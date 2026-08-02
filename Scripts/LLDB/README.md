# SwiftUI Display-List LLDB Commands

`swiftui_displaylist_minimal_description.py` redirects SwiftUI's full
display-list description to its minimal description while debugging.

SwiftUI normally checks `SWIFTUI_PRINT_TREE` and then calls `description`.
The two getters use the same Swift calling convention and return the same type:

```text
$s7SwiftUI11DisplayListV11descriptionSSvg
$s7SwiftUI11DisplayListV18minimalDescriptionSSvg
```

While the process is paused, the script replaces the first arm64 instruction
of `description` with a direct branch to `minimalDescription`. SwiftUI retains
its existing environment-variable check, output prefix, and printing schedule;
only the display-list payload changes from the full form to the minimal form.
No breakpoint is required, so Xcode does not stop for each printed tree.

## Usage

Enable `SWIFTUI_PRINT_TREE=1` in the Xcode Scheme before launching the app.
SwiftUI caches this setting, so changing it after launch requires a relaunch.

Run the app until SwiftUICore is loaded, pause it, then import and enable the
hook:

```text
(lldb) command script import <path-to-checkout>/Scripts/LLDB/swiftui_displaylist_minimal_description.py
(lldb) swiftui-display-list-minimal enable
```

The `SUI_Example`, `SUI_HostingExample`, and `SUI_TestingHost` schemes import
the script automatically through the adjacent `.lldbinit-swiftui` file; for
those schemes, only the `enable` command is needed after pausing.

Continue execution. Tree output now uses `minimalDescription`, for example:

```text
View 0x... at Time(...):
(DL(I:...))
```

Inspect or remove the hook while the process is paused:

```text
(lldb) swiftui-display-list-minimal status
(lldb) swiftui-display-list-minimal disable
```

`disable` restores the exact instruction bytes that were present before
`enable`. A process restart also restores the original SwiftUICore mapping.

## Existing description breakpoints

Xcode can persist script-created breakpoints while dropping their Python
actions. Such a breakpoint stops in `DisplayList.description` and then executes
the full getter when continued.

When enabling the hook, the script temporarily disables any breakpoint location
already resolved at the `description` entry. It restores those locations when
the hook is disabled. A stale symbolic breakpoint can also be removed once from
Xcode's Breakpoint navigator.

## Scope

- The script has been validated against SwiftUI 6.5.4 on an arm64 iOS 18.5
  Simulator.
- The hook currently supports arm64 and arm64e targets. It validates instruction
  alignment and the direct-branch range before changing memory.
- The getters are private implementation details and may change between OS
  releases. Missing or ambiguous symbols leave the process unchanged.
- While enabled, every direct call to `DisplayList.description` is redirected,
  not only calls originating from `SWIFTUI_PRINT_TREE`.
- The change exists only in the debugged process. It does not modify the
  SwiftUICore binary on disk.
- Disable the hook before detaching LLDB if the process will remain alive.
