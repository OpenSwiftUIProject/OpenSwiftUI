const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");
const vm = require("node:vm");

const script = fs.readFileSync(path.join(__dirname, "..", "playground.js"), "utf8");
const response = (payload, status = 200) => ({
  ok: status >= 200 && status < 300,
  status,
  json: async () => payload,
});
const snapshot = (state, revision = 7) => ({ revision, state, diagnostics: [], log: "" });

function deferred() {
  let resolve;
  let reject;
  const promise = new Promise((yes, no) => { resolve = yes; reject = no; });
  return { promise, resolve, reject };
}

async function playground() {
  const elements = new Map();
  const timers = new Map();
  const sources = [];
  let timerID = 0;
  let text = "original source";
  let change;
  const element = () => ({
    dataset: {}, textContent: "", hidden: false, contentWindow: {},
    setAttribute() {}, addEventListener() {}, append() {}, replaceChildren() {}, remove() {},
  });
  const editor = {
    renderer: { setPadding() {}, setScrollMargin() {} },
    session: { setUseWorker() {}, setMode() {}, on(_, callback) { change = callback; } },
    commands: { addCommand() {} },
    setOptions() {}, setTheme() {}, clearSelection() {}, setReadOnly() {},
    setValue(value) { text = value; change?.(); },
    getValue() { return text; },
  };
  class EventSource {
    static CONNECTING = 0;
    static OPEN = 1;
    static CLOSED = 2;
    constructor() {
      this.readyState = EventSource.CONNECTING;
      this.listeners = {};
      sources.push(this);
    }
    addEventListener(type, callback) { this.listeners[type] = callback; }
    close() { this.readyState = EventSource.CLOSED; }
  }
  const context = vm.createContext({
    console, AbortController, EventSource,
    document: {
      querySelector(selector) {
        if (!elements.has(selector)) elements.set(selector, element());
        return elements.get(selector);
      },
      createElement: element,
    },
    window: {
      ace: { config: { set() {} }, edit: () => editor, require: () => ({ Range: class {} }) },
      addEventListener() {}, location: { origin: "http://localhost:8000" },
      setTimeout(callback, delay) {
        timers.set(++timerID, { callback, delay });
        return timerID;
      },
      clearTimeout(id) { timers.delete(id); },
    },
    fetch: async () => response({
      source: text, token: "token", revision: 7, build: snapshot("queued"),
    }),
  });
  const run = (code) => vm.runInContext(code, context);
  vm.runInContext(script, context);
  await new Promise(setImmediate);
  return {
    context, run, timers, sources,
    status: () => elements.get("#playground").dataset.buildStatus,
    label: () => elements.get("[data-testid='build-status']").textContent,
    source: () => text,
    edit(value) { editor.setValue(value); },
    event(payload) { sources.at(-1).listeners.message({ data: JSON.stringify(payload) }); },
    open() {
      sources.at(-1).readyState = EventSource.OPEN;
      sources.at(-1).listeners.open();
    },
    disconnect() {
      sources.at(-1).readyState = EventSource.CONNECTING;
      sources.at(-1).listeners.error();
    },
  };
}

test("initial connecting or lost SSE is recovered by status polling", async () => {
  const page = await playground();
  page.context.fetch = async () => response({
    source: "must not replace editor", revision: 7, token: "different token",
    build: { ...snapshot("failed"), log: "compile error", diagnostics: [{ message: "missing argument" }] },
  });
  await page.run("reconcileBuildStatus()");
  assert.equal(page.status(), "failed");
  assert.equal(page.source(), "original source");
  assert.equal(page.run("state.token"), "token");
  assert.equal(page.run("buildLog.textContent"), "compile error");
  assert.equal(page.run("diagnosticSummary.textContent"), "1 problem");
});

test("reconnecting SSE is visible without hiding the terminal result", async () => {
  const page = await playground();
  page.event(snapshot("failed"));
  page.disconnect();
  assert.equal(page.status(), "failed");
  assert.match(page.label(), /reconnecting status/);
  page.open();
  assert.equal(page.status(), "failed");
  assert.doesNotMatch(page.label(), /reconnecting/);
});

