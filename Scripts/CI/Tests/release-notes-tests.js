const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const test = require("node:test");
const { parseMetadata, resolveTitle, updateReleaseNotes, validateTheme } = require("../release-notes.js");

const version = "0.23.0";
const repository = "OpenSwiftUIProject/OpenSwiftUI";
const changelog = "## What's Changed\n* Add a feature by @contributor in #123\n";
const metadata = { theme: "Gesture Support", highlights: ["Add gesture support on iOS and macOS"] };

function fixture(t, { title = version, response = JSON.stringify(metadata), failure } = {}) {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "openswiftui-release-notes-"));
  t.after(() => fs.rmSync(directory, { recursive: true, force: true }));
  const calls = [];
  const warnings = [];
  const updates = [];
  const run = (command, args) => {
    calls.push({ command, args });
    if (command === "npm" || command === "copilot") {
      if (failure === command) throw new Error("Command failed");
      return command === "copilot" ? response : "";
    }
    assert.equal(command, "gh");
    if (args[0] === "release" && args[1] === "view") return JSON.stringify({ name: title });
    if (args[0] === "api") {
      assert.ok(args.includes("repos/OpenSwiftUIProject/OpenSwiftUI/releases/generate-notes"));
      assert.ok(args.includes("tag_name=0.23.0"));
      if (failure === "changelog") throw new Error("GitHub is unavailable");
      return changelog;
    }
    assert.deepEqual(args.slice(0, 3), ["release", "edit", version]);
    if (failure === "update") throw new Error("GitHub rejected the update");
    updates.push({
      title: args[args.indexOf("--title") + 1],
      body: fs.readFileSync(args[args.indexOf("--notes-file") + 1], "utf8"),
    });
    return "";
  };
  return {
    calls, warnings, updates,
    options: { version, repository, directory, hasCopilotToken: true, run, warn: message => warnings.push(message) },
  };
}

test("release themes accept plain text and reject invalid title fragments", () => {
  assert.equal(validateTheme("  Gesture Support  "), "Gesture Support");
  assert.equal(validateTheme('Text "Quotes" & $(touch sentinel)'), 'Text "Quotes" & $(touch sentinel)');
  for (const value of [undefined, null, 12, "", "  ", "Line\nBreak", "Tab\tCharacter", "Carriage\rReturn", "Control\u0000", "Unicode\u2028Break", "0.23.0: Gesture Support", "v0.23.0 Gesture Support", "OpenSwiftUI 0.23.0: Gesture Support"]) {
    assert.throws(() => validateTheme(value), /theme/i);
  }
});

test("Copilot metadata must be valid JSON with a theme and zero to five plain bullets", () => {
  assert.deepEqual(parseMetadata(JSON.stringify(metadata)), metadata);
  assert.deepEqual(parseMetadata('{"theme":"CI Regression Fix","highlights":[]}'), { theme: "CI Regression Fix", highlights: [] });
  for (const value of [
    "", "```json\n{}\n```", "null", "[]", "{}",
    JSON.stringify({ ...metadata, theme: " " }),
    JSON.stringify({ ...metadata, theme: "Line\nBreak" }),
    JSON.stringify({ ...metadata, highlights: "Add support" }),
    JSON.stringify({ ...metadata, highlights: ["Add support\n## Extra"] }),
    JSON.stringify({ ...metadata, highlights: [""] }),
    JSON.stringify({ ...metadata, highlights: ["- Add support"] }),
    JSON.stringify({ ...metadata, highlights: Array(6).fill("Add support") }),
  ]) assert.throws(() => parseMetadata(value));
});

test("title selection prefers an override and preserves curated titles on reruns", () => {
  const currentTitle = "0.23.0: Curated Theme";
  assert.equal(resolveTitle({ version, currentTitle, theme: "Manual Theme", generatedTheme: "Generated Theme" }), "0.23.0: Manual Theme");
  assert.equal(resolveTitle({ version, currentTitle, generatedTheme: "Generated Theme" }), currentTitle);
  for (const title of ["", version, "v0.23.0", "OpenSwiftUI 0.23.0"]) {
    assert.equal(resolveTitle({ version, currentTitle: title, generatedTheme: "Gesture Support" }), "0.23.0: Gesture Support");
  }
  assert.equal(resolveTitle({ version, currentTitle: version }), version);
  assert.throws(() => resolveTitle({ version, currentTitle, theme: " " }), /theme/i);
});

