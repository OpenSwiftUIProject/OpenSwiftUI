const assert = require("node:assert/strict");
const { execFileSync } = require("node:child_process");
const fs = require("node:fs/promises");
const os = require("node:os");
const path = require("node:path");
const test = require("node:test");
const { frameworks } = require("../release.js");

const version = "0.20.0";
const gitEnvironment = {
  ...process.env, GIT_CONFIG_GLOBAL: "/dev/null", GIT_CONFIG_NOSYSTEM: "1",
  GIT_AUTHOR_NAME: "Release test", GIT_COMMITTER_NAME: "Release test",
  GIT_AUTHOR_EMAIL: "release@example.invalid", GIT_COMMITTER_EMAIL: "release@example.invalid",
};
const git = (directory, ...args) => execFileSync("git", ["-C", directory, ...args], {
  encoding: "utf8", env: gitEnvironment, stdio: ["ignore", "pipe", "pipe"],
}).trim();

async function fixture(t) {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "openswiftui-binary-release-"));
  t.after(() => fs.rm(root, { recursive: true, force: true }));
  const source = path.join(root, "source");
  const remote = path.join(root, "remote.git");
  const binary = path.join(root, "binary");
  await fs.mkdir(path.join(source, "Scripts/CI"), { recursive: true });
  await fs.mkdir(path.join(source, "Sources/OpenSwiftUIMacros"), { recursive: true });
  await fs.copyFile(path.join(__dirname, "../release.js"), path.join(source, "Scripts/CI/release.js"));
  await fs.writeFile(path.join(source, "Sources/OpenSwiftUIMacros/Macro.swift"), "// Current macros\n");
  await fs.mkdir(remote);
  git(remote, "init", "--bare", "--initial-branch=main");
  git(root, "clone", remote, binary);
  await fs.writeFile(path.join(binary, "Package.swift.template"), [
    "// {{VERSION}}", ...frameworks.map(name => `// ${name}: {{CHECKSUM_${name}}}`),
  ].join("\n"));
  await fs.writeFile(path.join(binary, "README.md"), '.package(url: "https://github.com/OpenSwiftUIProject/OpenSwiftUI-spm", from: "0.19.0")\n');
  git(binary, "add", ".");
  git(binary, "commit", "-m", "Initial package");
  git(binary, "push", "origin", "main");
  const manifest = {
    version, sha: "a".repeat(40),
    files: Object.fromEntries(frameworks.map(name => [`${name}.xcframework.zip`, "b".repeat(64)])),
  };
  const run = (overrides = {}) => execFileSync("bash", [
    path.join(__dirname, "../update_binary_package.sh"), source, binary,
  ], {
    env: { ...gitEnvironment, VERSION: version, RELEASE_MANIFEST: JSON.stringify(manifest), ...overrides },
    encoding: "utf8", stdio: ["ignore", "pipe", "pipe"],
  });
  return { root, source, remote, binary, manifest, run };
}

test("binary package publication creates matching refs and retries without another commit", async t => {
  const { source, remote, binary, run } = await fixture(t);
  run();
  const published = git(remote, "rev-parse", `refs/tags/${version}`);
  assert.equal(git(remote, "rev-parse", "main"), published);
  assert.match(await fs.readFile(path.join(binary, "Package.swift"), "utf8"), /0\.20\.0/);
  assert.match(await fs.readFile(path.join(binary, "README.md"), "utf8"), /from: "0\.20\.0"/);
  run();
  assert.equal(git(remote, "rev-parse", "main"), published);
  await fs.appendFile(path.join(source, "Sources/OpenSwiftUIMacros/Macro.swift"), "// Changed\n");
  assert.throws(run, /different artifacts or macros/);
  assert.equal(git(remote, "rev-parse", `refs/tags/${version}`), published);
});

test("a concurrent main update rejects both the branch update and the new tag", async t => {
  const { root, remote, run } = await fixture(t);
  const concurrent = path.join(root, "concurrent");
  git(root, "clone", remote, concurrent);
  await fs.writeFile(path.join(concurrent, "CHANGELOG.md"), "Concurrent update\n");
  git(concurrent, "add", ".");
  git(concurrent, "commit", "-m", "Concurrent update");
  git(concurrent, "push", "origin", "main");
  const current = git(remote, "rev-parse", "main");
  assert.throws(run, /atomic push failed/);
  assert.equal(git(remote, "rev-parse", "main"), current);
  assert.throws(() => git(remote, "show-ref", "--verify", `refs/tags/${version}`));
});

test("a manifest for another version cannot publish a binary package tag", async t => {
  const { remote, manifest, run } = await fixture(t);
  const original = git(remote, "rev-parse", "main");
  manifest.version = "0.21.0";
  assert.throws(() => run({ RELEASE_MANIFEST: JSON.stringify(manifest) }), /version/i);
  assert.equal(git(remote, "rev-parse", "main"), original);
  assert.throws(() => git(remote, "show-ref", "--verify", `refs/tags/${version}`));
});
