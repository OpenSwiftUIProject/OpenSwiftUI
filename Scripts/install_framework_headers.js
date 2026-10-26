const fs = require("node:fs");
const path = require("node:path");

function installFrameworkHeaders(name, framework, source) {
  const contents = fs.existsSync(path.join(framework, "Versions"))
    ? path.join(framework, "Versions/Current") : framework;
  const headers = path.join(contents, "Headers");
  const modules = path.join(contents, "Modules");
  const sourceMap = fs.readFileSync(path.join(source, "module.modulemap"), "utf8");
  const declaration = `module ${name} {`;
  if (!sourceMap.startsWith(declaration)) {
    throw new Error(`Expected a public module map for ${name}.`);
  }
  fs.accessSync(path.join(source, `${name}.h`));

  // Keep the source and framework exports in one module map. Only their layout differs.
  const frameworkMap = sourceMap.replace(declaration, `framework ${declaration}`);
  fs.cpSync(source, headers, {
    recursive: true,
    dereference: true,
    filter: file => fs.statSync(file).isDirectory() || file.endsWith(".h"),
  });
  fs.rmSync(path.join(headers, `${name}-Swift.h`), { force: true });
  fs.mkdirSync(modules, { recursive: true });
  fs.writeFileSync(path.join(modules, "module.modulemap"), frameworkMap);
}

if (require.main === module) {
  const carriers = { OpenSwiftUI: "COpenSwiftUI", OpenSwiftUICore: "OpenSwiftUI_SPI" };
  const [name, framework] = process.argv.slice(2);
  if (process.argv.length !== 4 || !carriers[name]) {
    console.error("Usage: node Scripts/install_framework_headers.js <OpenSwiftUI|OpenSwiftUICore> <framework>");
    process.exitCode = 64;
  } else {
    installFrameworkHeaders(name, framework, path.join(__dirname, "../Sources", carriers[name], "Public"));
  }
}

module.exports = { installFrameworkHeaders };
