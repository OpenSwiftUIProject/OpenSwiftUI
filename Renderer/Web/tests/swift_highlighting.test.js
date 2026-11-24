const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

const root = path.resolve(__dirname, "..");
const context = vm.createContext({ console, setTimeout, clearTimeout });
for (const sourcePath of [
  "node_modules/ace-builds/src-min-noconflict/ace.js",
  "node_modules/ace-builds/src-min-noconflict/mode-swift.js",
  "swift6-mode.js",
]) {
  const absolutePath = path.join(root, sourcePath);
  new vm.Script(fs.readFileSync(absolutePath, "utf8"), {
    filename: absolutePath,
  }).runInContext(context);
}

const Mode = context.ace.require("ace/mode/swift6").Mode;
const tokenizer = new Mode().getTokenizer();

function tokenize(source) {
  let state = "start";
  const tokens = [];
  for (const [row, line] of source.split("\n").entries()) {
    const result = tokenizer.getLineTokens(line, state);
    state = result.state;
    tokens.push(...result.tokens.map((token) => ({ ...token, row })));
  }
  return tokens;
}

function requireToken(tokens, value, expectedType) {
  const token = tokens.find((candidate) => candidate.value === value);
  assert.ok(token, `Missing token: ${value}`);
  assert.equal(token.type, expectedType, `${value} was ${token.type}`);
}

const tokens = tokenize(`// comment with some await
actor Store {
    nonisolated func load<T>(_ value: borrowing T) async throws -> some Sendable {
        let text = "hello actor await"
        await perform(value)
    }
}
macro Preview() = #externalMacro(module: "M", type: "P")
let asyncValue = 1
let someView = 2`);

for (const keyword of [
  "actor",
  "nonisolated",
  "borrowing",
  "async",
  "throws",
  "some",
  "await",
  "macro",
]) {
  requireToken(tokens, keyword, "keyword");
}
requireToken(tokens, "asyncValue", "identifier");
requireToken(tokens, "someView", "identifier");
assert.ok(tokens.some((token) => (
  token.type.startsWith("string") && token.value.includes("hello actor await")
)));
assert.ok(tokens.some((token) => (
  token.type.startsWith("comment") && token.value.includes("some await")
)));

const multilineTokens = tokenize(`/* actor
await */
let value = 1`);
assert.ok(multilineTokens.some((token) => (
  token.row === 1 && token.type.startsWith("comment") && token.value.includes("await")
)));
requireToken(multilineTokens, "let", "keyword");
