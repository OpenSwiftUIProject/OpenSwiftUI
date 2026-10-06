const assert = require("node:assert/strict");
const { spawnSync } = require("node:child_process");
const fs = require("node:fs/promises");
const os = require("node:os");
const path = require("node:path");
const test = require("node:test");

async function check(t, output, status = 0) {
  const directory = await fs.mkdtemp(path.join(os.tmpdir(), "framework dependencies-"));
  t.after(() => fs.rm(directory, { recursive: true, force: true }));
  const fixture = path.join(directory, "otool.txt");
  await fs.writeFile(fixture, output);
  await fs.writeFile(path.join(directory, "otool"), `#!/bin/bash
set -euo pipefail
[[ "$1" == -L && "$2" == "$TEST_BINARY" ]]
cat "$TEST_OTOOL_OUTPUT"
exit "$TEST_OTOOL_STATUS"
`, { mode: 0o755 });
  const binary = path.join(directory, "Client.framework/Versions/A/Client");
  return spawnSync("bash", [path.join(__dirname, "../check_framework_dependencies.sh"), binary], {
    encoding: "utf8",
    env: {
      ...process.env, PATH: `${directory}${path.delimiter}${process.env.PATH}`,
      TEST_BINARY: binary, TEST_OTOOL_OUTPUT: fixture, TEST_OTOOL_STATUS: String(status),
    },
  });
}

function loadCommands(dependencies, architecture = "arm64") {
  const entries = dependencies.map((dependency, index) =>
    `\t${dependency} (compatibility version ${index + 2}.3.4, current version ${index + 5}.6.7)`);
  return `Client (architecture ${architecture}):\n${entries.join("\n")}\n`;
}

test("runtime paths accept new libraries and arbitrary framework and compatibility versions", async t => {
  const result = await check(t, loadCommands([
    "@rpath/FutureKit.framework/FutureKit",
    "@rpath/AnotherKit.framework/Versions/B/AnotherKit",
    "@rpath/Library With Spaces.framework/Versions/Current/Library With Spaces",
    "/System/Library/Frameworks/SystemKit.framework/Versions/C/SystemKit",
    "/System/Library/PrivateFrameworks/PrivateKit.framework/PrivateKit",
    "/usr/lib/libExample.2.dylib",
    "/usr/lib/swift/libExample.dylib",
    "@rpath/libFuture.9.dylib",
  ]));
  assert.equal(result.status, 0, result.stderr);
});

for (const dependency of [
  "/tmp/build/Local.framework/Versions/A/Local",
  "/usr/local/lib/libLocal.dylib",
  "@loader_path/Local.framework/Local",
  "relative/Local.framework/Local",
  "@rpath/Local",
  "@rpath/Local.framework",
  "@rpath/libLocal.dylib/Local",
]) {
  test(`an unsupported path in any architecture fails: ${dependency}`, async t => {
    const result = await check(t,
      loadCommands(["@rpath/Client.framework/Client"], "x86_64") +
      loadCommands(["@rpath/Client.framework/Client", dependency]));
    assert.equal(result.status, 1);
    assert.ok(result.stderr.includes(`unsupported runtime dependency: ${dependency}`), result.stderr);
  });
}

test("static archives without dynamic dependencies pass", async t => {
  const result = await check(t, "Archive : Client\nClient(Support.o):\n");
  assert.equal(result.status, 0, result.stderr);
});

test("an inspection failure cannot pass dependency validation", async t => {
  const result = await check(t, "", 1);
  assert.equal(result.status, 1);
  assert.match(result.stderr, /Could not inspect framework dependencies/);
});
