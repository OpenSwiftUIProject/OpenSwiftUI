"""LLDB command for printing SwiftUI display lists minimally.

SwiftUI's SWIFTUI_PRINT_TREE path calls DisplayList.description. While the
inferior is stopped, this command temporarily replaces that getter's first
arm64 instruction with a direct branch to DisplayList.minimalDescription.
Both getters have the same Swift calling convention, so SwiftUI keeps its
original environment gating, prefix, and printing schedule.
"""

import lldb
import shlex
import struct


_COMMAND_NAME = "swiftui-display-list-minimal"
_DESCRIPTION_SYMBOL = "$s7SwiftUI11DisplayListV11descriptionSSvg"
_MINIMAL_DESCRIPTION_SYMBOL = (
    "$s7SwiftUI11DisplayListV18minimalDescriptionSSvg"
)
_SWIFTUI_CORE_MODULE = "SwiftUICore"
_PRINT_TREE_ENVIRONMENT_KEY = "SWIFTUI_PRINT_TREE"
_ARM64_BRANCH_OPCODE = 0x14000000
_ARM64_BRANCH_IMMEDIATE_MASK = 0x03FFFFFF
_INSTRUCTION_SIZE = 4
_GONE_PROCESS_STATES = {
    lldb.eStateInvalid,
    lldb.eStateUnloaded,
    lldb.eStateExited,
}
_WRITABLE_PROCESS_STATES = {
    lldb.eStateStopped,
    lldb.eStateCrashed,
    lldb.eStateSuspended,
}

# Preserve the patch across `command script import` reloads in one LLDB
# session. A process restart restores the framework mapping by itself.
if "_PATCH_STATE" not in globals():
    _PATCH_STATE = None


class HookError(RuntimeError):
    pass


def _selected_target(debugger):
    target = debugger.GetSelectedTarget()
    if not target.IsValid():
        raise HookError("No LLDB target is selected.")
    return target


def _stopped_process(target):
    process = target.GetProcess()
    if not process.IsValid() or process.GetProcessID() == 0:
        raise HookError(
            "Launch the process and pause it before enabling the hook."
        )
    if process.GetState() != lldb.eStateStopped:
        raise HookError("Pause the process before changing the hook.")
    return process


def _symbol_load_addresses(module, target, name):
    contexts = module.FindSymbols(name, lldb.eSymbolTypeCode)
    addresses = set()
    for index in range(contexts.GetSize()):
        symbol = contexts.GetContextAtIndex(index).GetSymbol()
        if not symbol.IsValid():
            continue
        address = symbol.GetStartAddress().GetLoadAddress(target)
        if address != lldb.LLDB_INVALID_ADDRESS:
            addresses.add(address)
    return addresses


def _branch_instruction(source, destination):
    if source == destination:
        raise HookError("The two DisplayList getters resolve to one address.")

    delta = destination - source
    if delta % _INSTRUCTION_SIZE != 0:
        raise HookError("Getter addresses are not instruction-aligned.")

    immediate = delta // _INSTRUCTION_SIZE
    if immediate < -(1 << 25) or immediate >= (1 << 25):
        raise HookError(
            "DisplayList.minimalDescription is outside arm64 branch range."
        )
    instruction = (
        _ARM64_BRANCH_OPCODE
        | (immediate & _ARM64_BRANCH_IMMEDIATE_MASK)
    )
    return struct.pack("<I", instruction)


def _resolve_patch(target):
    architecture = (target.GetTriple() or "").split("-", 1)[0]
    if architecture not in {"arm64", "arm64e"}:
        raise HookError(
            "The hook currently supports arm64 and arm64e targets only."
        )

    modules = [
        target.GetModuleAtIndex(index)
        for index in range(target.GetNumModules())
        if target.GetModuleAtIndex(index).GetFileSpec().GetFilename()
        == _SWIFTUI_CORE_MODULE
    ]
    if not modules:
        raise HookError(
            "SwiftUICore is not loaded. Continue to an early app breakpoint, "
            "pause, and try again."
        )

    candidates = []
    for module in modules:
        sources = _symbol_load_addresses(module, target, _DESCRIPTION_SYMBOL)
        destinations = _symbol_load_addresses(
            module,
            target,
            _MINIMAL_DESCRIPTION_SYMBOL,
        )
        if len(sources) == 1 and len(destinations) == 1:
            candidates.append((sources.pop(), destinations.pop()))
    if not candidates:
        raise HookError("Could not resolve both DisplayList getters uniquely.")
    if len(candidates) != 1:
        raise HookError(
            "Multiple loaded SwiftUICore images contain the DisplayList "
            "getters; refusing to choose one."
        )

    source, destination = candidates[0]
    return source, destination, _branch_instruction(source, destination)


def _read_instruction(process, address):
    error = lldb.SBError()
    data = process.ReadMemory(address, _INSTRUCTION_SIZE, error)
    if error.Fail() or len(data) != _INSTRUCTION_SIZE:
        message = error.GetCString() or "short read"
        raise HookError(
            "Could not read SwiftUICore memory at {:#x}: {}".format(
                address,
                message,
            )
        )
    return data


