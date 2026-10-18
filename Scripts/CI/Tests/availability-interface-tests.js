const assert = require("node:assert/strict");
const { spawnSync } = require("node:child_process");
const fs = require("node:fs/promises");
const os = require("node:os");
const path = require("node:path");
const test = require("node:test");
const { normalizeText, normalizeDirectory } = require("../../normalize_swiftinterface.js");

const root = path.resolve(__dirname, "../../..");

test("duplicate platform versions use the strictest numeric version in either order", () => {
  for (const versions of ["macOS 10.9, macOS 10.15.1", "macOS 10.15.1, macOS 10.9"]) {
    const source = `  @available(iOS 13.0, ${versions}, iOS 15.0, visionOS 1.0, *)\n`;
    const expected = "  @available(iOS 15.0, macOS 10.15.1, visionOS 1.0, *)\n";
    assert.equal(normalizeText(source), expected);
    assert.equal(normalizeText(expected), expected);
  }
  assert.equal(normalizeText("@available(iOS 13, iOS 13.0, *)"), "@available(iOS 13, *)");
});

test("complex attributes, comments, and strings remain unchanged", () => {
  const source = [
    '@available(iOS, introduced: 13.0, deprecated: 15.0, message: "Use another API")',
    '@available(macOS, unavailable)',
    '@available(iOS 13.0, iOS 15.0, *, deprecated)',
    '@available(*, deprecated, renamed: "replacement()")',
    '@available(swift 6.0)',
    '@available(iOS 13.0, macOS 10.15, *)',
    '// @available(iOS 13.0, iOS 15.0, *)',
    '/* Outer /* Nested */ @available(iOS 13.0, iOS 15.0, *) */',
    'public let text = #"""',
    '@available(iOS 13.0, iOS 15.0, *)',
    '"""#',
    'public let escaped = "\\\"@available(iOS 13.0, iOS 15.0, *)"',
    'public let interpolated = "\\(value("@available(iOS 13.0, iOS 15.0, *)"))"',
  ].join("\n");
  assert.equal(normalizeText(source), source);
  assert.equal(normalizeText(source + '\n@available(iOS 13.0, iOS 15.0, *)'),
    source + '\n@available(iOS 15.0, *)');
});

test("normalizes all interface variants without touching binary modules", async t => {
  const directory = await fs.mkdtemp(path.join(os.tmpdir(), "interface files "));
  t.after(() => fs.rm(directory, { recursive: true, force: true }));
  const modules = path.join(directory, "Probe.swiftmodule");
  await fs.mkdir(modules);
  const source = "@available(iOS 13.0, iOS 15.0, *)\n";
  for (const suffix of ["swiftinterface", "private.swiftinterface", "package.swiftinterface", "swiftmodule"]) {
    await fs.writeFile(path.join(modules, `arm64.${suffix}`), source);
  }
  // macOS frameworks expose Modules through a Versions/Current symlink.
  const current = path.join(directory, "Current");
  await fs.symlink(modules, current);
  assert.equal(normalizeDirectory(current), 3);
  for (const suffix of ["swiftinterface", "private.swiftinterface", "package.swiftinterface"]) {
    assert.equal(await fs.readFile(path.join(modules, `arm64.${suffix}`), "utf8"), "@available(iOS 15.0, *)\n");
  }
  assert.equal(await fs.readFile(path.join(modules, "arm64.swiftmodule"), "utf8"), source);
  assert.equal(normalizeDirectory(directory), 0);
  assert.throws(() => normalizeDirectory(path.join(directory, "missing")), /ENOENT/);
});

test("normalized source availability configurations can be loaded as interfaces", {
  skip: process.platform !== "darwin",
}, async t => {
  const directory = await fs.mkdtemp(path.join(os.tmpdir(), "availability-interface-"));
  t.after(() => fs.rm(directory, { recursive: true, force: true }));
  const blocks = new Set();
  for (const file of [
    "Sources/OpenSwiftUICore/Data/EnvironmentKeys/ControlSize.swift",
    "Sources/OpenSwiftUI/Event/Focus/DefaultFocus.swift",
  ]) {
    const source = await fs.readFile(path.join(root, file), "utf8");
    for (const match of source.matchAll(/(?:^[ \t]*@available\([^\n]+\)\n)+/gm)) blocks.add(match[0].trim());
  }
  assert.ok(blocks.size > 0);
  const fixture = path.join(directory, "Probe.swift");
  await fs.writeFile(fixture, [...blocks].map((block, index) =>
    `${block}\npublic struct Probe${index} {}\n`).join("\n") +
    "\n@available(macOS 11.0, *)\n@available(macOS 15.0, *)\npublic func api() {}\n");
  const manifest = await fs.readFile(path.join(root, "Package.swift"), "utf8");
  const minimum = manifest.match(/let minimumVersion = "([^"]+)"/)[1];
  const definitions = [...manifest.matchAll(/AvailabilityMacro=(\w+):\\\(ignoreAvailability \? minimumVersion : "([^"]+)"\)/g)];
  assert.ok(definitions.length > 0);
  const configurations = {
    package: definitions.map(([, name]) => `${name}:${minimum}`),
    compatibility: definitions.map(([, name, versions]) => `${name}:${versions}`),
  };
  for (const name of ["OpenSwiftUI", "SwiftUI"]) {
    const config = await fs.readFile(path.join(root, `Configurations/Shared/basic/${name}.xcconfig`), "utf8");
    configurations[name] = [...config.matchAll(/"AvailabilityMacro=([^"]+)"/g)].map(match => match[1]);
  }
  for (const [name, macros] of Object.entries(configurations)) {
    await t.test(name, async () => {
      const output = path.join(directory, name);
      await fs.mkdir(output);
      const base = ["swiftc", "-swift-version", "6", "-target", "arm64-apple-macosx11.0",
        "-module-cache-path", path.join(output, "cache")];
      const result = spawnSync("xcrun", [...base, fixture, "-emit-module", "-enable-library-evolution",
        "-no-verify-emitted-module-interface", "-module-name", "Probe", "-package-name", "ProbePackage",
        "-emit-module-path", path.join(output, "Probe.swiftmodule"),
        "-emit-module-interface-path", path.join(output, "Probe.swiftinterface"),
        "-emit-package-module-interface-path", path.join(output, "Probe.package.swiftinterface"),
        ...macros.flatMap(macro => ["-enable-experimental-feature", `AvailabilityMacro=${macro}`]),
      ], { encoding: "utf8" });
      assert.equal(result.status, 0, result.stderr);
      normalizeDirectory(output);
      // Import each variant on its own so serialized modules and other variants cannot hide errors.
      for (const variant of ["swiftinterface", "private.swiftinterface", "package.swiftinterface"]) {
        const load = path.join(output, variant);
        await fs.mkdir(load);
        await fs.copyFile(path.join(output, `Probe.${variant}`), path.join(load, "Probe.swiftinterface"));
        const client = path.join(load, "Client.swift");
        for (const version of ["13.0", "15.0"]) {
          await fs.writeFile(client, `import Probe\n@available(macOS ${version}, *)\nfunc caller() { api() }\n`);
          const check = spawnSync("xcrun", [...base, "-typecheck", client, "-I", load,
            "-Xfrontend", "-module-load-mode", "-Xfrontend", "prefer-interface"], { encoding: "utf8" });
          assert.equal(check.status, version === "13.0" ? 1 : 0, check.stderr);
          if (version === "13.0") assert.match(check.stderr, /'api\(\)' is only available in macOS 15.0 or newer/);
        }
      }
    });
  }
});