test("late poll and SSE replay cannot regress a failed result to queued", async () => {
  const page = await playground();
  page.open();
  const pending = deferred();
  page.context.fetch = () => pending.promise;
  const poll = page.run("reconcileBuildStatus()");
  page.event(snapshot("failed"));
  pending.resolve(response({ build: snapshot("queued") }));
  await poll;
  page.event(snapshot("building"));
  assert.equal(page.status(), "failed");
});

test("PUT race preserves the newest deferred result and saving state", async () => {
  const page = await playground();
  page.edit("edited source");
  const pending = deferred();
  page.context.fetch = () => pending.promise;
  const put = page.run("submitSource(true)");
  page.event(snapshot("building", 7));
  assert.equal(page.label(), "Saving…");
  page.event(snapshot("failed", 8));
  page.event(snapshot("queued", 8));
  pending.resolve(response({ revision: 8, state: "queued" }));
  await put;
  assert.equal(page.status(), "failed");
  assert.equal(page.run("state.sourceRevision"), 8);
  assert.equal(page.source(), "edited source");
});

test("polling preserves dirty text and its unsaved label", async () => {
  const page = await playground();
  page.edit("not submitted yet");
  page.context.fetch = async () => response({ source: "server source", build: snapshot("failed") });
  await page.run("reconcileBuildStatus()");
  assert.equal(page.source(), "not submitted yet");
  assert.equal(page.status(), "dirty");
  assert.equal(page.run("state.sourceRevision"), 7);
});

test("reverting an unsaved edit restores the terminal result received while dirty", async () => {
  const page = await playground();
  page.edit("not submitted yet");
  page.event({ ...snapshot("failed"), log: "missing parameter" });
  assert.equal(page.status(), "dirty");
  page.edit("original source");
  page.context.fetch = () => { throw new Error("reverting must not submit a build"); };
  await page.run("submitSource(false)");
  assert.equal(page.status(), "failed");
  assert.equal(page.run("buildLog.textContent"), "missing parameter");
});

test("old status cannot erase a newer-source conflict", async () => {
  const page = await playground();
  page.event(snapshot("queued", 8));
  page.context.fetch = async () => response({ build: snapshot("building", 7) });
  await page.run("reconcileBuildStatus()");
  assert.equal(page.status(), "failed");
  assert.match(page.label(), /Newer source exists/);
});

test("polling is single-flight and times out without dropping its next attempt", async () => {
  const page = await playground();
  let requests = 0;
  page.context.fetch = (_, { signal }) => {
    requests += 1;
    return new Promise((_, reject) => signal.addEventListener("abort", () => reject(new Error("aborted"))));
  };
  const first = page.run("reconcileBuildStatus()");
  await page.run("reconcileBuildStatus()");
  assert.equal(requests, 1);
  const timeout = [...page.timers.values()].find((timer) => timer.delay === 5000);
  timeout.callback();
  await first;
  assert.equal(page.run("state.statusPollInFlight"), false);
  assert.match(page.label(), /reconnecting status/);
  assert.ok([...page.timers.values()].some((timer) => timer.delay === 2000));
});

test("duplicate ready snapshots do not retry a failed preview iframe", async () => {
  const page = await playground();
  const ready = { ...snapshot("ready"), readyRevision: 7, readyPreviewURL: "/preview.html?revision=7" };
  page.event(ready);
  assert.equal(page.run("state.candidateRevision"), 7);
  page.run('reportPreviewFailure("runtime error")');
  page.event(ready);
  assert.equal(page.run("state.candidateRevision"), null);
  assert.equal(page.status(), "failed");
  page.edit("temporary edit");
  page.edit("original source");
  await page.run("submitSource(false)");
  assert.equal(page.run("state.candidateRevision"), null);
  assert.equal(page.status(), "failed");
  assert.equal(page.label(), "Preview failed");
});
