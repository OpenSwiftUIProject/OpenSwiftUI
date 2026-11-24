const start = document.querySelector("#start");
const status = document.querySelector("#status");
const results = document.querySelector("#results");
const details = document.querySelector("#details");
const preview = document.querySelector("#preview");
const delay = (milliseconds) => new Promise((resolve) => setTimeout(resolve, milliseconds));

let nextPointerID = 100;

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

async function waitUntil(predicate, message, timeout = 3000) {
  const deadline = performance.now() + timeout;
  do {
    if (predicate()) return;
    await delay(20);
  } while (performance.now() < deadline);
  throw new Error(message);
}

function canvas() {
  return preview.contentDocument.querySelector("#canvas");
}

function counter(label = "Tap count") {
  const prefix = `${label}: `;
  const text = canvas()?.dataset.renderedText?.split("|").find((entry) => entry.startsWith(prefix));
  const value = text?.slice(prefix.length);
  assert(value !== undefined && /^\d+$/.test(value), `The Preview must contain ‘${label}: N’`);
  return Number(value);
}

function target(label = "Tap count") {
  const commands = JSON.parse(canvas().dataset.textCommandSummary ?? "[]");
  const command = commands.find((entry) => entry.text === `${label}: ${counter(label)}`);
  assert(command, `The renderer did not report the ${label} text bounds`);
  return { x: command.x + command.width / 2, y: command.y + command.height / 2 };
}

function clientPoint(point) {
  const element = canvas();
  const rect = element.getBoundingClientRect();
  const style = preview.contentWindow.getComputedStyle(element);
  const pixels = (property) => Number.parseFloat(style[property]) || 0;
  const left = pixels("borderLeftWidth") + pixels("paddingLeft");
  const top = pixels("borderTopWidth") + pixels("paddingTop");
  const horizontal = left + pixels("borderRightWidth") + pixels("paddingRight");
  const vertical = top + pixels("borderBottomWidth") + pixels("paddingBottom");
  const width = pixels("width") - (style.boxSizing === "border-box" ? horizontal : 0);
  const height = pixels("height") - (style.boxSizing === "border-box" ? vertical : 0);
  // The default demo's logical surface is fixed in ExampleApp/App.swift.
  return {
    x: rect.left + (left + point.x * width / 720) * rect.width / (width + horizontal),
    y: rect.top + (top + point.y * height / 480) * rect.height / (height + vertical),
  };
}

function emit(type, pointerID, point, options = {}) {
  const coordinates = options.clientPoint ?? clientPoint(point);
  const button = options.button ?? 0;
  const released = type === "pointerup" || type === "pointercancel" || type === "lostpointercapture";
  canvas().dispatchEvent(new preview.contentWindow.PointerEvent(type, {
    bubbles: true,
    cancelable: true,
    pointerId: pointerID,
    pointerType: options.pointerType ?? "mouse",
    isPrimary: options.isPrimary ?? true,
    button,
    buttons: released ? 0 : button === 2 ? 2 : 1,
    clientX: coordinates.x,
    clientY: coordinates.y,
  }));
}

function tap(options = {}) {
  const pointerID = options.pointerID ?? ++nextPointerID;
  const point = target(options.label);
  emit("pointerdown", pointerID, point, options);
  emit("pointerup", pointerID, point, options);
}

async function increments(action, label = "Tap count") {
  const before = counter(label);
  await action();
  await waitUntil(() => counter(label) === before + 1, `Expected ${label}: ${before + 1}, got ${counter(label)}`);
  await delay(80);
  assert(counter(label) === before + 1, "One pointer sequence invoked the callback more than once");
}

async function unchanged(action, label = "Tap count") {
  const before = counter(label);
  await action();
  await delay(120);
  assert(counter(label) === before, `Unexpected callback: ${label} changed from ${before} to ${counter(label)}`);
}

