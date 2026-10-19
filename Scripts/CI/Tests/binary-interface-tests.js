const assert = require("node:assert/strict");
const { spawnSync } = require("node:child_process");
const fs = require("node:fs/promises");
const os = require("node:os");
const path = require("node:path");
const test = require("node:test");

const frameworks = require("../release.js").frameworks;

async function fixture(t, { missing, buildStatus = 0, consumerStatus = 0, failingPlatform } = {}) {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "binary interface "));
  t.after(() => fs.rm(root, { recursive: true, force: true }));
  const source = path.join(root, "OpenSwiftUI");
  const output = path.join(root, "build");
  const binary = path.join(root, "OpenSwiftUI-spm");
  await fs.mkdir(path.join(source, "Scripts/CI"), { recursive: true });
  await fs.mkdir(path.join(binary, "Example"), { recursive: true });
  await fs.mkdir(path.join(root, "bin"));
  await fs.mkdir(path.join(root, "DarwinPrivateFrameworks/Scripts/XR"), { recursive: true });
  await fs.writeFile(path.join(root, "DarwinPrivateFrameworks/Scripts/XR/install_xr_uikit_overlay.sh"),
    "#!/bin/bash\nexit 0\n", { mode: 0o755 });
  await fs.copyFile(path.join(__dirname, "../check_binary_interface.sh"), path.join(source, "Scripts/CI/check_binary_interface.sh"));
  await fs.writeFile(path.join(source, "Scripts/build_xcframework.sh"), `#!/bin/bash
printf '%s\\n' "$@" > "$TEST_ROOT/build-args"
exit ${buildStatus}
`, { mode: 0o755 });
  await fs.writeFile(path.join(binary, "Example/setup.sh"), "#!/bin/bash\nexit 0\n", { mode: 0o755 });
  await fs.writeFile(path.join(root, "bin/xcodebuild"), `#!/bin/bash
printf '%s\\n' "$@" >> "$TEST_ROOT/consumer-args"
printf '%s' "$OPENSWIFTUI_LOCAL_XCFRAMEWORKS_PATH" > "$TEST_ROOT/local-path"
if [[ "$*" == *"${failingPlatform ?? "generic/platform="}"* ]]; then
  exit ${consumerStatus}
fi
`, { mode: 0o755 });
  for (const name of frameworks.filter(name => name !== missing)) {
    await fs.mkdir(path.join(output, `${name}.xcframework`), { recursive: true });
  }
  return {
    root, output,
    run: (...args) => spawnSync("bash", [path.join(source, "Scripts/CI/check_binary_interface.sh"), ...args], {
      encoding: "utf8", env: { ...process.env, PATH: `${root}/bin:${process.env.PATH}`, TEST_ROOT: root,
        PROJECT_BUILD_DIR: output, OPENSWIFTUI_BINARY_PACKAGE_PATH: binary },
    }),
  };
}

test("uses the complete release build and checks all three platform interfaces", async t => {
  const f = await fixture(t);
  const result = f.run();
  assert.equal(result.status, 0, result.stderr);
  const build = await fs.readFile(path.join(f.root, "build-args"), "utf8");
  assert.equal(build, "--compute\nOpenSwiftUI\n");
  const consumer = await fs.readFile(path.join(f.root, "consumer-args"), "utf8");
  for (const platform of ["iOS Simulator", "macOS", "visionOS Simulator"]) {
    assert.ok(consumer.includes(`generic/platform=${platform}`));
  }
  const derivedData = [...consumer.matchAll(/-derivedDataPath\n([^\n]+)/g)].map(match => match[1]);
  assert.equal(new Set(derivedData).size, 3);
  assert.match(consumer, /-module-load-mode.*prefer-interface/);
  assert.equal(await fs.readFile(path.join(f.root, "local-path"), "utf8"), await fs.realpath(f.output));
});

test("a missing local framework fails before the package can download a release", async t => {
  const f = await fixture(t, { missing: "OpenSwiftUICore" });
  const result = f.run("--skip-build");
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /OpenSwiftUICore.xcframework/);
  await assert.rejects(fs.stat(path.join(f.root, "consumer-args")), { code: "ENOENT" });
});

test("a packaging failure cannot pass the check", async t => {
  const f = await fixture(t, { buildStatus: 42 });
  assert.equal(f.run().status, 42);
  await assert.rejects(fs.stat(path.join(f.root, "consumer-args")), { code: "ENOENT" });
});

test("a consumer compile failure cannot pass the check", async t => {
  const f = await fixture(t, { consumerStatus: 65 });
  assert.equal(f.run("--skip-build").status, 65);
});

for (const platform of ["iOS Simulator", "macOS", "visionOS Simulator"]) {
  test(`a ${platform} failure is reported after checking all platforms`, async t => {
    const f = await fixture(t, { consumerStatus: 65, failingPlatform: `generic/platform=${platform}` });
    assert.equal(f.run("--skip-build").status, 65);
    const consumer = await fs.readFile(path.join(f.root, "consumer-args"), "utf8");
    assert.equal((consumer.match(/-destination/g) ?? []).length, 3);
  });
}
