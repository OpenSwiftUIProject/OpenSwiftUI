const playground = document.querySelector("#playground");
const editorElement = document.querySelector("#source-editor");
const runButton = document.querySelector("[data-testid='run-button']");
const resetButton = document.querySelector("[data-testid='reset-source-button']");
const defaultSource = document.querySelector("#default-content-view")?.textContent.trim();
const buildStatus = document.querySelector("[data-testid='build-status']");
const previewStatus = document.querySelector("[data-testid='preview-status']");
const previewRevision = document.querySelector("[data-testid='preview-revision']");
const previewStack = document.querySelector("[data-testid='preview-stack']");
const emptyPreview = document.querySelector("[data-testid='empty-preview']");
const diagnosticSummary = document.querySelector("[data-testid='diagnostic-summary']");
const diagnosticList = document.querySelector("[data-testid='diagnostics']");
const buildLogContainer = document.querySelector("[data-testid='build-log-container']");
const buildLog = document.querySelector("[data-testid='build-log']");

function makeSourceEditor(element) {
  window.ace.config.set("basePath", "/vendor/ace");
  const instance = window.ace.edit(element);
  const Range = window.ace.require("ace/range").Range;
  let isSettingValue = false;

  instance.setOptions({
    enableKeyboardAccessibility: true,
    fontSize: "13px",
    highlightActiveLine: true,
    highlightGutterLine: true,
    printMargin: false,
    scrollPastEnd: 0.35,
    showFoldWidgets: true,
    showLineNumbers: true,
    tabSize: 4,
    textInputAriaLabel: "ContentView.swift source",
    useSoftTabs: true,
    wrap: false,
  });
  instance.renderer.setPadding(22);
  instance.renderer.setScrollMargin(20, 40);
  instance.session.setUseWorker(false);
  instance.session.setMode("ace/mode/swift6");
  instance.setTheme("ace/theme/one_dark");
  element.dataset.editorLanguage = "swift";

  return {
    getValue() {
      return instance.getValue();
    },

    setValue(value) {
      isSettingValue = true;
      try {
        instance.setValue(value, -1);
        instance.clearSelection();
      } finally {
        isSettingValue = false;
      }
    },

    focus() {
      instance.focus();
    },

    selectOffsets(start, end) {
      const document = instance.session.getDocument();
      const startPosition = document.indexToPosition(start, 0);
      const endPosition = document.indexToPosition(end, 0);
      instance.selection.setRange(new Range(
        startPosition.row,
        startPosition.column,
        endPosition.row,
        endPosition.column
      ));
      instance.scrollToLine(startPosition.row, true, true);
    },

    setDisabled(disabled) {
      instance.setReadOnly(disabled);
      element.dataset.disabled = String(disabled);
      element.setAttribute("aria-disabled", String(disabled));
    },

    onChange(handler) {
      instance.session.on("change", () => {
        if (!isSettingValue) {
          handler();
        }
      });
    },

    addRunCommand(handler) {
      instance.commands.addCommand({
        name: "runOpenSwiftUIPlayground",
        bindKey: { mac: "Command-Enter", win: "Ctrl-Enter" },
        exec: handler,
      });
    },
  };
}

const editor = makeSourceEditor(editorElement);

const state = {
  token: "",
  sourceRevision: 0,
  lastSubmittedSource: "",
  autoBuildTimer: null,
  putInFlight: false,
  putBaseRevision: null,
  sourceConflict: false,
  saveFailed: false,
  submitAgain: false,
  forceAgain: false,
  deferredEvent: null,
  eventSource: null,
  eventConnection: "connecting",
  buildStatusLabel: "",
  lastBuildEvent: null,
  statusPollTimer: null,
  statusPollInFlight: false,
  activeFrame: null,
  activeRevision: null,
  candidateFrame: null,
  candidateRevision: null,
  candidateTimer: null,
  previewFailure: null,
};