const tests = [
  ["Mouse tap updates State and redraws", () => increments(() => tap())],
  ["A second tap starts a fresh gesture", () => increments(() => tap())],
  ["Unrelated background does not hit the counter", () => unchanged(() => {
    const id = ++nextPointerID;
    emit("pointerdown", id, { x: 10, y: 10 });
    emit("pointerup", id, { x: 10, y: 10 });
  })],
  ["The padded background participates in Core hit testing", () => increments(() => {
    const command = JSON.parse(canvas().dataset.textCommandSummary).find((entry) => /^Tap count:/.test(entry.text));
    const point = { x: command.x - 5, y: command.y + command.height / 2 };
    const id = ++nextPointerID;
    emit("pointerdown", id, point);
    emit("pointerup", id, point);
  })],
  ["pointercancel does not invoke onEnded", () => unchanged(() => {
    const id = ++nextPointerID;
    const point = target();
    emit("pointerdown", id, point);
    emit("pointercancel", id, point);
    emit("pointerup", id, point);
  })],
  ["Lost pointer capture cancels recognition", () => unchanged(() => {
    const id = ++nextPointerID;
    const point = target();
    emit("pointerdown", id, point);
    emit("lostpointercapture", id, point);
    emit("pointerup", id, point);
  })],
  ["Movement greater than 45 logical points rejects a tap", () => unchanged(() => {
    const id = ++nextPointerID;
    const point = target();
    const moved = { x: point.x + 60, y: point.y };
    emit("pointerdown", id, point);
    emit("pointermove", id, moved);
    emit("pointerup", id, moved);
  })],
  ["Holding longer than 0.75 seconds rejects a tap", () => unchanged(async () => {
    const id = ++nextPointerID;
    const point = target();
    emit("pointerdown", id, point);
    await delay(850);
    emit("pointerup", id, point);
  })],
  ["Secondary mouse button does not trigger the primary tap", () => unchanged(() => tap({ button: 2 }))],
  ["Blur cancels a pointer and the next tap still works", async () => {
    await unchanged(() => {
      const id = ++nextPointerID;
      const point = target();
      emit("pointerdown", id, point);
      preview.contentWindow.dispatchEvent(new preview.contentWindow.Event("blur"));
      emit("pointerup", id, point);
    });
    await increments(() => tap());
  }],
  ["Orphan movement and release events are ignored", () => unchanged(() => {
    const id = ++nextPointerID;
    const point = target();
    const before = canvas().dataset.webPointerEventCount;
    emit("pointermove", id, point);
    emit("pointerup", id, point);
    assert(canvas().dataset.webPointerEventCount === before, "Orphan events reached Core");
  })],
  ["A touch tap uses the shared gesture graph", () => increments(() => tap({ pointerType: "touch" }))],
  ["A pen tap uses the shared gesture graph", () => increments(() => tap({ pointerType: "pen" }))],
  ["Overlapping touches do not become a one-finger tap", () => unchanged(() => {
    const first = ++nextPointerID;
    const second = ++nextPointerID;
    const point = target();
    const options = { pointerType: "touch" };
    emit("pointerdown", first, point, options);
    emit("pointerdown", second, point, { ...options, isPrimary: false });
    emit("pointerup", second, point, { ...options, isPrimary: false });
    emit("pointerup", first, point, options);
  })],
  ["CSS scaling, fractional borders and padding preserve logical coordinates", async () => {
    const element = canvas();
    const savedStyle = element.getAttribute("style");
    try {
      element.style.cssText += ";width:720px!important;height:480px!important;max-width:none;box-sizing:content-box;border:7.5px solid transparent;padding:3.25px;transform:scale(0.5);transform-origin:top left";
      const point = target();
      const rect = element.getBoundingClientRect();
      const leftBorder = Number.parseFloat(preview.contentWindow.getComputedStyle(element).borderLeftWidth);
      const topBorder = Number.parseFloat(preview.contentWindow.getComputedStyle(element).borderTopWidth);
      // Construct a known 720x480 content-box case independently of the adapter.
      const coordinates = {
        x: rect.left + (leftBorder + 3.25 + point.x) * 0.5,
        y: rect.top + (topBorder + 3.25 + point.y) * 0.5,
      };
      await increments(() => tap({ clientPoint: coordinates }));
      assert(Math.abs(Number(element.dataset.lastPointerX) - point.x) < 0.01, "Scaled x was not in logical surface coordinates");
      assert(Math.abs(Number(element.dataset.lastPointerY) - point.y) < 0.01, "Scaled y was not in logical surface coordinates");
    } finally {
      if (savedStyle === null) element.removeAttribute("style");
      else element.setAttribute("style", savedStyle);
    }
  }],
  ["The generic .gesture(TapGesture().onEnded) API updates State", () => increments(
    () => tap({ label: "Gesture taps" }), "Gesture taps"
  )],
  ["A double tap waits for the second tap before invoking its callback", () => increments(async () => {
    const before = counter("Double taps");
    tap({ label: "Double taps" });
    await delay(75);
    assert(counter("Double taps") === before, "The first tap prematurely completed a double tap");
    tap({ label: "Double taps" });
  }, "Double taps")],
  ["Reusing a mouse pointer ID supports repeated taps and a double tap", async () => {
    const pointerID = ++nextPointerID;
    await increments(() => tap({ pointerID }));
    await increments(() => tap({ pointerID }));
    await increments(async () => {
      const before = counter("Double taps");
      tap({ pointerID, label: "Double taps" });
      await delay(75);
      assert(counter("Double taps") === before, "Reusing the pointer ID prematurely completed a double tap");
      tap({ pointerID, label: "Double taps" });
    }, "Double taps");
  }],
  ["Blur cancels a pending double tap after its first pointer has ended", () => increments(async () => {
    const before = counter("Double taps");
    tap({ label: "Double taps" });
    await delay(60);
    assert(canvas().dataset.activePointerCount === "0", "The first tap did not release its pointer");
    preview.contentWindow.dispatchEvent(new preview.contentWindow.Event("blur"));
    await delay(20);
    tap({ label: "Double taps" });
    await delay(75);
    assert(counter("Double taps") === before, "The post-blur tap completed the cancelled pair");
    tap({ label: "Double taps" });
  }, "Double taps")],
  ["An expired double tap does not complete, and a fresh pair recovers", async () => {
    await unchanged(async () => {
      const before = counter("Double taps");
      tap({ label: "Double taps" });
      await delay(450);
      assert(counter("Double taps") === before, "An incomplete double tap fired during its timeout");
      tap({ label: "Double taps" });
    }, "Double taps");
    // The later tap starts a fresh pending pair; let that pair expire too.
    await delay(450);
    await increments(async () => {
      tap({ label: "Double taps" });
      await delay(75);
      tap({ label: "Double taps" });
    }, "Double taps");
  }],
];

