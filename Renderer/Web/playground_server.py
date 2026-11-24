#!/usr/bin/env python3

"""Local build coordinator and HTTP server for the Web renderer playground."""

import argparse
import hashlib
import hmac
import json
import mimetypes
import os
import re
import secrets
import shutil
import signal
import subprocess
import sys
import tempfile
import threading
import time
from dataclasses import dataclass
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple
from urllib.parse import unquote, urlsplit

from serialized_diagnostics import recover_errors


ROOT = Path(__file__).resolve().parent
SOURCE_PATH = ROOT / "ExampleApp" / "ContentView.swift"
BUILD_SCRIPT = ROOT / "build-example.sh"
PREVIEW_ROOT = ROOT / ".preview"
STAGING_BUNDLE = PREVIEW_ROOT / "staging" / "Bundle"
BUILDS_ROOT = PREVIEW_ROOT / "builds"
FAST_TEMPLATE = PREVIEW_ROOT / "fast-template"
DRAFT_PATH = PREVIEW_ROOT / "draft.swift"
REVISION_PATH = PREVIEW_ROOT / "revision.txt"
ACE_ROOT = ROOT / "node_modules" / "ace-builds" / "src-min-noconflict"
FAST_MANIFEST = ROOT / ".build" / "plugin-tools.yaml"
FAST_DATABASE = ROOT / ".build" / "build.db"
FAST_WASM = ROOT / ".build" / "wasm32-unknown-wasip1" / "debug" / "ExampleApp.wasm"

MAX_SOURCE_BYTES = 256 * 1024
MAX_LOG_CHARACTERS = 256 * 1024
MAX_DIAGNOSTICS = 100
BUILD_TIMEOUT_SECONDS = 10 * 60
PREVIEW_HISTORY_LIMIT = 3

REQUIRED_BUNDLE_FILES = (
    "index.js",
    "instantiate.js",
    "runtime.js",
    "platforms/browser.js",
    "ExampleApp.wasm",
)

STATIC_FILES = {
    "/": ROOT / "index.html",
    "/index.html": ROOT / "index.html",
    "/playground.css": ROOT / "playground.css",
    "/playground.js": ROOT / "playground.js",
    "/swift6-mode.js": ROOT / "swift6-mode.js",
    "/preview.html": ROOT / "preview.html",
    "/preview.js": ROOT / "preview.js",
    "/vendor/ace/ace.js": ACE_ROOT / "ace.js",
    "/vendor/ace/mode-swift.js": ACE_ROOT / "mode-swift.js",
    "/vendor/ace/theme-one_dark.js": ACE_ROOT / "theme-one_dark.js",
}

FRONTEND_DEPENDENCY_FILES = tuple(
    path for url, path in STATIC_FILES.items() if url.startswith("/vendor/")
)

ANSI_ESCAPE_PATTERN = re.compile(r"\x1b(?:\[[0-?]*[ -/]*[@-~]|\][^\x07]*(?:\x07|\x1b\\))")
DIAGNOSTIC_PATTERN = re.compile(
    r"^(.*?\.(?:swift|c|cc|cpp|cxx|h|hh|hpp|hxx|m|mm)):"
    r"(\d+):(\d+):\s+(fatal error|error|warning|note):\s+(.*)$"
)
GLOBAL_DIAGNOSTIC_PATTERN = re.compile(
    r"^(?:([^\s:]+):\s+)?(fatal error|error|warning):\s+(.*)$"
)
BUILD_PATH_PATTERN = re.compile(r"^/builds/([1-9]\d*)/(.+)$")
PACKAGE_TO_JS_SOURCE_PATTERN = re.compile(
    r"\b(?:JavaScriptKit|JavaScriptEventLoop|JavaScriptBigIntSupport)\b|@JS\w*"
)


@dataclass(frozen=True)
class SourceSnapshot:
    revision: int
    source: str


@dataclass(frozen=True)
class BuildResult:
    succeeded: bool
    duration_ms: int
    log: str
    diagnostics: List[Dict[str, Any]]
    mode: str = "full"
    fallback_reason: Optional[str] = None
    cancelled: bool = False


