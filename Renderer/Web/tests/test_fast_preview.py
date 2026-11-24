import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock


WEB_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(WEB_ROOT))
try:
    import playground_server  # noqa: E402
finally:
    sys.path.pop(0)


class FastPreviewTests(unittest.TestCase):
    def coordinator(self):
        coordinator = playground_server.BuildCoordinator()
        coordinator._revision = 7
        return coordinator

    def test_parse_diagnostics_reads_swift_parseable_output(self):
        diagnostic = "{}:4:9: error: expected expression\n".format(
            playground_server.SOURCE_PATH
        )
        log = "42\n" + json.dumps(
            {"kind": "finished", "output": diagnostic},
            indent=2,
        )

        self.assertEqual(
            playground_server.parse_diagnostics(log),
            [{
                "file": "ExampleApp/ContentView.swift",
                "line": 4,
                "column": 9,
                "severity": "error",
                "message": "expected expression",
                "editable": True,
            }],
        )

    def test_clean_log_strips_ansi_and_truncates(self):
        raw_log = "\N{ESCAPE}[31merror\N{ESCAPE}[0m\x00" + (
            "x" * playground_server.MAX_LOG_CHARACTERS
        )

        cleaned = playground_server.clean_log(raw_log)

        self.assertNotIn("\N{ESCAPE}", cleaned)
        self.assertNotIn("\x00", cleaned)
        self.assertIn("build log truncated", cleaned)
        self.assertLessEqual(
            len(cleaned),
            playground_server.MAX_LOG_CHARACTERS + 64,
        )

    def test_linker_and_fatal_errors_are_visible_in_problems(self):
        log = "\n".join([
            "wasm-ld: error: unable to find library -lswiftDemangle",
            "clang: error: linker command failed with exit code 1",
            "clang: fatal error: too many errors emitted",
            "fatal error: module build failed",
            "ContentView.swift:4:9: fatal error: cannot load module",
            "clang: warning: unused linker argument",
            "ordinary progress output",
        ])

        diagnostics = playground_server.parse_diagnostics(log)

        self.assertEqual(
            [(item["severity"], item["message"]) for item in diagnostics],
            [
                ("error", "wasm-ld: unable to find library -lswiftDemangle"),
                ("error", "clang: linker command failed with exit code 1"),
                ("error", "clang: too many errors emitted"),
                ("error", "module build failed"),
                ("error", "cannot load module"),
                ("warning", "clang: unused linker argument"),
            ],
        )
        self.assertIsNone(diagnostics[0]["file"])
        self.assertFalse(diagnostics[0]["editable"])
        self.assertEqual(diagnostics[4]["line"], 4)

    def test_errors_are_not_crowded_out_by_warnings(self):
        log = "\n".join(
            "warning: warning {}".format(index)
            for index in range(playground_server.MAX_DIAGNOSTICS + 1)
        ) + "\nContentView.swift:4:9: error: missing argument\n"

        diagnostics = playground_server.parse_diagnostics(log)

        self.assertEqual(len(diagnostics), playground_server.MAX_DIAGNOSTICS)
        self.assertEqual(diagnostics[0]["severity"], "error")
        self.assertEqual(diagnostics[0]["message"], "missing argument")

    def test_process_keeps_errors_outside_display_log_and_recovers_serialized_errors(self):
        coordinator = self.coordinator()
        padding = "x" * playground_server.MAX_LOG_CHARACTERS
        output = (
            padding + "\nContentView.swift:4:9: error: original error\n" + padding
        )
        process = mock.Mock(returncode=1)
        process.communicate.return_value = (output, None)
        recovered = "Text+View.swift:1736:67: error: missing textMeasurementProvider"

        with mock.patch.object(
            playground_server.subprocess, "Popen", return_value=process,
        ), mock.patch.object(
            playground_server, "recover_errors", return_value=[recovered],
        ) as recover:
            result = coordinator._run_process(["unused-build-command"], "full")

        self.assertFalse(result.succeeded)
        self.assertNotIn("original error", result.log)
        self.assertIn("build log truncated", result.log)
        self.assertEqual(
            [item["message"] for item in result.diagnostics],
            ["original error", "missing textMeasurementProvider"],
        )
        recover.assert_called_once()
        self.assertIsNone(coordinator._process)

    def test_successful_process_does_not_read_old_serialized_errors(self):
        coordinator = self.coordinator()
        process = mock.Mock(returncode=0)
        process.communicate.return_value = ("Build complete", None)
        with mock.patch.object(
            playground_server.subprocess, "Popen", return_value=process,
        ), mock.patch.object(playground_server, "recover_errors") as recover:
            result = coordinator._run_process(["unused-build-command"], "fast")
        self.assertTrue(result.succeeded)
        self.assertEqual(result.diagnostics, [])
        recover.assert_not_called()

    def test_full_build_preserves_diagnostics_not_present_in_truncated_log(self):
        coordinator = self.coordinator()
        diagnostics = playground_server.parse_diagnostics(
            "Text+View.swift:1736:67: error: missing argument"
        )
        process_result = playground_server.BuildResult(
            succeeded=False,
            duration_ms=100,
            log="… build log truncated …",
            diagnostics=diagnostics,
            mode="full",
        )
        with tempfile.TemporaryDirectory() as temporary_directory, mock.patch.object(
            playground_server, "STAGING_BUNDLE", Path(temporary_directory) / "Bundle",
        ), mock.patch.object(coordinator, "_discard_staging"), mock.patch.object(
            coordinator, "_run_process", return_value=process_result,
        ):
            result = coordinator._run_full_build()
        self.assertFalse(result.succeeded)
        self.assertEqual(result.diagnostics, diagnostics)

    def test_fast_build_reuses_llbuild_plan_and_assembles_bundle(self):
        coordinator = self.coordinator()
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            manifest = root / "plugin-tools.yaml"
            database = root / "build.db"
            wasm = root / "ExampleApp.wasm"
            template = root / "template"
            staging = root / "staging" / "Bundle"
            for path in (manifest, database, wasm):
                path.write_bytes(b"data")
            for relative_path in playground_server.REQUIRED_BUNDLE_FILES:
                if relative_path == "ExampleApp.wasm":
                    continue
                path = template / relative_path
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(b"template")

            tool = root / "swift-build-tool"
            tool.write_bytes(b"tool")
            coordinator._fast_build_tool = tool
            process_result = playground_server.BuildResult(
                succeeded=True,
                duration_ms=12,
                log="",
                diagnostics=[],
                mode="fast",
            )

            with mock.patch.multiple(
                playground_server,
                FAST_MANIFEST=manifest,
                FAST_DATABASE=database,
                FAST_WASM=wasm,
                FAST_TEMPLATE=template,
                STAGING_BUNDLE=staging,
            ), mock.patch.object(
                coordinator,
                "_run_process",
                return_value=process_result,
            ) as run_process:
                result = coordinator._run_fast_build(7)

            self.assertTrue(result.succeeded)
            self.assertEqual((staging / "ExampleApp.wasm").read_bytes(), b"data")
            arguments, mode = run_process.call_args.args
            self.assertEqual(mode, "fast")
            self.assertEqual(arguments[0], str(tool))
            self.assertEqual(arguments[1:5], ["-f", str(manifest), "--db", str(database)])
            self.assertEqual(arguments[5], "main")

    def test_swift_diagnostic_does_not_trigger_expensive_full_fallback(self):
        coordinator = self.coordinator()
        fast_result = playground_server.BuildResult(
            succeeded=False,
            duration_ms=20,
            log="compile error",
            diagnostics=[{
                "file": "ExampleApp/ContentView.swift",
                "severity": "error",
                "editable": True,
            }],
            mode="fast",
        )
        snapshot = playground_server.SourceSnapshot(7, "struct ContentView {}")

        with mock.patch.object(
            coordinator,
            "_fast_build_unavailable_reason",
            return_value=None,
        ), mock.patch.object(
            coordinator,
            "_run_fast_build",
            return_value=fast_result,
        ), mock.patch.object(coordinator, "_run_full_build") as full_build:
            result = coordinator._run_build(snapshot)

        self.assertIs(result, fast_result)
        full_build.assert_not_called()

    def test_fast_infrastructure_failure_falls_back_once(self):
        coordinator = self.coordinator()
        fast_result = playground_server.BuildResult(
            succeeded=False,
            duration_ms=20,
            log="llbuild exited",
            diagnostics=[],
            mode="fast",
        )
        full_result = playground_server.BuildResult(
            succeeded=True,
            duration_ms=100,
            log="",
            diagnostics=[],
            mode="full",
        )
        snapshot = playground_server.SourceSnapshot(7, "struct ContentView {}")

        with mock.patch.object(
            coordinator,
            "_fast_build_unavailable_reason",
            return_value=None,
        ), mock.patch.object(
            coordinator,
            "_run_fast_build",
            return_value=fast_result,
        ), mock.patch.object(
            coordinator,
            "_run_full_build",
            return_value=full_result,
        ) as full_build:
            result = coordinator._run_build(snapshot)

        self.assertIs(result, full_result)
        full_build.assert_called_once_with(
            "fast preview command failed without Swift diagnostics"
        )

    def test_global_fast_error_falls_back_but_source_error_does_not(self):
        coordinator = self.coordinator()
        snapshot = playground_server.SourceSnapshot(7, "struct ContentView {}")
        global_error = playground_server.BuildResult(
            succeeded=False,
            duration_ms=20,
            log="error: llbuild database is corrupt",
            diagnostics=[{
                "file": "",
                "line": 0,
                "column": 0,
                "severity": "error",
                "message": "llbuild database is corrupt",
                "editable": False,
            }],
            mode="fast",
        )
        source_error = playground_server.BuildResult(
            succeeded=False,
            duration_ms=20,
            log="App.swift:1:1: error: incompatible ContentView",
            diagnostics=[{
                "file": "ExampleApp/App.swift",
                "line": 1,
                "column": 1,
                "severity": "error",
                "message": "incompatible ContentView",
                "editable": False,
            }],
            mode="fast",
        )
        full_result = playground_server.BuildResult(
            succeeded=False,
            duration_ms=100,
            log="full failed",
            diagnostics=[],
            mode="full",
        )

        with mock.patch.object(
            coordinator,
            "_fast_build_unavailable_reason",
            return_value=None,
        ), mock.patch.object(
            coordinator,
            "_run_fast_build",
            side_effect=[global_error, source_error],
        ), mock.patch.object(
            coordinator,
            "_run_full_build",
            return_value=full_result,
        ) as full_build:
            self.assertIs(coordinator._run_build(snapshot), full_result)
            self.assertIs(coordinator._run_build(snapshot), source_error)

        full_build.assert_called_once_with(
            "fast preview command failed without Swift diagnostics"
        )

    def test_stale_fast_failure_does_not_start_full_build(self):
        coordinator = self.coordinator()
        coordinator._revision = 8
        fast_result = playground_server.BuildResult(
            succeeded=False,
            duration_ms=20,
            log="cancelled",
            diagnostics=[],
            mode="fast",
        )
        snapshot = playground_server.SourceSnapshot(7, "struct ContentView {}")

        with mock.patch.object(
            coordinator,
            "_fast_build_unavailable_reason",
            return_value=None,
        ), mock.patch.object(
            coordinator,
            "_run_fast_build",
            return_value=fast_result,
        ), mock.patch.object(coordinator, "_run_full_build") as full_build:
            result = coordinator._run_build(snapshot)

        self.assertTrue(result.cancelled)
        full_build.assert_not_called()

    def test_fast_cancellation_escalates_without_touching_a_new_process(self):
        coordinator = self.coordinator()
        process = mock.Mock(pid=1234)
        process.poll.return_value = None
        coordinator._process = process
        coordinator._process_mode = "fast"

        class ImmediateTimer:
            def __init__(self, _interval, action):
                self.action = action
                self.daemon = False

            def start(self):
                self.action()

        with mock.patch.object(
            playground_server.os,
            "killpg",
        ) as kill_process_group, mock.patch.object(
            playground_server.threading,
            "Timer",
            ImmediateTimer,
        ), mock.patch.object(
            coordinator,
            "_terminate_process",
        ) as terminate_process:
            coordinator._cancel_fast_process(process)

        kill_process_group.assert_called_once_with(
            process.pid,
            playground_server.signal.SIGINT,
        )
        terminate_process.assert_called_once_with(process)

        replacement = mock.Mock(pid=5678)
        coordinator._process = replacement
        coordinator._process_mode = "fast"
        with mock.patch.object(
            playground_server.os,
            "killpg",
        ) as kill_process_group, mock.patch.object(
            playground_server.threading,
            "Timer",
            ImmediateTimer,
        ), mock.patch.object(
            coordinator,
            "_terminate_process",
        ) as terminate_process:
            coordinator._cancel_fast_process(process)

        kill_process_group.assert_not_called()
        terminate_process.assert_not_called()

    def test_template_refresh_failure_keeps_full_preview_and_disables_fast_path(self):
        coordinator = self.coordinator()
        coordinator._fast_fingerprint = "old"
        process_result = playground_server.BuildResult(
            succeeded=True,
            duration_ms=100,
            log="built",
            diagnostics=[],
            mode="full",
        )

        with tempfile.TemporaryDirectory() as temporary_directory, mock.patch.object(
            playground_server,
            "STAGING_BUNDLE",
            Path(temporary_directory) / "Bundle",
        ), mock.patch.object(
            coordinator,
            "_discard_staging",
        ), mock.patch.object(
            coordinator,
            "_run_process",
            return_value=process_result,
        ), mock.patch.object(
            coordinator,
            "_verify_bundle",
            return_value=True,
        ), mock.patch.object(
            coordinator,
            "_refresh_fast_template",
            side_effect=OSError("disk full"),
        ):
            result = coordinator._run_full_build("cache changed")

        self.assertTrue(result.succeeded)
        self.assertEqual(result.mode, "full")
        self.assertEqual(result.fallback_reason, "cache changed")
        self.assertIn("Fast Preview is unavailable", result.log)
        self.assertIsNone(coordinator._fast_fingerprint)

    def test_javascriptkit_source_uses_full_packaging(self):
        coordinator = self.coordinator()
        coordinator._fast_fingerprint = "ready"
        sources = (
            "@preconcurrency import JavaScriptKit\nstruct ContentView {}\n",
            "import struct JavaScriptKit.JSObject\nstruct ContentView {}\n",
            "@JSFunction func callback() {}\n",
        )

        for source in sources:
            with self.subTest(source=source):
                reason = coordinator._fast_build_unavailable_reason(source)
                self.assertEqual(reason, "ContentView changes JavaScriptKit packaging")


if __name__ == "__main__":
    unittest.main()