function setBuildStatus(status, label) {
  playground.dataset.buildStatus = status;
  state.buildStatusLabel = label;
  renderConnectionStatus();
}

function renderConnectionStatus() {
  playground.dataset.buildConnection = state.eventConnection;
  buildStatus.textContent = state.buildStatusLabel
    + (state.eventConnection === "reconnecting" ? " · reconnecting status…" : "");
}

function setPreviewStatus(status, label) {
  playground.dataset.previewStatus = status;
  previewStatus.textContent = label;
}

function setSourceRevision(revision) {
  state.sourceRevision = Number(revision);
  playground.dataset.sourceRevision = String(revision);
}

function formatDuration(milliseconds) {
  if (!Number.isFinite(milliseconds)) {
    return "";
  }
  return milliseconds < 1000
    ? `${milliseconds} ms`
    : `${(milliseconds / 1000).toFixed(1)} s`;
}

function sourceOffsetAt(line, column) {
  const lines = editor.getValue().split("\n");
  const safeLine = Math.max(1, Math.min(Number(line) || 1, lines.length));
  let offset = 0;
  for (let index = 0; index < safeLine - 1; index += 1) {
    offset += lines[index].length + 1;
  }
  return offset + Math.max(0, Math.min((Number(column) || 1) - 1, lines[safeLine - 1].length));
}

function revealDiagnostic(diagnostic) {
  if (!diagnostic.editable || !diagnostic.line) {
    return;
  }
  const start = sourceOffsetAt(diagnostic.line, diagnostic.column);
  const source = editor.getValue();
  const lineEnd = source.indexOf("\n", start);
  editor.focus();
  editor.selectOffsets(start, lineEnd === -1 ? source.length : lineEnd);
}

function renderDiagnostics(diagnostics = [], rawLog = "") {
  diagnosticList.replaceChildren();
  playground.dataset.diagnosticCount = String(diagnostics.length);
  diagnosticSummary.textContent = diagnostics.length === 0
    ? "No problems"
    : `${diagnostics.length} problem${diagnostics.length === 1 ? "" : "s"}`;

  for (const diagnostic of diagnostics) {
    const item = document.createElement("li");
    const button = document.createElement("button");
    const severity = document.createElement("span");
    const message = document.createElement("span");
    const location = document.createElement("span");

    button.type = "button";
    button.className = "diagnostic-button";
    button.dataset.severity = diagnostic.severity ?? "error";
    button.dataset.editable = String(Boolean(diagnostic.editable));
    button.addEventListener("click", () => revealDiagnostic(diagnostic));

    severity.className = "diagnostic-severity";
    severity.textContent = diagnostic.severity ?? "error";
    message.className = "diagnostic-message";
    message.textContent = diagnostic.message ?? "Unknown build error";
    location.className = "diagnostic-location";
    if (diagnostic.file) {
      const suffix = diagnostic.line
        ? `:${diagnostic.line}${diagnostic.column ? `:${diagnostic.column}` : ""}`
        : "";
      location.textContent = ` — ${diagnostic.file}${suffix}`;
      message.append(location);
    }

    button.append(severity, message);
    item.append(button);
    diagnosticList.append(item);
  }

  buildLog.textContent = rawLog;
  buildLogContainer.hidden = rawLog.length === 0;
  if (rawLog.length === 0) {
    buildLogContainer.open = false;
  }
}

function scheduleAutoBuild() {
  window.clearTimeout(state.autoBuildTimer);
  state.autoBuildTimer = window.setTimeout(() => submitSource(false), 700);
}

