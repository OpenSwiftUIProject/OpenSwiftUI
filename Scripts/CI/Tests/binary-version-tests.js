const assert = require("node:assert/strict");
const { spawnSync } = require("node:child_process");
const fs = require("node:fs/promises");
const os = require("node:os");
const path = require("node:path");
const test = require("node:test");

const script = path.join(__dirname, "../check_binary_version.py");
const modules = ["OpenSwiftUI", "OpenSwiftUICore"];
const slices = [
  ["macos-arm64", "macos", "", "arm64-apple-macos13.0"],
  ["ios-arm64", "ios", "", "arm64-apple-ios15.0"],
  ["ios-arm64-simulator", "ios", "simulator", "arm64-apple-ios15.0-simulator"],
  ["xros-arm64", "xros", "", "arm64-apple-xros1.0"],
  ["xros-arm64-simulator", "xros", "simulator", "arm64-apple-xros1.0-simulator"],
];

async function fixture(t) {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "binary version "));
  t.after(() => fs.rm(root, { recursive: true, force: true }));
  const source = path.join(root, "source");
  const versionFile = path.join(source, "VERSION.txt");
  const checker = path.join(source, "Scripts/CI/check_binary_version.py");
  await fs.mkdir(path.dirname(checker), { recursive: true });
  await fs.copyFile(script, checker);
  await fs.writeFile(versionFile, "0.25.0\n");
  const interfaces = [];
  for (const module of modules) {
    const package = path.join(root, `${module}.xcframework`);
    const libraries = [];
    for (const [identifier, platform, variant, target] of slices) {
      const framework = path.join(package, identifier, `${module}.framework`);
      const directory = path.join(framework, "Modules", `${module}.swiftmodule`);
      await fs.mkdir(directory, { recursive: true });
      const file = path.join(directory, "arm64.swiftinterface");
      await fs.writeFile(file, `// swift-module-flags: -target ${target} -user-module-version 0.25.0 -module-name ${module}\n`);
      interfaces.push(file);
      libraries.push(`<dict><key>LibraryIdentifier</key><string>${identifier}</string>
<key>LibraryPath</key><string>${module}.framework</string>
<key>SupportedPlatform</key><string>${platform}</string>
<key>SupportedPlatformVariant</key><string>${variant}</string>
<key>SupportedArchitectures</key><array><string>arm64</string></array></dict>`);
    }
    await fs.writeFile(path.join(package, "Info.plist"), `<?xml version="1.0"?><plist version="1.0"><dict><key>AvailableLibraries</key><array>${libraries.join("")}</array></dict></plist>`);
  }
  await fs.mkdir(path.join(root, "bin"));
  await fs.writeFile(path.join(root, "bin/xcrun"), `#!/bin/bash
if [[ "$1" == --sdk ]]; then
  echo /sdk
else
  printf '%s\\n' "$@" >> "$TEST_ROOT/compiler-args"
  exit "$TEST_COMPILER_STATUS"
fi
`, { mode: 0o755 });
  return { root, interfaces, versionFile, run: (compile = false, status = 0) => spawnSync("python3", [
    checker, root, ...(compile ? ["--check-imports", path.join(root, "checks")] : []),
  ], { encoding: "utf8", cwd: root, env: { ...process.env, PATH: `${root}/bin:${process.env.PATH}`,
    TEST_ROOT: root, TEST_COMPILER_STATUS: String(status), OPENSWIFTUI_MODULE_VERSION: "9.9.9" } }) };
}

test("validates both modules in every slice and generates compiler boundary checks", async t => {
  const f = await fixture(t);
  const result = f.run(true);
  assert.equal(result.status, 0, result.stderr);
  const source = await fs.readFile(path.join(f.root, "checks/VersionCheck.swift"), "utf8");
  for (const module of modules) {
    assert.ok(source.includes(`!canImport(${module}, _version: 0.25.0)`));
    assert.ok(source.includes(`canImport(${module}, _version: 0.25.1)`));
  }
  const args = await fs.readFile(path.join(f.root, "compiler-args"), "utf8");
  assert.equal((args.match(/-typecheck/g) ?? []).length, 5);
  assert.equal((args.match(/-warnings-as-errors/g) ?? []).length, 5);
  assert.equal((args.match(/prefer-interface/g) ?? []).length, 5);
});

for (const version of [null, "0.24.9", "0.25.1"]) {
  test(`a missing or incorrect version in any slice fails: ${version}`, async t => {
    const f = await fixture(t);
    const file = f.interfaces.at(-1);
    const text = await fs.readFile(file, "utf8");
    await fs.writeFile(file, text.replace("-user-module-version 0.25.0", version ? `-user-module-version ${version}` : ""));
    const result = f.run();
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /OpenSwiftUICore.*arm64.swiftinterface/);
  });
}

test("private interfaces cannot replace a missing public interface", async t => {
  const f = await fixture(t);
  const file = f.interfaces[0];
  await fs.rename(file, file.replace(".swiftinterface", ".private.swiftinterface"));
  assert.notEqual(f.run().status, 0);
});

test("a missing architecture interface fails", async t => {
  const f = await fixture(t);
  const plist = path.join(f.root, "OpenSwiftUI.xcframework/Info.plist");
  await fs.writeFile(plist, (await fs.readFile(plist, "utf8")).replace("<string>arm64</string>", "<string>arm64</string><string>x86_64</string>"));
  assert.notEqual(f.run().status, 0);
});

test("compiler failures cannot pass version validation", async t => {
  const f = await fixture(t);
  assert.notEqual(f.run(true, 42).status, 0);
});

test("invalid source versions fail before inspecting artifacts", async t => {
  const f = await fixture(t);
  for (const version of ["", "v0.25.0", "0.25", "01.2.3", "0.25.0-rc.1", "0.25.0\n0.26.0"]) {
    await fs.writeFile(f.versionFile, version);
    const result = f.run();
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /stable version/);
  }
});

test("a changed or missing version file cannot validate stale binaries", async t => {
  const f = await fixture(t);
  await fs.writeFile(f.versionFile, "0.26.0\n");
  const result = f.run();
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /Expected user module version 0.26.0/);
  await fs.unlink(f.versionFile);
  assert.match(f.run().stderr, /VERSION.txt/);
});