test("notes and title are updated together after one Copilot request", t => {
  const { options, calls, updates, warnings } = fixture(t);
  updateReleaseNotes(options);
  assert.equal(calls.filter(call => call.command === "copilot").length, 1);
  assert.equal(updates.length, 1);
  assert.equal(updates[0].title, "0.23.0: Gesture Support");
  assert.ok(updates[0].body.startsWith("## Highlights\n\n- Add gesture support on iOS and macOS\n\n"));
  assert.ok(updates[0].body.includes(changelog));
  assert.match(updates[0].body, /## Binary Integration/);
  assert.ok(updates[0].body.includes('.package(url: "https://github.com/OpenSwiftUIProject/OpenSwiftUI-spm.git", from: "0.23.0")'));
  assert.equal(warnings.length, 0);
  const edit = calls.at(-1).args;
  assert.deepEqual(edit.slice(0, 7), ["release", "edit", "0.23.0", "--repo", repository, "--title", "0.23.0: Gesture Support"]);
});

test("manual themes remain literal arguments without Copilot credentials", t => {
  const { options, calls, updates, warnings } = fixture(t);
  const theme = 'Text "Quotes" & $(touch sentinel)';
  updateReleaseNotes({ ...options, theme, hasCopilotToken: false });
  assert.equal(updates[0].title, '0.23.0: Text "Quotes" & $(touch sentinel)');
  assert.ok(calls.every(call => call.command === "gh"));
  assert.equal(warnings.length, 1);
  assert.doesNotMatch(updates[0].body, /## Highlights/);
});

for (const scenario of [
  { name: "missing credentials", hasCopilotToken: false },
  { name: "failed setup", failure: "npm" },
  { name: "failed generation", failure: "copilot" },
  { name: "malformed output", response: "not JSON" },
  { name: "an invalid theme", response: '{"theme":"Line\\nBreak","highlights":[]}' },
]) {
  test(scenario.name + " keeps the title and still updates the changelog", t => {
    const { options, updates, warnings } = fixture(t, { ...scenario, title: "0.23.0: Curated Theme" });
    updateReleaseNotes({ ...options, hasCopilotToken: scenario.hasCopilotToken ?? true });
    assert.equal(updates[0].title, "0.23.0: Curated Theme");
    assert.ok(updates[0].body.includes(changelog));
    assert.match(updates[0].body, /## Binary Integration/);
    assert.doesNotMatch(updates[0].body, /## Highlights/);
    assert.equal(warnings.length, 1);
  });
}

test("invalid manual themes fail before any GitHub or Copilot command", t => {
  const { options, calls } = fixture(t);
  assert.throws(() => updateReleaseNotes({ ...options, theme: "Line\nBreak" }), /theme/i);
  assert.equal(calls.length, 0);
});

test("successful regeneration keeps the curated title and refreshes highlights", t => {
  const { options, updates } = fixture(t, { title: "0.23.0: Curated Theme" });
  updateReleaseNotes(options);
  assert.equal(updates[0].title, "0.23.0: Curated Theme");
  assert.match(updates[0].body, /## Highlights/);
});

test("a maintenance theme can have no user-facing highlights", t => {
  const { options, updates } = fixture(t, { response: '{"theme":"CI Regression Fix","highlights":[]}' });
  updateReleaseNotes(options);
  assert.equal(updates[0].title, "0.23.0: CI Regression Fix");
  assert.doesNotMatch(updates[0].body, /## Highlights/);
});

test("GitHub failures stop the workflow instead of using the Copilot fallback", t => {
  for (const failure of ["changelog", "update"]) {
    const { options, warnings, updates } = fixture(t, { failure });
    assert.throws(() => updateReleaseNotes(options), /GitHub/);
    assert.equal(warnings.length, 0);
    assert.equal(updates.length, 0);
  }
});