def _write_instruction(process, address, instruction):
    error = lldb.SBError()
    count = process.WriteMemory(address, instruction, error)
    if error.Fail() or count != len(instruction):
        message = error.GetCString() or "short write"
        raise HookError(
            "Could not write SwiftUICore memory at {:#x}: {}".format(
                address,
                message,
            )
        )
    if _read_instruction(process, address) != instruction:
        raise HookError(
            "SwiftUICore did not retain the instruction written at "
            "{:#x}.".format(address)
        )


def _breakpoint_locations_at_address(target, address):
    for index in range(target.GetNumBreakpoints()):
        breakpoint = target.GetBreakpointAtIndex(index)
        if not breakpoint.IsValid() or not breakpoint.IsEnabled():
            continue
        for location_index in range(breakpoint.GetNumLocations()):
            location = breakpoint.GetLocationAtIndex(location_index)
            if location.GetAddress().GetLoadAddress(target) == address:
                yield location


def _disable_conflicting_breakpoints(target, address):
    disabled = []
    for location in _breakpoint_locations_at_address(target, address):
        if location.IsEnabled():
            location.SetEnabled(False)
            disabled.append(location)
    return disabled


def _restore_breakpoints(locations):
    for location in locations:
        if location.IsValid():
            location.SetEnabled(True)


def _print_tree_environment(target):
    value = target.GetLaunchInfo().GetEnvironment().Get(
        _PRINT_TREE_ENVIRONMENT_KEY
    )
    if value is not None:
        return value

    process = target.GetProcess()
    if process.IsValid() and process.GetProcessID() != 0:
        return "<unknown after launch>"
    return "<unset>"


def _new_patch_state(
    target,
    process,
    source,
    destination,
    original,
    instruction,
    locations,
    uncertain=False,
):
    return {
        "target": target,
        "process": process,
        "process_id": process.GetProcessID(),
        "process_unique_id": process.GetUniqueID(),
        "source": source,
        "destination": destination,
        "original": original,
        "instruction": instruction,
        "locations": locations,
        "uncertain": uncertain,
    }


def _same_process(state, process):
    return state["process_unique_id"] == process.GetUniqueID()


def _retire_ended_patch():
    global _PATCH_STATE

    if _PATCH_STATE is None:
        return
    process = _PATCH_STATE["process"]
    state = process.GetState() if process.IsValid() else lldb.eStateInvalid
    if state in _GONE_PROCESS_STATES:
        _restore_breakpoints(_PATCH_STATE["locations"])
        _PATCH_STATE = None


def _prepare_enable(target, process, source, instruction):
    """Return True when this process already contains the active patch."""
    global _PATCH_STATE

    _retire_ended_patch()
    if _PATCH_STATE is None:
        return False
    if not _same_process(_PATCH_STATE, process):
        raise HookError(
            "The hook is still active in process {}. Disable it before "
            "enabling another process.".format(_PATCH_STATE["process_id"])
        )
    if (
        _PATCH_STATE["source"] != source
        or _PATCH_STATE["instruction"] != instruction
    ):
        raise HookError(
            "The active hook no longer matches the resolved SwiftUICore "
            "symbols. Disable it before continuing."
        )

    current = _read_instruction(process, source)
    if current == instruction:
        _PATCH_STATE["locations"].extend(
            _disable_conflicting_breakpoints(target, source)
        )
        return True
    if current != _PATCH_STATE["original"]:
        raise HookError(
            "DisplayList.description changed after the hook was enabled."
        )

    # Someone restored the instruction independently. Release our ownership of
    # the breakpoints before installing a fresh patch.
    _restore_breakpoints(_PATCH_STATE["locations"])
    _PATCH_STATE = None
    return False


def _enable(debugger, result):
    global _PATCH_STATE

    target = _selected_target(debugger)
    process = _stopped_process(target)
    source, destination, instruction = _resolve_patch(target)
    if _prepare_enable(target, process, source, instruction):
        result.AppendMessage(
            "SwiftUI minimal display-list printing is already enabled."
        )
        return

    locations = _disable_conflicting_breakpoints(target, source)
    original = None
    write_started = False
    try:
        original = _read_instruction(process, source)
        if original == instruction:
            raise HookError(
                "DisplayList.description is already patched, but its "
                "original instruction is unavailable; restart the process "
                "to reset it."
            )
        write_started = True
        _write_instruction(process, source, instruction)
    except HookError as error:
        if write_started:
            try:
                _write_instruction(process, source, original)
            except HookError as rollback_error:
                _PATCH_STATE = _new_patch_state(
                    target,
                    process,
                    source,
                    destination,
                    original,
                    instruction,
                    locations,
                    uncertain=True,
                )
                raise HookError(
                    "{} Rollback also failed: {} The instruction may be "
                    "partially modified; keep the process paused and run "
                    "`{} disable` again.".format(
                        error,
                        rollback_error,
                        _COMMAND_NAME,
                    )
                )
        _restore_breakpoints(locations)
        raise

    _PATCH_STATE = _new_patch_state(
        target,
        process,
        source,
        destination,
        original,
        instruction,
        locations,
    )
    result.AppendMessage(
        "Enabled SwiftUI minimal display-list printing: {:#x} -> {:#x}.".format(
            source,
            destination,
        )
    )
    if locations:
        result.AppendMessage(
            "Disabled {} conflicting description breakpoint(s) for this "
            "session.".format(len(locations))
        )
    if _print_tree_environment(target) == "<unset>":
        result.AppendMessage(
            "Note: set SWIFTUI_PRINT_TREE=1 in the Scheme before launching "
            "the process."
        )


