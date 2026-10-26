const assert = require("node:assert/strict");
const { spawnSync } = require("node:child_process");
const fs = require("node:fs/promises");
const os = require("node:os");
const path = require("node:path");
const test = require("node:test");

const frameworks = require("../release.js").frameworks;

async function fixture(t, { missing, buildStatus = 0, consumerStatus = 0, failingPlatform, moduleVersion = "0.25.0" } = {}) {
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
  await fs.copyFile(path.join(__dirname, "../check_binary_version.py"), path.join(source, "Scripts/CI/check_binary_version.py"));
  await fs.writeFile(path.join(source, "VERSION.txt"), "0.25.0\n");
  await fs.writeFile(path.join(source, "Scripts/build_xcframework.sh"), `#!/bin/bash
printf '%s\\n' "$@" > "$TEST_ROOT/build-args"
exit ${buildStatus}
`, { mode: 0o755 });
  await fs.writeFile(path.join(binary, "Example/setup.sh"), "#!/bin/bash\nexit 0\n", { mode: 0o755 });
  await fs.writeFile(path.join(root, "bin/xcrun"), "#!/bin/bash\nif [[ \"$1\" == --sdk ]]; then echo /sdk; fi\nexit 0\n", { mode: 0o755 });
  await fs.writeFile(path.join(root, "bin/xcodebuild"), `#!/bin/bash
printf '%s\\n' "$@" >> "$TEST_ROOT/consumer-args"
printf '%s' "$OPENSWIFTUI_LOCAL_XCFRAMEWORKS_PATH" > "$TEST_ROOT/local-path"
if [[ "$*" == *"${failingPlatform ?? "generic/platform="}"* ]]; then
  exit ${consumerStatus}
fi
`, { mode: 0o755 });
  for (const name of frameworks.filter(name => name !== missing)) {
    const package = path.join(output, `${name}.xcframework`);
    await fs.mkdir(package, { recursive: true });
    if (["OpenSwiftUI", "OpenSwiftUICore"].includes(name)) {
      const directory = path.join(package, "macos-arm64", `${name}.framework/Modules/${name}.swiftmodule`);
      await fs.mkdir(directory, { recursive: true });
      await fs.writeFile(path.join(directory, "arm64.swiftinterface"), `// swift-module-flags: -target arm64-apple-macos13.0 -user-module-version ${moduleVersion}\n`);
      await fs.writeFile(path.join(package, "Info.plist"), `<?xml version="1.0"?><plist version="1.0"><dict><key>AvailableLibraries</key><array><dict>
<key>LibraryIdentifier</key><string>macos-arm64</string><key>LibraryPath</key><string>${name}.framework</string>
<key>SupportedPlatform</key><string>macos</string><key>SupportedArchitectures</key><array><string>arm64</string></array>
</dict></array></dict></plist>`);
    }
  }
  return {
    root, output,
    run: (...args) => spawnSync("bash", [path.join(source, "Scripts/CI/check_binary_interface.sh"), ...args], {
      encoding: "utf8", env: { ...process.env, PATH: `${root}/bin:${process.env.PATH}`, TEST_ROOT: root,
        PROJECT_BUILD_DIR: output, OPENSWIFTUI_BINARY_PACKAGE_PATH: binary, OPENSWIFTUI_MODULE_VERSION: "9.9.9" },
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

test("an incorrect module version fails before building the consumer", async t => {
  const f = await fixture(t, { moduleVersion: "0.24.0" });
  const result = f.run("--skip-build");
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /Expected user module version 0.25.0/);
  await assert.rejects(fs.stat(path.join(f.root, "consumer-args")), { code: "ENOENT" });
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