async function submitSource(force) {
  window.clearTimeout(state.autoBuildTimer);
  if (state.putInFlight) {
    state.submitAgain = true;
    state.forceAgain ||= force;
    return;
  }

  const source = editor.getValue();
  if (!force && source === state.lastSubmittedSource) {
    // Reverting an edit may reveal a result received while the editor was dirty.
    // Restore its status without reloading a preview that already failed at runtime.
    if (!state.sourceConflict && !state.saveFailed
      && Number(state.lastBuildEvent?.revision) === state.sourceRevision) {
      renderBuildResult(state.lastBuildEvent);
    }
    return;
  }

  state.putInFlight = true;
  state.putBaseRevision = state.sourceRevision;
  runButton.disabled = true;
  setBuildStatus("queued", "Saving…");
  try {
    const response = await fetch("/api/source", {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
        "X-Playground-Token": state.token,
      },
      body: JSON.stringify({
        source,
        baseRevision: state.sourceRevision,
      }),
    });
    const payload = await response.json();
    if (response.status === 409) {
      state.sourceConflict = true;
      renderDiagnostics([{
        severity: "error",
        message: "The source changed in another playground tab. Reload before running again.",
        editable: false,
      }]);
      setBuildStatus("failed", `Revision conflict (server r${payload.revision})`);
      return;
    }
    if (!response.ok) {
      throw new Error(payload.error ?? `HTTP ${response.status}`);
    }
    setSourceRevision(payload.revision);
    state.sourceConflict = false;
    state.saveFailed = false;
    state.lastSubmittedSource = source;
    state.lastBuildEvent = { revision: payload.revision, state: "queued" };
    renderDiagnostics();
    setBuildStatus("queued", `Queued r${payload.revision}`);
    if (editor.getValue() !== source) {
      state.submitAgain = true;
    }
    if (state.deferredEvent) {
      const deferredEvent = state.deferredEvent;
      state.deferredEvent = null;
      handleBuildEvent(deferredEvent);
    }
  } catch (error) {
    state.saveFailed = true;
    setBuildStatus("disconnected", "Save failed");
    renderDiagnostics([{
      severity: "error",
      message: String(error),
      editable: false,
    }]);
  } finally {
    state.putInFlight = false;
    state.putBaseRevision = null;
    runButton.disabled = false;
    if (state.submitAgain) {
      const forceNext = state.forceAgain;
      state.submitAgain = false;
      state.forceAgain = false;
      window.setTimeout(() => submitSource(forceNext), 0);
    }
  }
}

function clearCandidate() {
  window.clearTimeout(state.candidateTimer);
  state.candidateTimer = null;
  state.candidateFrame?.remove();
  state.candidateFrame = null;
  state.candidateRevision = null;
}

function reportPreviewFailure(message) {
  state.previewFailure = { revision: state.candidateRevision, message };
  clearCandidate();
  setPreviewStatus(state.activeFrame ? "ready" : "empty", state.activeFrame ? "Last good preview" : "Preview failed");
  setBuildStatus("failed", "Preview failed");
  renderDiagnostics([{
    severity: "error",
    message,
    editable: false,
  }]);
}

function loadPreview(revision, previewURL) {
  const numericRevision = Number(revision);
  const expectedURL = `/preview.html?revision=${numericRevision}`;
  if (!Number.isSafeInteger(numericRevision) || numericRevision < 1 || previewURL !== expectedURL) {
    return;
  }
  if (
    (state.activeRevision !== null && numericRevision <= state.activeRevision)
    || (state.candidateRevision !== null && numericRevision <= state.candidateRevision)
  ) {
    return;
  }

  clearCandidate();
  const frame = document.createElement("iframe");
  frame.dataset.testid = "preview-frame";
  frame.dataset.previewRole = "candidate";
  frame.dataset.previewRevision = String(numericRevision);
  frame.title = `OpenSwiftUI Preview revision ${numericRevision}`;
  frame.setAttribute("sandbox", "allow-scripts allow-same-origin");
  frame.setAttribute(
    "allow",
    "camera 'none'; microphone 'none'; geolocation 'none'; clipboard-read 'none'; clipboard-write 'none'"
  );
  frame.referrerPolicy = "no-referrer";
  state.candidateFrame = frame;
  state.candidateRevision = numericRevision;
  previewStack.append(frame);
  frame.src = expectedURL;
  setPreviewStatus("loading", `Loading r${numericRevision}…`);
  state.candidateTimer = window.setTimeout(() => {
    if (state.candidateFrame === frame) {
      reportPreviewFailure(`Preview r${numericRevision} did not become ready within 90 seconds.`);
    }
  }, 90_000);
}