start.addEventListener("click", async () => {
  start.disabled = true;
  results.replaceChildren();
  details.textContent = "";
  document.documentElement.dataset.gestureSmokeStatus = "running";
  status.textContent = "Loading the actual WASM Preview…";
  let passed = 0;
  try {
    const url = new URL("../preview.html", import.meta.url);
    const revision = new URLSearchParams(location.search).get("revision");
    if (revision !== null) {
      assert(/^[1-9]\d*$/.test(revision), "revision must be a positive integer");
      url.searchParams.set("revision", revision);
    }
    url.searchParams.set("gestureSmoke", String(Date.now()));
    preview.src = url.href;
    await waitUntil(() => {
      const document = preview.contentDocument;
      if (document?.URL !== url.href) return false;
      const state = document?.documentElement.dataset.webRendererStatus;
      if (state === "failed") throw new Error(document.documentElement.dataset.webRendererError);
      return state === "ready" && canvas()?.dataset.webInput === "pointer";
    }, "Preview did not become ready with the PointerEvent bridge", 60000);
    counter();
    for (const [name, run] of tests) {
      const row = document.createElement("li");
      row.textContent = `${name} — running`;
      results.append(row);
      status.textContent = `Running ${passed + 1}/${tests.length}`;
      try {
        await run();
        assert(canvas().dataset.activePointerCount === "0", "The test leaked an active pointer");
        passed += 1;
        row.dataset.result = "passed";
        row.textContent = `${name} — PASS`;
        console.info(`[Web gesture smoke] PASS ${name}`);
      } catch (error) {
        row.dataset.result = "failed";
        row.textContent = `${name} — FAIL`;
        throw error;
      }
    }
    status.textContent = `${passed}/${tests.length} passed`;
    document.documentElement.dataset.gestureSmokeStatus = "passed";
  } catch (error) {
    status.textContent = `Failed after ${passed}/${tests.length} passed`;
    details.textContent = String(error?.stack ?? error);
    document.documentElement.dataset.gestureSmokeStatus = "failed";
    console.error("[Web gesture smoke]", error);
  } finally {
    document.documentElement.dataset.gestureSmokePassed = String(passed);
    document.documentElement.dataset.gestureSmokeTotal = String(tests.length);
    start.disabled = false;
  }
});
