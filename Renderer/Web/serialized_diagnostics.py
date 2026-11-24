"""Best-effort recovery of Swift errors omitted from SwiftPM's console output."""

import ctypes
from pathlib import Path
from typing import List, Optional


class CXString(ctypes.Structure):
    _fields_ = [("data", ctypes.c_void_p), ("private_flags", ctypes.c_uint)]


class DiagnosticReader:
    def __init__(self, library: Path) -> None:
        self.library = ctypes.CDLL(str(library))
        self.load = self._function(
            "clang_loadDiagnostics",
            [ctypes.c_char_p, ctypes.POINTER(ctypes.c_int), ctypes.POINTER(CXString)],
            ctypes.c_void_p,
        )
        self.count = self._function("clang_getNumDiagnosticsInSet", [ctypes.c_void_p], ctypes.c_uint)
        self.get = self._function("clang_getDiagnosticInSet", [ctypes.c_void_p, ctypes.c_uint], ctypes.c_void_p)
        self.severity = self._function("clang_getDiagnosticSeverity", [ctypes.c_void_p], ctypes.c_uint)
        self.format = self._function("clang_formatDiagnostic", [ctypes.c_void_p, ctypes.c_uint], CXString)
        self.string = self._function("clang_getCString", [CXString], ctypes.c_char_p)
        self.dispose_string = self._function("clang_disposeString", [CXString], None)
        self.dispose_diagnostic = self._function("clang_disposeDiagnostic", [ctypes.c_void_p], None)
        self.dispose_set = self._function("clang_disposeDiagnosticSet", [ctypes.c_void_p], None)

    def _function(self, name, arguments, result):
        function = getattr(self.library, name)
        function.argtypes = arguments
        function.restype = result
        return function

    def errors(self, path: Path) -> List[str]:
        error = ctypes.c_int()
        message = CXString()
        diagnostics = self.load(bytes(path), ctypes.byref(error), ctypes.byref(message))
        self.dispose_string(message)
        if not diagnostics:
            return []
        result: List[str] = []
        try:
            for index in range(self.count(diagnostics)):
                diagnostic = self.get(diagnostics, index)
                try:
                    if self.severity(diagnostic) < 3:  # CXDiagnostic_Error
                        continue
                    # Include source locations and column numbers, as in Swift's text log.
                    formatted = self.format(diagnostic, 3)
                    try:
                        value = self.string(formatted)
                        if value:
                            result.append(value.decode("utf-8", errors="replace"))
                    finally:
                        self.dispose_string(formatted)
                finally:
                    self.dispose_diagnostic(diagnostic)
        finally:
            self.dispose_set(diagnostics)
        return result


def recover_errors(build_directory: Path, started_ns: int, build_tool: Optional[Path]) -> List[str]:
    """Read only diagnostics written by this build; never reuse stale errors.

    libclang ships with some Swift toolchains but is not a Preview prerequisite.
    If it is absent, incompatible, or cannot read a file, keep the console errors.
    """
    if build_tool is None:
        return []
    try:
        paths = [
            path for path in build_directory.rglob("*.dia")
            if path.is_file() and path.stat().st_mtime_ns >= started_ns
        ]
        if not paths:
            return []
        library_directory = build_tool.resolve().parent.parent / "lib"
        libraries = [library_directory / "libclang.dylib", library_directory / "libclang.so"]
        libraries.extend(sorted(library_directory.glob("libclang.so.*")))
        library = next((path for path in libraries if path.is_file()), None)
        if library is None:
            return []
        reader = DiagnosticReader(library)
    except (OSError, AttributeError):
        return []

    errors: List[str] = []
    for path in sorted(paths):
        try:
            errors.extend(reader.errors(path))
        except (OSError, ValueError):
            continue
    return list(dict.fromkeys(errors))