function activateCandidate() {
  const frame = state.candidateFrame;
  const revision = state.candidateRevision;
  if (!frame || revision === null) {
    return;
  }
  window.clearTimeout(state.candidateTimer);
  state.candidateTimer = null;
  const oldFrame = state.activeFrame;
  if (oldFrame) {
    oldFrame.dataset.previewRole = "retiring";
  }
  frame.dataset.previewRole = "active";
  state.activeFrame = frame;
  state.activeRevision = revision;
  state.candidateFrame = null;
  state.candidateRevision = null;
  playground.dataset.previewRevision = String(revision);
  previewRevision.textContent = `Revision ${revision}`;
  emptyPreview.hidden = true;
  setPreviewStatus("ready", "Ready");
  window.setTimeout(() => oldFrame?.remove(), 180);
}

function isNewerBuildEvent(payload, previous) {
  if (!previous || Number(payload.revision) !== Number(previous.revision)) {
    return !previous || Number(payload.revision) > Number(previous.revision);
  }
  const phase = { idle: 0, queued: 1, building: 2, ready: 3, failed: 3 };
  return phase[payload.state] > phase[previous.state];
}

function handleBuildEvent(payload) {
  const revision = Number(payload.revision);
  if (!Number.isSafeInteger(revision)
    || !["idle", "queued", "building", "ready", "failed"].includes(payload.state)) {
    return;
  }
  if (revision > state.sourceRevision && state.putInFlight) {
    if (isNewerBuildEvent(payload, state.deferredEvent)) {
      state.deferredEvent = payload;
    }
    return;
  }
  if (state.putInFlight && revision === state.putBaseRevision) {
    return;
  }
  if (revision !== state.sourceRevision) {
    if (revision > state.sourceRevision) {
      state.sourceConflict = true;
      setBuildStatus("failed", `Newer source exists (r${revision})`);
    }
    return;
  }
  // A delayed polling response or SSE replay must not replace a terminal result
  // with Queued, or retry a failed preview iframe for the same revision.
  if (!isNewerBuildEvent(payload, state.lastBuildEvent)) {
    return;
  }
  state.lastBuildEvent = payload;
  if (payload.readyRevision != null && payload.readyPreviewURL) {
    loadPreview(Number(payload.readyRevision), payload.readyPreviewURL);
  }
  if (state.sourceConflict || state.saveFailed
    || editor.getValue() !== state.lastSubmittedSource) {
    return;
  }
  renderBuildResult(payload);
}

function renderBuildResult(payload) {
  const revision = Number(payload.revision);
  switch (payload.state) {
  case "queued":
    setBuildStatus("queued", `Queued r${revision}`);
    break;
  case "building":
    setBuildStatus("building", `Building r${revision}…`);
    break;
  case "ready": {
    if (state.previewFailure?.revision === revision) {
      setBuildStatus("failed", "Preview failed");
      renderDiagnostics([{
        severity: "error",
        message: state.previewFailure.message,
        editable: false,
      }]);
      break;
    }
    const duration = formatDuration(Number(payload.durationMS));
    const mode = payload.buildMode === "fast" ? "Fast Preview" : "Full build";
    setBuildStatus("ready", duration ? `${mode} in ${duration}` : `Ready r${revision}`);
    renderDiagnostics();
    break;
  }
  case "failed": {
    const duration = formatDuration(Number(payload.durationMS));
    const mode = payload.buildMode === "fast" ? "Fast Preview" : "Build";
    setBuildStatus("failed", duration ? `${mode} failed after ${duration}` : `Failed r${revision}`);
    renderDiagnostics(payload.diagnostics ?? [], payload.log ?? "");
    break;
  }
  default:
    break;
  }
}

