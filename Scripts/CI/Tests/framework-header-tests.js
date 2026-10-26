const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const test = require("node:test");

const { installFrameworkHeaders } = require("../../install_framework_headers.js");

function fixture(t, versioned) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "framework headers "));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const source = path.join(root, "Public");
  const framework = path.join(root, "OpenSwiftUI.framework");
  const contents = versioned ? path.join(framework, "Versions/A") : framework;
  fs.mkdirSync(source, { recursive: true });
  fs.mkdirSync(path.join(source, "Details"));
  fs.mkdirSync(path.join(contents, "Headers"), { recursive: true });
  if (versioned) {
    fs.symlinkSync("A", path.join(framework, "Versions/Current"));
    fs.symlinkSync("Versions/Current/Headers", path.join(framework, "Headers"));
  }
  fs.writeFileSync(path.join(source, "OpenSwiftUI.h"), '#include "Details/Exports.h"\n');
  fs.writeFileSync(path.join(source, "Details/Exports.h"), "#define PUBLIC_VALUE 42\n");
  fs.writeFileSync(path.join(source, "OpenSwiftUI_Metal.h"), "#if defined(__METAL_VERSION__)\nnamespace OpenSwiftUI {}\n#endif\n");
  fs.writeFileSync(path.join(root, "Internal.h"), "#define INTERNAL_VALUE 7\n");
  fs.writeFileSync(path.join(source, "module.modulemap"), `module OpenSwiftUI {
    umbrella header "OpenSwiftUI.h"
    textual header "OpenSwiftUI_Metal.h"
    export *
    module * { export * }
}
`);
  fs.writeFileSync(path.join(contents, "Headers/OpenSwiftUI-Swift.h"), "// Generated Swift declarations\n");
  return { source, framework, contents };
}

for (const versioned of [false, true]) {
  test(`installs a self-contained public module in a ${versioned ? "versioned" : "flat"} framework`, t => {
    const f = fixture(t, versioned);
    installFrameworkHeaders("OpenSwiftUI", f.framework, f.source);
    const headers = path.join(f.contents, "Headers");
    assert.equal(fs.readFileSync(path.join(headers, "Details/Exports.h"), "utf8"), "#define PUBLIC_VALUE 42\n");
    assert.equal(fs.existsSync(path.join(headers, "OpenSwiftUI-Swift.h")), false);
    assert.equal(fs.readFileSync(path.join(headers, "OpenSwiftUI_Metal.h"), "utf8"), fs.readFileSync(path.join(f.source, "OpenSwiftUI_Metal.h"), "utf8"));
    assert.equal(fs.existsSync(path.join(headers, "Internal.h")), false);
    assert.equal(fs.existsSync(path.join(headers, "module.modulemap")), false);
    const map = fs.readFileSync(path.join(f.contents, "Modules/module.modulemap"), "utf8");
    assert.match(map, /^framework module OpenSwiftUI \{/);
    assert.match(map, /umbrella header "OpenSwiftUI.h"/);
    assert.match(map, /textual header "OpenSwiftUI_Metal.h"/);
    assert.equal(map.includes("OpenSwiftUI.Swift"), false);
    assert.equal(map.includes("OpenSwiftUI-Swift.h"), false);
    assert.equal(map.includes(f.source), false);
    installFrameworkHeaders("OpenSwiftUI", f.framework, f.source);
    assert.equal(fs.readFileSync(path.join(f.contents, "Modules/module.modulemap"), "utf8"), map);
  });
}

test("installs public headers without a generated Swift header", t => {
  const f = fixture(t, false);
  fs.unlinkSync(path.join(f.contents, "Headers/OpenSwiftUI-Swift.h"));
  installFrameworkHeaders("OpenSwiftUI", f.framework, f.source);
  assert.equal(fs.existsSync(path.join(f.contents, "Headers/OpenSwiftUI.h")), true);
  assert.equal(fs.existsSync(path.join(f.contents, "Headers/OpenSwiftUI-Swift.h")), false);
});

test("rejects a missing public umbrella before changing the framework", t => {
  const f = fixture(t, false);
  fs.unlinkSync(path.join(f.source, "OpenSwiftUI.h"));
  assert.throws(() => installFrameworkHeaders("OpenSwiftUI", f.framework, f.source), /OpenSwiftUI.h/);
  assert.equal(fs.existsSync(path.join(f.contents, "Headers/OpenSwiftUI-Swift.h")), true);
  assert.equal(fs.existsSync(path.join(f.contents, "Headers/OpenSwiftUI_Metal.h")), false);
});

test("rejects a module map for a different module", t => {
  const f = fixture(t, false);
  fs.writeFileSync(path.join(f.source, "module.modulemap"), 'module Internal { header "Internal.h" }\n');
  assert.throws(() => installFrameworkHeaders("OpenSwiftUI", f.framework, f.source), /OpenSwiftUI/);
  assert.equal(fs.existsSync(path.join(f.contents, "Headers/OpenSwiftUI.h")), false);
});
