#!/usr/bin/env python3
"""Check XCFramework module versions against the source checkout's VERSION.txt."""

import argparse
import plistlib
import re
import shlex
import subprocess
import sys
import tempfile
from pathlib import Path


MODULES = ("OpenSwiftUI", "OpenSwiftUICore")
SDKS = {
    ("macos", ""): "macosx",
    ("ios", ""): "iphoneos",
    ("ios", "simulator"): "iphonesimulator",
    ("xros", ""): "xros",
    ("xros", "simulator"): "xrsimulator",
}


def module_slices(root, module, version):
    package = root / f"{module}.xcframework"
    info = plistlib.loads((package / "Info.plist").read_bytes())
    libraries = info["AvailableLibraries"]
    if not libraries:
        raise ValueError(f"No libraries in {package}")
    slices = {}
    for library in libraries:
        framework = package / library["LibraryIdentifier"] / library["LibraryPath"]
        directory = framework / "Modules" / f"{module}.swiftmodule"
        interfaces = {}
        for interface in sorted(directory.glob("*.swiftinterface")):
            if interface.name.endswith((".private.swiftinterface", ".package.swiftinterface")):
                continue
            match = re.search(r"^// swift-module-flags: (.*)$", interface.read_text(), re.MULTILINE)
            flags = shlex.split(match[1]) if match else []
            if flags.count("-user-module-version") != 1:
                raise ValueError(f"Missing or duplicate user module version: {interface}")
            index = flags.index("-user-module-version")
            if flags[index + 1:index + 2] != [version]:
                raise ValueError(f"Expected user module version {version}: {interface}")
            interfaces[interface] = flags
        for architecture in library["SupportedArchitectures"]:
            matches = [file for file in interfaces if file.stem == architecture or file.name.startswith(architecture + "-")]
            if not matches:
                raise ValueError(f"No public interface for {architecture}: {directory}")
            flags = interfaces[matches[0]]
            target = flags[flags.index("-target") + 1]
            key = (library["SupportedPlatform"], library.get("SupportedPlatformVariant", ""), architecture)
            if key in slices:
                raise ValueError(f"Duplicate platform and architecture: {package}: {key}")
            slices[key] = (framework.parent, target)
        if not interfaces or not library["SupportedArchitectures"]:
            raise ValueError(f"No public interfaces or architectures: {framework}")
    return slices


def check_imports(modules, version, output):
    output.mkdir(parents=True, exist_ok=True)
    major, minor, patch = map(int, version.split("."))
    upper = f"{major}.{minor}.{patch + 1}"
    source = output / "VersionCheck.swift"
    source.write_text("\n".join(
        f'#if !canImport({module}, _version: {version})\n'
        f'#error("{module} must provide version {version}")\n#endif\n'
        f'#if canImport({module}, _version: {upper})\n'
        f'#error("{module} must be below version {upper}")\n#endif\n'
        for module in MODULES
    ))
    for key in sorted(modules[MODULES[0]]):
        platform, variant, architecture = key
        sdk = SDKS[(platform, variant)]
        name = "-".join(part for part in key if part)
        sdk_path = subprocess.check_output(["xcrun", "--sdk", sdk, "--show-sdk-path"], text=True).strip()
        cache = tempfile.mkdtemp(prefix=f"{name}-cache-", dir=output)
        target = modules[MODULES[0]][key][1]
        command = ["xcrun", "swiftc", "-typecheck", str(source), "-sdk", sdk_path,
                   "-target", target, "-module-cache-path", cache, "-warnings-as-errors",
                   "-Xfrontend", "-module-load-mode", "-Xfrontend", "prefer-interface"]
        for module in MODULES:
            command.extend(["-F", str(modules[module][key][0])])
        result = subprocess.run(command, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        log = output / f"{name}.log"
        log.write_text(f"$ {shlex.join(command)}\n\n{result.stdout}")
        if result.returncode:
            raise ValueError(f"Module version import check failed; see {log}\n{result.stdout}")
        print(f"Module version {version}: {name} passed")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("build_root", type=Path)
    parser.add_argument("--check-imports", type=Path, metavar="OUTPUT", help="Compile version boundaries with fresh caches and save the logs")
    args = parser.parse_args()
    version_file = Path(__file__).resolve().parents[2] / "VERSION.txt"
    version = version_file.read_text().strip()
    if not re.fullmatch(r"(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)", version):
        raise ValueError(f"Use a stable version such as 0.25.0, without a v prefix, in {version_file}.")
    modules = {module: module_slices(args.build_root.resolve(), module, version) for module in MODULES}
    if modules[MODULES[0]].keys() != modules[MODULES[1]].keys():
        raise ValueError("OpenSwiftUI and OpenSwiftUICore must provide the same platforms and architectures")
    print(f"Public interfaces match module version {version}")
    if args.check_imports:
        check_imports(modules, version, args.check_imports.resolve())


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError, IndexError, subprocess.CalledProcessError) as error:
        print(f"error: {error}", file=sys.stderr)
        sys.exit(1)