function scheduleStatusPoll(delay = 2000) {
  window.clearTimeout(state.statusPollTimer);
  state.statusPollTimer = window.setTimeout(reconcileBuildStatus, delay);
}

async function reconcileBuildStatus() {
  if (state.statusPollInFlight) {
    return;
  }
  const isBuilding = ["queued", "building"].includes(state.lastBuildEvent?.state)
    || playground.dataset.buildStatus === "queued";
  if (state.putInFlight || (!isBuilding && state.eventConnection === "connected")) {
    scheduleStatusPoll();
    return;
  }
  state.statusPollInFlight = true;
  const controller = new AbortController();
  const timeout = window.setTimeout(() => controller.abort(), 5000);
  try {
    const response = await fetch("/api/source", {
      cache: "no-store",
      signal: controller.signal,
    });
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    const payload = await response.json();
    // Reconcile build state only: never replace unsaved editor text, the PUT
    // base revision, or the session token with an asynchronous polling result.
    handleBuildEvent(payload.build);
    if (state.eventSource?.readyState === EventSource.CLOSED) {
      connectEvents();
    }
  } catch (error) {
    state.eventConnection = "reconnecting";
    renderConnectionStatus();
  } finally {
    window.clearTimeout(timeout);
    state.statusPollInFlight = false;
    scheduleStatusPoll();
  }
}

function connectEvents() {
  state.eventSource?.close();
  const eventSource = new EventSource("/api/events");
  state.eventSource = eventSource;
  eventSource.addEventListener("open", () => {
    state.eventConnection = "connected";
    renderConnectionStatus();
  });
  eventSource.addEventListener("message", (event) => {
    try {
      state.eventConnection = "connected";
      renderConnectionStatus();
      handleBuildEvent(JSON.parse(event.data));
    } catch (error) {
      console.error("Invalid playground event", error);
    }
  });
  eventSource.addEventListener("error", () => {
    state.eventConnection = "reconnecting";
    renderConnectionStatus();
    scheduleStatusPoll(0);
  });
}

window.addEventListener("message", (event) => {
  const frame = state.candidateFrame;
  const message = event.data;
  if (
    event.origin !== window.location.origin
    || !frame
    || event.source !== frame.contentWindow
    || message?.scope !== "openswiftui-playground"
    || Number(message.revision) !== state.candidateRevision
  ) {
    return;
  }
  if (message.type === "preview-ready") {
    activateCandidate();
  } else if (message.type === "preview-failed") {
    reportPreviewFailure(message.message ?? "The preview failed to initialize.");
  }
});

editor.onChange(() => {
  setBuildStatus("dirty", "Unsaved changes");
  scheduleAutoBuild();
});

editor.addRunCommand(() => submitSource(true));

runButton.addEventListener("click", () => submitSource(true));

resetButton.addEventListener("click", () => {
  if (!state.token || !defaultSource) {
    return;
  }
  const source = `${defaultSource}\n`;
  if (editor.getValue() !== source) {
    if (!window.confirm("Replace the current ContentView with the default example?")) {
      return;
    }
    editor.setValue(source);
  }
  submitSource(true);
});

async function bootstrap() {
  setBuildStatus("idle", "Connecting…");
  try {
    const response = await fetch("/api/source", { cache: "no-store" });
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    const payload = await response.json();
    state.token = payload.token;
    editor.setValue(payload.source);
    state.lastSubmittedSource = payload.source;
    setSourceRevision(payload.revision);
    handleBuildEvent(payload.build);
    resetButton.disabled = !defaultSource;
    connectEvents();
    scheduleStatusPoll();
  } catch (error) {
    editor.setDisabled(true);
    runButton.disabled = true;
    setBuildStatus("disconnected", "Build service unavailable");
    renderDiagnostics([{
      severity: "error",
      message: `Start playground_server.py before opening this page: ${String(error)}`,
      editable: false,
    }]);
  }
}

bootstrap();
