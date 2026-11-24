import os
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock


WEB_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(WEB_ROOT))
try:
    import serialized_diagnostics
finally:
    sys.path.pop(0)


class SerializedDiagnosticsTests(unittest.TestCase):
    def fixture(self, root):
        tool = root / "toolchain" / "bin" / "swift-build-tool"
        tool.parent.mkdir(parents=True)
        tool.touch()
        library = root / "toolchain" / "lib" / "libclang.dylib"
        library.parent.mkdir()
        library.touch()
        build = root / "build"
        build.mkdir()
        return tool, library, build

    def test_only_current_build_diagnostics_are_read_and_duplicate_errors_removed(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            tool, library, build = self.fixture(Path(temporary_directory))
            for name, modified in (("stale.dia", 100), ("current.dia", 200)):
                path = build / name
                path.touch()
                os.utime(str(path), ns=(modified, modified))
            with mock.patch.object(serialized_diagnostics, "DiagnosticReader") as reader:
                reader.return_value.errors.return_value = ["error: missing argument"] * 2
                result = serialized_diagnostics.recover_errors(build, 150, tool)

            self.assertEqual(result, ["error: missing argument"])
            reader.assert_called_once_with(library.resolve())
            reader.return_value.errors.assert_called_once_with(build / "current.dia")

    def test_absent_or_unloadable_library_leaves_console_errors_available(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            tool, library, build = self.fixture(Path(temporary_directory))
            (build / "current.dia").touch()
            with mock.patch.object(
                serialized_diagnostics, "DiagnosticReader", side_effect=OSError("unavailable"),
            ):
                self.assertEqual(serialized_diagnostics.recover_errors(build, 0, tool), [])
            library.unlink()
            with mock.patch.object(serialized_diagnostics, "DiagnosticReader") as reader:
                self.assertEqual(serialized_diagnostics.recover_errors(build, 0, tool), [])
                reader.assert_not_called()
            self.assertEqual(serialized_diagnostics.recover_errors(build, 0, None), [])

    def test_unreadable_file_does_not_hide_other_errors(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            tool, _, build = self.fixture(Path(temporary_directory))
            (build / "a.dia").touch()
            (build / "b.dia").touch()
            with mock.patch.object(serialized_diagnostics, "DiagnosticReader") as reader:
                reader.return_value.errors.side_effect = [OSError("unreadable"), ["error: actual"]]
                result = serialized_diagnostics.recover_errors(build, 0, tool)
            self.assertEqual(result, ["error: actual"])

    def test_reader_skips_warnings_and_releases_native_objects(self):
        reader = serialized_diagnostics.DiagnosticReader.__new__(serialized_diagnostics.DiagnosticReader)
        reader.load = mock.Mock(return_value=100)
        reader.count = mock.Mock(return_value=2)
        reader.get = mock.Mock(side_effect=[101, 102])
        reader.severity = mock.Mock(side_effect=[2, 3])
        reader.format = mock.Mock(return_value=serialized_diagnostics.CXString())
        reader.string = mock.Mock(return_value=b"Text.swift:1:2: error: missing argument")
        reader.dispose_string = mock.Mock()
        reader.dispose_diagnostic = mock.Mock()
        reader.dispose_set = mock.Mock()

        self.assertEqual(reader.errors(Path("example.dia")), ["Text.swift:1:2: error: missing argument"])
        reader.format.assert_called_once_with(102, 3)
        self.assertEqual(reader.dispose_diagnostic.call_args_list, [mock.call(101), mock.call(102)])
        self.assertEqual(reader.dispose_string.call_count, 2)
        reader.dispose_set.assert_called_once_with(100)


if __name__ == "__main__":
    unittest.main()