def _disable(result):
    global _PATCH_STATE

    if _PATCH_STATE is None:
        result.AppendMessage("SwiftUI minimal display-list printing is disabled.")
        return

    state = _PATCH_STATE
    process = state["process"]
    process_state = (
        process.GetState() if process.IsValid() else lldb.eStateInvalid
    )
    if process_state == lldb.eStateDetached:
        raise HookError(
            "Process {} is detached and may still contain the patch. "
            "This LLDB session can no longer restore it; terminate the "
            "process to discard the process-local change.".format(
                state["process_id"]
            )
        )
    if process_state not in _GONE_PROCESS_STATES:
        if process_state not in _WRITABLE_PROCESS_STATES:
            raise HookError(
                "Pause process {} before disabling the hook.".format(
                    state["process_id"]
                )
            )

        current = _read_instruction(process, state["source"])
        if current != state["original"]:
            if current != state["instruction"] and not state["uncertain"]:
                raise HookError(
                    "DisplayList.description contains an unrelated "
                    "instruction; refusing to overwrite it."
                )
            _write_instruction(
                process,
                state["source"],
                state["original"],
            )

    _restore_breakpoints(state["locations"])
    _PATCH_STATE = None
    result.AppendMessage("Disabled SwiftUI minimal display-list printing.")


def _patch_status(state):
    process = state["process"]
    process_state = (
        process.GetState() if process.IsValid() else lldb.eStateInvalid
    )
    if process_state in _GONE_PROCESS_STATES:
        return "disabled (process ended; breakpoint cleanup pending)"
    if process_state == lldb.eStateDetached:
        return "enabled (process detached; restoration pending)"
    if process_state not in _WRITABLE_PROCESS_STATES:
        return "enabled (unverified while process is running)"

    try:
        current = _read_instruction(process, state["source"])
    except HookError as error:
        return "unknown ({})".format(error)
    if current == state["instruction"]:
        return "enabled"
    if current == state["original"]:
        return "disabled externally (breakpoint cleanup pending)"
    return "unknown (description instruction changed externally)"


def _status(debugger, result):
    target = _selected_target(debugger)
    state = _PATCH_STATE
    status = "disabled" if state is None else _patch_status(state)
    result.AppendMessage(
        "SwiftUI minimal display-list printing: {}".format(status)
    )
    result.AppendMessage("mode=arm64 branch patch (no breakpoint)")

    reporting_target = state["target"] if state is not None else target
    result.AppendMessage("target={}".format(reporting_target.GetTriple()))
    result.AppendMessage(
        "{}={}".format(
            _PRINT_TREE_ENVIRONMENT_KEY,
            _print_tree_environment(reporting_target),
        )
    )
    if state is not None:
        result.AppendMessage(
            "process={}, description={:#x}, minimalDescription={:#x}".format(
                state["process_id"],
                state["source"],
                state["destination"],
            )
        )
        result.AppendMessage(
            "conflicting_breakpoints_disabled={}".format(
                len(state["locations"])
            )
        )


def swiftui_display_list_minimal(
    debugger,
    command,
    result,
    internal_dict,
):
    del internal_dict

    try:
        arguments = shlex.split(command)
        if len(arguments) != 1 or arguments[0] not in {
            "enable",
            "disable",
            "status",
        }:
            raise HookError(
                "usage: {} enable|disable|status".format(_COMMAND_NAME)
            )

        action = arguments[0]
        if action == "enable":
            _enable(debugger, result)
        elif action == "disable":
            _disable(result)
        else:
            _status(debugger, result)
    except (HookError, ValueError) as error:
        result.SetError(str(error))


def __lldb_init_module(debugger, internal_dict):
    del internal_dict

    debugger.HandleCommand(
        'command script add --overwrite -h "Redirect SwiftUI display-list '
        'tree output to minimalDescription without a breakpoint." -f '
        '{}.swiftui_display_list_minimal {}'.format(
            __name__,
            _COMMAND_NAME,
        )
    )
    print(
        "Installed LLDB command: {} enable|disable|status".format(
            _COMMAND_NAME
        )
    )
