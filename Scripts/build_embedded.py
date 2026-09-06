#!/usr/bin/env python3
"""Build the explicit static-display Embedded profile, without SwiftPM deps."""
import argparse
import os
from pathlib import Path
import re
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--target", choices=("host", "riscv32"), required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--swiftc", default=os.environ.get("SWIFTC", "swiftc"))
    parser.add_argument("--arch", default="rv32imc_zicsr_zifencei")
    parser.add_argument("--ar")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    sources = [root / line for line in (root / "Embedded/sources.txt").read_text().splitlines() if line]
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    command = [args.swiftc, "-enable-experimental-feature", "Embedded", "-wmo", "-Osize",
               "-parse-as-library", "-DOPENSWIFTUI_LVGL", "-package-name", "OpenSwiftUI",
               "-module-name", "OpenSwiftUI", "-Xfrontend", "-function-sections",
               "-Xfrontend", "-enable-single-module-llvm-emission"]
    # Use the same availability macro names as the normal package. This profile
    # has no Apple platform deployment dependency; the macros keep shared files
    # parseable in both profiles without deleting their normal annotations.
    macros = sorted(set(re.findall(r"@available\((OpenSwiftUI_\w+|_distantFuture)",
                                  "\n".join(p.read_text() for p in sources))))
    for macro in macros:
        command += ["-enable-experimental-feature", f"AvailabilityMacro={macro}:macOS 10.15, iOS 13.0"]
    if args.target == "riscv32":
        command += ["-target", "riscv32-none-none-eabi", "-Xcc", "-march=" + args.arch,
                    "-Xcc", "-mabi=ilp32", "-Xcc", "-fno-pic", "-Xcc", "-fno-pie"]
    elif os.uname().sysname == "Darwin":
        command += ["-sdk", subprocess.check_output(["xcrun", "--show-sdk-path"], text=True).strip()]
    object_file = output / "OpenSwiftUI.o"
    subprocess.run(command + ["-emit-module", "-emit-module-path", str(output / "OpenSwiftUI.swiftmodule"),
                              "-emit-object", "-o", str(object_file)] + [str(p) for p in sources], check=True)
    if args.target == "riscv32":
        subprocess.run(["riscv32-esp-elf-objcopy", "--remove-section", ".swift_modhash", str(object_file)], check=True)
    archive = output / "libOpenSwiftUI.a"
    archive.unlink(missing_ok=True)
    ar = args.ar or ("riscv32-esp-elf-ar" if args.target == "riscv32" else "ar")
    subprocess.run([ar, "rcs", str(archive), str(object_file)], check=True)
    print(f"Embedded OpenSwiftUI: {args.target}, {len(sources)} source files, {archive.stat().st_size} archive bytes")


if __name__ == "__main__":
    main()