def atomic_write(path: Path, value: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary_path = tempfile.mkstemp(
        prefix=".{}-".format(path.name),
        dir=str(path.parent),
    )
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8", newline="") as stream:
            stream.write(value)
            stream.flush()
            os.fsync(stream.fileno())
        os.chmod(temporary_path, 0o644)
        os.replace(temporary_path, str(path))
    except BaseException:
        try:
            os.unlink(temporary_path)
        except FileNotFoundError:
            pass
        raise


def clean_log(raw_log: str, truncate: bool = True) -> str:
    value = ANSI_ESCAPE_PATTERN.sub("", raw_log)
    value = "".join(
        character
        for character in value
        if character in "\n\r\t" or ord(character) >= 32
    )
    if not truncate or len(value) <= MAX_LOG_CHARACTERS:
        return value
    head_length = MAX_LOG_CHARACTERS // 4
    tail_length = MAX_LOG_CHARACTERS - head_length
    return "{}\n\n… build log truncated …\n\n{}".format(
        value[:head_length],
        value[-tail_length:],
    )


def diagnostic_log_lines(log: str) -> List[str]:
    """Return ordinary lines plus diagnostics nested in Swift parseable output."""
    lines: List[str] = []
    decoder = json.JSONDecoder()
    consumed = 0
    search_cursor = 0
    while search_cursor < len(log):
        object_start = log.find("{", search_cursor)
        if object_start < 0:
            break
        try:
            message, object_end = decoder.raw_decode(log, object_start)
        except (TypeError, ValueError):
            search_cursor = object_start + 1
            continue
        lines.extend(log[consumed:object_start].splitlines())
        consumed = object_end
        search_cursor = object_end
        if not isinstance(message, dict):
            continue
        output = message.get("output")
        if isinstance(output, str):
            lines.extend(output.splitlines())
    lines.extend(log[consumed:].splitlines())
    return lines


def display_path(raw_path: str) -> str:
    candidate = Path(raw_path)
    if not candidate.is_absolute():
        candidate = ROOT / candidate
    try:
        return str(candidate.resolve().relative_to(ROOT))
    except (OSError, ValueError):
        return candidate.name or raw_path


def parse_diagnostics(log: str) -> List[Dict[str, Any]]:
    diagnostics: List[Dict[str, Any]] = []
    seen = set()
    for line in diagnostic_log_lines(log):
        match = DIAGNOSTIC_PATTERN.match(line)
        if match:
            raw_path, line_number, column, severity, message = match.groups()
            item = {
                "file": display_path(raw_path),
                "line": int(line_number),
                "column": int(column),
                "severity": severity,
                "message": message,
                "editable": (
                    (Path(raw_path) if Path(raw_path).is_absolute() else ROOT / raw_path).resolve()
                    == SOURCE_PATH.resolve()
                ),
            }
        else:
            match = GLOBAL_DIAGNOSTIC_PATTERN.match(line)
            if not match:
                continue
            tool, severity, message = match.groups()
            if tool:
                message = "{}: {}".format(tool, message)
            item = {
                "file": None,
                "line": None,
                "column": None,
                "severity": severity,
                "message": message,
                "editable": False,
            }
        if item["severity"] == "fatal error":
            item["severity"] = "error"
        key = (
            item["file"],
            item["line"],
            item["column"],
            item["severity"],
            item["message"],
        )
        if key in seen:
            continue
        seen.add(key)
        diagnostics.append(item)
    # Long warning lists must not hide the error that actually stopped a build.
    priority = {"error": 0, "warning": 1, "note": 2}
    diagnostics.sort(key=lambda item: priority[item["severity"]])
    return diagnostics[:MAX_DIAGNOSTICS]


class EventBroker:
    def __init__(self) -> None:
        self._condition = threading.Condition()
        self._event_id = 0
        self._payload: Dict[str, Any] = {}
        self._closed = False

    def publish(self, payload: Dict[str, Any]) -> None:
        with self._condition:
            self._event_id += 1
            self._payload = dict(payload)
            self._condition.notify_all()

    def wait(self, after_event_id: int, timeout: float) -> Optional[Tuple[int, Dict[str, Any]]]:
        with self._condition:
            if self._event_id <= after_event_id and not self._closed:
                self._condition.wait(timeout)
            if self._event_id > after_event_id:
                return self._event_id, dict(self._payload)
            return None

    @property
    def closed(self) -> bool:
        with self._condition:
            return self._closed

    def close(self) -> None:
        with self._condition:
            self._closed = True
            self._condition.notify_all()


class BuildCoordinator:
    def __init__(self) -> None:
        self.events = EventBroker()
        self.token = secrets.token_urlsafe(24)
        self._condition = threading.Condition(threading.RLock())
        self._stopping = False
        self._process: Optional[subprocess.Popen] = None
        self._process_mode: Optional[str] = None
        self._pending: Optional[SourceSnapshot] = None
        self._revision = self._load_last_revision()
        self._source = self._load_initial_source()
        self._ready_revision: Optional[int] = None
        self._fast_build_tool = self._find_fast_build_tool()
        self._fast_fingerprint: Optional[str] = None
        self._state = self._payload_locked("idle", self._revision)
        self._worker = threading.Thread(
            target=self._worker_loop,
            name="OpenSwiftUIPlaygroundBuild",
            daemon=True,
        )

    def _load_initial_source(self) -> str:
        source = SOURCE_PATH.read_text(encoding="utf-8")
        if not DRAFT_PATH.exists():
            return source
        try:
            if DRAFT_PATH.stat().st_mtime_ns > SOURCE_PATH.stat().st_mtime_ns:
                return DRAFT_PATH.read_text(encoding="utf-8")
            DRAFT_PATH.unlink()
        except OSError:
            pass
        return source

    def _load_last_revision(self) -> int:
        candidates = [0]
        try:
            candidates.append(int(REVISION_PATH.read_text(encoding="utf-8").strip()))
        except (FileNotFoundError, OSError, ValueError):
            pass
        try:
            candidates.extend(
                int(path.name)
                for path in BUILDS_ROOT.iterdir()
                if path.is_dir() and path.name.isdigit()
            )
        except (FileNotFoundError, OSError):
            pass
        return max(candidates)

    def _allocate_revision_locked(self) -> int:
        self._revision += 1
        atomic_write(REVISION_PATH, "{}\n".format(self._revision))
        return self._revision

    def _payload_locked(
        self,
        state: str,
        revision: int,
        diagnostics: Optional[List[Dict[str, Any]]] = None,
        log: str = "",
        duration_ms: Optional[int] = None,
        build_mode: Optional[str] = None,
        fallback_reason: Optional[str] = None,
    ) -> Dict[str, Any]:
        payload: Dict[str, Any] = {
            "revision": revision,
            "state": state,
            "readyRevision": self._ready_revision,
            "readyPreviewURL": (
                "/preview.html?revision={}".format(self._ready_revision)
                if self._ready_revision is not None
                else None
            ),
            "diagnostics": diagnostics or [],
            "log": log,
        }
        if duration_ms is not None:
            payload["durationMS"] = duration_ms
        if build_mode is not None:
            payload["buildMode"] = build_mode
        if fallback_reason is not None:
            payload["fallbackReason"] = fallback_reason
        return payload

    def _set_state_locked(self, payload: Dict[str, Any]) -> None:
        self._state = payload
        self.events.publish(payload)

    def start(self) -> None:
        self._worker.start()
        with self._condition:
            revision = self._allocate_revision_locked()
            self._pending = SourceSnapshot(revision, self._source)
            self._set_state_locked(self._payload_locked("queued", revision))
            self._condition.notify_all()

    def stop(self) -> None:
        process: Optional[subprocess.Popen]
        with self._condition:
            self._stopping = True
            process = self._process
            self._condition.notify_all()
        if process is not None and process.poll() is None:
            self._terminate_process(process)
        self.events.close()
        self._worker.join(timeout=10.0)

    def source_response(self) -> Dict[str, Any]:
        with self._condition:
            return {
                "source": self._source,
                "revision": self._revision,
                "token": self.token,
                "build": dict(self._state),
            }

    def submit(self, source: str, base_revision: int) -> Tuple[bool, Dict[str, Any]]:
        process_to_cancel: Optional[subprocess.Popen] = None
        with self._condition:
            if base_revision != self._revision:
                return False, {
                    "error": "revision_conflict",
                    "source": self._source,
                    "revision": self._revision,
                }
            atomic_write(DRAFT_PATH, source)
            revision = self._allocate_revision_locked()
            self._source = source
            self._pending = SourceSnapshot(revision, source)
            if self._process_mode == "fast":
                process_to_cancel = self._process
            self._set_state_locked(self._payload_locked("queued", revision))
            self._condition.notify_all()
        if process_to_cancel is not None:
            self._cancel_fast_process(process_to_cancel)
        return True, {"revision": revision, "state": "queued"}

    def _worker_loop(self) -> None:
        while True:
            with self._condition:
                while self._pending is None and not self._stopping:
                    self._condition.wait()
                if self._stopping:
                    return
                snapshot = self._pending
                self._pending = None
                if snapshot is None or snapshot.revision != self._revision:
                    continue

            try:
                atomic_write(SOURCE_PATH, snapshot.source)
            except OSError as error:
                log = clean_log("error: failed to update ContentView.swift: {}\n".format(error))
                with self._condition:
                    if snapshot.revision == self._revision:
                        self._set_state_locked(
                            self._payload_locked(
                                "failed",
                                snapshot.revision,
                                parse_diagnostics(log),
                                log,
                            )
                        )
                continue
            with self._condition:
                if snapshot.revision == self._revision:
                    try:
                        DRAFT_PATH.unlink()
                    except FileNotFoundError:
                        pass
                    self._set_state_locked(self._payload_locked("building", snapshot.revision))

            try:
                result = self._run_build(snapshot)
            except (OSError, subprocess.SubprocessError) as error:
                log = clean_log("error: failed to start the SwiftWASM build: {}\n".format(error))
                result = BuildResult(
                    succeeded=False,
                    duration_ms=0,
                    log=log,
                    diagnostics=parse_diagnostics(log),
                    mode="full",
                )

            published = False
            with self._condition:
                if self._stopping:
                    return
                if snapshot.revision != self._revision:
                    self._discard_staging()
                    continue
                if result.succeeded:
                    try:
                        self._publish(snapshot.revision)
                    except OSError as error:
                        log = clean_log("{}\nerror: failed to publish preview: {}\n".format(result.log, error))
                        self._set_state_locked(
                            self._payload_locked(
                                "failed",
                                snapshot.revision,
                                parse_diagnostics(log),
                                log,
                                result.duration_ms,
                            )
                        )
                        continue
                    self._ready_revision = snapshot.revision
                    published = True
                    self._set_state_locked(
                        self._payload_locked(
                            "ready",
                            snapshot.revision,
                            duration_ms=result.duration_ms,
                            build_mode=result.mode,
                            fallback_reason=result.fallback_reason,
                        )
                    )
                else:
                    self._discard_staging()
                    self._set_state_locked(
                        self._payload_locked(
                            "failed",
                            snapshot.revision,
                            result.diagnostics,
                            result.log,
                            result.duration_ms,
                            build_mode=result.mode,
                            fallback_reason=result.fallback_reason,
                        )
                    )

            if published:
                self._prune_builds()

    def _run_build(self, snapshot: SourceSnapshot) -> BuildResult:
        try:
            reason = self._fast_build_unavailable_reason(snapshot.source)
        except OSError as error:
            reason = "Fast Preview cache validation failed: {}".format(error)
        if reason is not None:
            return self._run_full_build(reason if self._fast_fingerprint is not None else None)

        try:
            result = self._run_fast_build(snapshot.revision)
        except (OSError, subprocess.SubprocessError) as error:
            if not self._is_current_revision(snapshot.revision):
                return self._cancelled_result("fast")
            reason = "fast preview infrastructure failed: {}".format(error)
            return self._run_full_build(reason)

        has_source_error = any(
            diagnostic.get("severity") == "error" and bool(diagnostic.get("file"))
            for diagnostic in result.diagnostics
        )
        if result.succeeded or result.cancelled or has_source_error:
            return result
        if not self._is_current_revision(snapshot.revision):
            return self._cancelled_result("fast")
        return self._run_full_build("fast preview command failed without Swift diagnostics")

    def _run_full_build(self, fallback_reason: Optional[str] = None) -> BuildResult:
        self._discard_staging()
        STAGING_BUNDLE.parent.mkdir(parents=True, exist_ok=True)
        result = self._run_process(
            [str(BUILD_SCRIPT), str(STAGING_BUNDLE)],
            "full",
            fallback_reason,
        )
        succeeded = result.succeeded and self._verify_bundle(STAGING_BUNDLE)
        log = result.log
        diagnostics = result.diagnostics
        if result.succeeded and not succeeded:
            log = clean_log("{}\nerror: build completed without a complete browser bundle\n".format(log))
            diagnostics = parse_diagnostics(log)
        if succeeded:
            try:
                self._refresh_fast_template(STAGING_BUNDLE)
            except OSError as error:
                self._fast_fingerprint = None
                warning = "warning: Fast Preview is unavailable until the next full build: {}\n".format(
                    error,
                )
                log = clean_log("{}\n{}".format(log, warning))
                diagnostics = (diagnostics + parse_diagnostics(warning))[:MAX_DIAGNOSTICS]
        return BuildResult(
            succeeded=succeeded,
            duration_ms=result.duration_ms,
            log=log,
            diagnostics=diagnostics,
            mode="full",
            fallback_reason=fallback_reason,
        )

    def _run_fast_build(self, revision: int) -> BuildResult:
        if self._fast_build_tool is None:
            raise OSError("swift-build-tool is unavailable")
        self._discard_staging()
        result = self._run_process(
            [
                str(self._fast_build_tool),
                "-f",
                str(FAST_MANIFEST),
                "--db",
                str(FAST_DATABASE),
                "main",
            ],
            "fast",
        )
        if not result.succeeded:
            return result
        if not self._is_current_revision(revision):
            return self._cancelled_result("fast", result.duration_ms)
        if not FAST_WASM.is_file() or FAST_WASM.stat().st_size == 0:
            raise OSError("Fast Preview completed without ExampleApp.wasm")
        self._assemble_fast_bundle()
        if not self._verify_bundle(STAGING_BUNDLE):
            raise OSError("Fast Preview assembled an incomplete browser bundle")
        return result

    def _run_process(
        self,
        arguments: List[str],
        mode: str,
        fallback_reason: Optional[str] = None,
    ) -> BuildResult:
        started = time.monotonic()
        started_ns = time.time_ns()
        process = subprocess.Popen(
            arguments,
            cwd=str(ROOT),
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            universal_newlines=True,
            encoding="utf-8",
            errors="replace",
            start_new_session=True,
        )
        with self._condition:
            self._process = process
            self._process_mode = mode
        timed_out = False
        try:
            output, _ = process.communicate(timeout=BUILD_TIMEOUT_SECONDS)
        except subprocess.TimeoutExpired:
            timed_out = True
            self._terminate_process(process)
            output, _ = process.communicate()
        finally:
            with self._condition:
                if self._process is process:
                    self._process = None
                    self._process_mode = None

        duration_ms = int((time.monotonic() - started) * 1000.0)
        if timed_out:
            output = "{}\nerror: build timed out after {} seconds\n".format(
                output,
                BUILD_TIMEOUT_SECONDS,
            )
        elif process.returncode > 0:
            # SwiftPM can emit only "emit-module failed" while preserving the
            # actual compiler errors in serialized diagnostics, not stdout.
            recovered = recover_errors(
                FAST_WASM.parent,
                started_ns,
                self._fast_build_tool or self._find_fast_build_tool(),
            )
            if recovered:
                output += "\n" + "\n".join(recovered) + "\n"
        diagnostic_log = clean_log(output, truncate=False)
        log = clean_log(diagnostic_log)
        return BuildResult(
            succeeded=not timed_out and process.returncode == 0,
            duration_ms=duration_ms,
            log=log,
            diagnostics=parse_diagnostics(diagnostic_log),
            mode=mode,
            fallback_reason=fallback_reason,
        )

    def _fast_build_unavailable_reason(self, source: str) -> Optional[str]:
        if self._fast_fingerprint is None:
            return "Fast Preview requires a successful full build"
        if PACKAGE_TO_JS_SOURCE_PATTERN.search(source):
            return "ContentView changes JavaScriptKit packaging"
        required_paths = (
            FAST_MANIFEST,
            FAST_DATABASE,
            FAST_WASM,
            FAST_TEMPLATE,
        )
        if self._fast_build_tool is None or any(not path.exists() for path in required_paths):
            return "Fast Preview cache is incomplete"
        if not self._verify_fast_template(FAST_TEMPLATE):
            return "Fast Preview bundle template is incomplete"
        if self._structural_fingerprint() != self._fast_fingerprint:
            return "the package or Preview runtime changed"
        return None

    def _refresh_fast_template(self, bundle: Path) -> None:
        PREVIEW_ROOT.mkdir(parents=True, exist_ok=True)
        temporary: Optional[Path] = Path(
            tempfile.mkdtemp(prefix=".fast-template-", dir=str(PREVIEW_ROOT))
        )
        try:
            def ignore_wasm(directory: str, names: List[str]) -> List[str]:
                if Path(directory).resolve() == bundle.resolve() and "ExampleApp.wasm" in names:
                    return ["ExampleApp.wasm"]
                return []

            assert temporary is not None
            shutil.copytree(str(bundle), str(temporary), dirs_exist_ok=True, ignore=ignore_wasm)
            if not self._verify_fast_template(temporary):
                raise OSError("full build did not produce a reusable bundle template")
            if FAST_TEMPLATE.exists():
                shutil.rmtree(str(FAST_TEMPLATE))
            os.rename(str(temporary), str(FAST_TEMPLATE))
            temporary = None
            self._fast_fingerprint = self._structural_fingerprint()
        finally:
            if temporary is not None and temporary.exists():
                shutil.rmtree(str(temporary), ignore_errors=True)

    @staticmethod
    def _assemble_fast_bundle() -> None:
        STAGING_BUNDLE.parent.mkdir(parents=True, exist_ok=True)
        shutil.copytree(str(FAST_TEMPLATE), str(STAGING_BUNDLE))
        shutil.copy2(str(FAST_WASM), str(STAGING_BUNDLE / "ExampleApp.wasm"))

    @staticmethod
    def _verify_fast_template(template: Path) -> bool:
        return all(
            (template / relative_path).is_file()
            and (template / relative_path).stat().st_size > 0
            for relative_path in REQUIRED_BUNDLE_FILES
            if relative_path != "ExampleApp.wasm"
        )

    @staticmethod
    def _find_fast_build_tool() -> Optional[Path]:
        override = os.environ.get("OPENSWIFTUI_WEB_SWIFT_BUILD_TOOL")
        if override:
            candidate = Path(override).expanduser()
            return candidate if candidate.is_file() and os.access(str(candidate), os.X_OK) else None

        release = os.environ.get("OPENSWIFTUI_WEB_SWIFT_RELEASE", "6.3.2")
        candidates = [
            Path.home()
            / "Library"
            / "Developer"
            / "Toolchains"
            / "swift-{}-RELEASE.xctoolchain".format(release)
            / "usr"
            / "bin"
            / "swift-build-tool"
        ]
        path_candidate = shutil.which("swift-build-tool")
        if path_candidate:
            candidates.append(Path(path_candidate))
        for candidate in candidates:
            if candidate.is_file() and os.access(str(candidate), os.X_OK):
                return candidate.resolve()
        return None

    def _structural_fingerprint(self) -> str:
        paths = [
            ROOT / "Package.swift",
            ROOT / "Package.resolved",
            BUILD_SCRIPT,
            ROOT / "ExampleApp" / "App.swift",
            ROOT / "ExampleApp" / "WebRuntime.swift",
            ROOT.parent.parent / "Package.swift",
            ROOT.parent.parent / "Package.resolved",
            FAST_MANIFEST,
        ]
        workspace_root = ROOT.parent.parent.parent
        paths.extend(sorted(workspace_root.glob("*/Package.swift")))
        paths.extend(sorted(workspace_root.glob("*/Package.resolved")))
        digest = hashlib.sha256()
        for path in sorted(set(candidate.resolve() for candidate in paths), key=str):
            digest.update(str(path).encode("utf-8"))
            if path.is_file():
                digest.update(b"\0file\0")
                digest.update(path.read_bytes())
            else:
                digest.update(b"\0missing\0")
        if self._fast_build_tool is not None:
            stat = self._fast_build_tool.stat()
            digest.update(str(self._fast_build_tool).encode("utf-8"))
            digest.update("{}:{}".format(stat.st_size, stat.st_mtime_ns).encode("ascii"))
        for key in (
            "OPENSWIFTUI_WEB_SWIFT_RELEASE",
            "OPENSWIFTUI_WEB_SWIFT_SDK_ID",
            "OPENSWIFTUI_WEB_SWIFT_BUILD_TOOL",
        ):
            digest.update(key.encode("ascii"))
            digest.update(os.environ.get(key, "").encode("utf-8"))
        return digest.hexdigest()

    def _is_current_revision(self, revision: int) -> bool:
        with self._condition:
            return not self._stopping and revision == self._revision

    @staticmethod
    def _cancelled_result(mode: str, duration_ms: int = 0) -> BuildResult:
        return BuildResult(
            succeeded=False,
            duration_ms=duration_ms,
            log="",
            diagnostics=[],
            mode=mode,
            cancelled=True,
        )

    def _cancel_fast_process(self, process: subprocess.Popen) -> None:
        with self._condition:
            if self._process is not process or self._process_mode != "fast":
                return
        if process.poll() is not None:
            return
        try:
            os.killpg(process.pid, signal.SIGINT)
        except ProcessLookupError:
            return

        def escalate() -> None:
            with self._condition:
                is_active = self._process is process and self._process_mode == "fast"
            if is_active and process.poll() is None:
                self._terminate_process(process)

        timer = threading.Timer(1.0, escalate)
        timer.daemon = True
        timer.start()

    @staticmethod
    def _terminate_process(process: subprocess.Popen) -> None:
        try:
            os.killpg(process.pid, signal.SIGTERM)
            process.wait(timeout=5.0)
        except (ProcessLookupError, subprocess.TimeoutExpired):
            try:
                os.killpg(process.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass

    @staticmethod
    def _verify_bundle(bundle: Path) -> bool:
        return all((bundle / relative_path).is_file() and (bundle / relative_path).stat().st_size > 0
                   for relative_path in REQUIRED_BUNDLE_FILES)

    @staticmethod
    def _discard_staging() -> None:
        if STAGING_BUNDLE.exists():
            shutil.rmtree(str(STAGING_BUNDLE))

    @staticmethod
    def _publish(revision: int) -> None:
        BUILDS_ROOT.mkdir(parents=True, exist_ok=True)
        destination = BUILDS_ROOT / str(revision)
        if destination.exists():
            raise OSError("preview revision already exists: {}".format(revision))
        os.rename(str(STAGING_BUNDLE), str(destination))

    def _prune_builds(self) -> None:
        try:
            builds = sorted(
                (path for path in BUILDS_ROOT.iterdir() if path.is_dir() and path.name.isdigit()),
                key=lambda path: int(path.name),
                reverse=True,
            )
        except FileNotFoundError:
            return
        for path in builds[PREVIEW_HISTORY_LIMIT:]:
            shutil.rmtree(str(path), ignore_errors=True)


class PlaygroundHTTPServer(ThreadingHTTPServer):
    daemon_threads = True

    def __init__(self, address: Tuple[str, int], coordinator: BuildCoordinator) -> None:
        self.coordinator = coordinator
        host, port = address
        self.allowed_hosts = {
            "{}:{}".format(host, port),
            "localhost:{}".format(port),
        }
        self.allowed_origins = {
            "http://{}:{}".format(host, port),
            "http://localhost:{}".format(port),
        }
        super().__init__(address, PlaygroundRequestHandler)

    def handle_error(self, request: Any, client_address: Tuple[str, int]) -> None:
        error = sys.exc_info()[1]
        if isinstance(error, (BrokenPipeError, ConnectionResetError)):
            return
        super().handle_error(request, client_address)


class PlaygroundRequestHandler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    server_version = "OpenSwiftUIPlayground/0.1"

    @property
    def playground_server(self) -> PlaygroundHTTPServer:
        return self.server  # type: ignore[return-value]

    def do_GET(self) -> None:
        if not self._valid_host():
            self._send_error(403, "invalid_host")
            return
        path = unquote(urlsplit(self.path).path)
        if path == "/api/source":
            self._send_json(200, self.playground_server.coordinator.source_response())
            return
        if path == "/api/events":
            self._serve_events()
            return
        static_path = STATIC_FILES.get(path)
        if static_path is not None:
            self._serve_file(static_path, immutable=False, document_path=path)
            return
        match = BUILD_PATH_PATTERN.match(path)
        if match:
            self._serve_build_file(match.group(1), match.group(2))
            return
        self._send_error(404, "not_found")

    def do_HEAD(self) -> None:
        if not self._valid_host():
            self._send_head_error(403)
            return
        path = unquote(urlsplit(self.path).path)
        static_path = STATIC_FILES.get(path)
        if static_path is not None:
            self._serve_file(static_path, immutable=False, document_path=path, head_only=True)
            return
        match = BUILD_PATH_PATTERN.match(path)
        if match:
            self._serve_build_file(match.group(1), match.group(2), head_only=True)
            return
        self._send_head_error(404)

    def do_PUT(self) -> None:
        if not self._valid_host():
            self._send_error(403, "invalid_host")
            return
        path = unquote(urlsplit(self.path).path)
        if path != "/api/source":
            self._send_error(404, "not_found")
            return
        if self.headers.get("Origin") not in self.playground_server.allowed_origins:
            self._send_error(403, "invalid_origin")
            return
        token = self.headers.get("X-Playground-Token", "")
        if not hmac.compare_digest(token, self.playground_server.coordinator.token):
            self._send_error(403, "invalid_token")
            return
        if self.headers.get_content_type() != "application/json":
            self._send_error(415, "content_type_must_be_application_json")
            return
        try:
            content_length = int(self.headers.get("Content-Length", ""))
        except ValueError:
            self._send_error(411, "content_length_required")
            return
        if content_length < 0 or content_length > MAX_SOURCE_BYTES:
            self._send_error(413, "source_too_large")
            return
        try:
            body = self.rfile.read(content_length).decode("utf-8", errors="strict")
            request = json.loads(body)
        except (UnicodeDecodeError, json.JSONDecodeError):
            self._send_error(400, "invalid_json")
            return
        if not isinstance(request, dict) or set(request) != {"source", "baseRevision"}:
            self._send_error(400, "expected_source_and_baseRevision")
            return
        source = request.get("source")
        base_revision = request.get("baseRevision")
        if not isinstance(source, str) or "\x00" in source:
            self._send_error(400, "source_must_be_utf8_text")
            return
        if len(source.encode("utf-8")) > MAX_SOURCE_BYTES:
            self._send_error(413, "source_too_large")
            return
        if isinstance(base_revision, bool) or not isinstance(base_revision, int):
            self._send_error(400, "baseRevision_must_be_an_integer")
            return
        accepted, response = self.playground_server.coordinator.submit(source, base_revision)
        self._send_json(202 if accepted else 409, response)

    def do_POST(self) -> None:
        self._method_not_allowed()

    def do_DELETE(self) -> None:
        self._method_not_allowed()

    def _method_not_allowed(self) -> None:
        self.send_response(405)
        self.send_header("Allow", "GET, PUT")
        self.send_header("Content-Length", "0")
        self.end_headers()

    def _valid_host(self) -> bool:
        return self.headers.get("Host", "") in self.playground_server.allowed_hosts

    def _serve_events(self) -> None:
        self.send_response(200)
        self.send_header("Content-Type", "text/event-stream; charset=utf-8")
        self.send_header("Cache-Control", "no-store")
        self.send_header("Connection", "keep-alive")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.end_headers()
        # Build events are complete state snapshots, not deltas. Always replay
        # the current snapshot so a browser reconnect also works after the
        # server restarts and its in-memory event counter resets.
        event_id = 0
        try:
            while not self.playground_server.coordinator.events.closed:
                event = self.playground_server.coordinator.events.wait(event_id, 15.0)
                if event is None:
                    self.wfile.write(b": heartbeat\n\n")
                else:
                    event_id, payload = event
                    data = json.dumps(payload, ensure_ascii=False, separators=(",", ":"))
                    message = "id: {}\ndata: {}\n\n".format(event_id, data).encode("utf-8")
                    self.wfile.write(message)
                self.wfile.flush()
        except (BrokenPipeError, ConnectionResetError, OSError):
            return

    def _serve_build_file(
        self,
        revision: str,
        raw_relative_path: str,
        head_only: bool = False,
    ) -> None:
        if "\\" in raw_relative_path:
            self._send_error(404, "not_found")
            return
        build_root = (BUILDS_ROOT / revision).resolve()
        candidate = (build_root / raw_relative_path).resolve()
        try:
            candidate.relative_to(build_root)
        except ValueError:
            self._send_error(404, "not_found")
            return
        self._serve_file(candidate, immutable=True, head_only=head_only)

    def _serve_file(
        self,
        path: Path,
        immutable: bool,
        document_path: Optional[str] = None,
        head_only: bool = False,
    ) -> None:
        if not path.is_file():
            self._send_error(404, "not_found")
            return
        content_type = {
            ".html": "text/html; charset=utf-8",
            ".css": "text/css; charset=utf-8",
            ".js": "text/javascript; charset=utf-8",
            ".wasm": "application/wasm",
            ".json": "application/json; charset=utf-8",
            ".ts": "text/plain; charset=utf-8",
        }.get(path.suffix, mimetypes.guess_type(str(path))[0] or "application/octet-stream")
        size = path.stat().st_size
        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(size))
        self.send_header(
            "Cache-Control",
            "public, max-age=31536000, immutable" if immutable else "no-store",
        )
        self.send_header("X-Content-Type-Options", "nosniff")
        if document_path in ("/", "/index.html"):
            self.send_header(
                "Content-Security-Policy",
                "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; "
                "connect-src 'self'; frame-src 'self'; img-src 'self' data:; "
                "object-src 'none'; base-uri 'none'",
            )
        elif document_path == "/preview.html":
            self.send_header(
                "Content-Security-Policy",
                "default-src 'none'; script-src 'self' 'wasm-unsafe-eval' https://cdn.jsdelivr.net; "
                "connect-src 'self' https://cdn.jsdelivr.net; style-src 'self' 'unsafe-inline'; "
                "font-src 'self'; img-src data:; object-src 'none'; base-uri 'none'",
            )
        self.end_headers()
        if head_only:
            return
        try:
            with path.open("rb") as stream:
                shutil.copyfileobj(stream, self.wfile, length=1024 * 1024)
        except (BrokenPipeError, ConnectionResetError):
            return

    def _send_json(self, status: int, value: Dict[str, Any]) -> None:
        body = json.dumps(value, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("X-Content-Type-Options", "nosniff")
        if status >= 400:
            self.close_connection = True
            self.send_header("Connection", "close")
        self.end_headers()
        self.wfile.write(body)

    def _send_error(self, status: int, error: str) -> None:
        self._send_json(status, {"error": error})

    def _send_head_error(self, status: int) -> None:
        self.send_response(status)
        self.send_header("Content-Length", "0")
        self.send_header("Cache-Control", "no-store")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.end_headers()

    def log_message(self, format_string: str, *arguments: Any) -> None:
        sys.stderr.write(
            "{} - - [{}] {}\n".format(
                self.client_address[0],
                self.log_date_time_string(),
                format_string % arguments,
            )
        )


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run the OpenSwiftUI Web playground")
    parser.add_argument("--host", choices=("127.0.0.1",), default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8000)
    return parser.parse_args()


def main() -> int:
    arguments = parse_arguments()
    if arguments.port < 1 or arguments.port > 65535:
        print("error: port must be between 1 and 65535", file=sys.stderr)
        return 2
    missing_frontend_dependencies = [
        path for path in FRONTEND_DEPENDENCY_FILES if not path.is_file()
    ]
    if missing_frontend_dependencies:
        print(
            "error: Web Playground frontend dependencies are missing; run npm ci",
            file=sys.stderr,
        )
        return 2

    coordinator = BuildCoordinator()
    server = PlaygroundHTTPServer((arguments.host, arguments.port), coordinator)
    coordinator.start()
    print("OpenSwiftUI Web Playground: http://{}:{}/".format(arguments.host, arguments.port))
    print("Press Control-C to stop.")
    try:
        server.serve_forever(poll_interval=0.25)
    except KeyboardInterrupt:
        print("\nStopping playground…")
    finally:
        server.shutdown()
        server.server_close()
        coordinator.stop()
    return 0


if __name__ == "__main__":
    sys.exit(main())
