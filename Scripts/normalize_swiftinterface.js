const fs = require("node:fs");
const path = require("node:path");

// Work around https://github.com/swiftlang/swift/issues/93415 until the
// interface printer merges repeated platform introductions itself.
function compareVersions(left, right) {
  const a = left.split(".").map(BigInt);
  const b = right.split(".").map(BigInt);
  for (let i = 0; i < Math.max(a.length, b.length); i++) {
    if ((a[i] ?? 0n) !== (b[i] ?? 0n)) return (a[i] ?? 0n) > (b[i] ?? 0n) ? 1 : -1;
  }
  return 0;
}

function normalizeAttribute(attribute) {
  const entries = attribute.slice("@available(".length, -1).split(",").map(entry => entry.trim());
  if (entries.pop() !== "*") return attribute;
  const platforms = new Map();
  let duplicate = false;
  for (const entry of entries) {
    const match = /^([A-Za-z_][A-Za-z_0-9]*)\s+(\d+(?:\.\d+)*)$/.exec(entry);
    // Long-form attributes and unknown syntax must remain unchanged.
    if (!match) return attribute;
    const [, platform, version] = match;
    if (platforms.has(platform)) {
      duplicate = true;
      if (compareVersions(version, platforms.get(platform)) <= 0) continue;
    }
    platforms.set(platform, version);
  }
  if (!duplicate) return attribute;
  return `@available(${[...platforms].map(([platform, version]) => `${platform} ${version}`).join(", ")}, *)`;
}

// Ignore comments and string literals, including raw/multiline strings and
// nested interpolation, so examples and default argument values are preserved.
function nonCodeEnd(text, start) {
  if (text.startsWith("//", start)) {
    const end = text.indexOf("\n", start);
    return end < 0 ? text.length : end;
  }
  if (text.startsWith("/*", start)) {
    let depth = 1;
    let i = start + 2;
    while (i < text.length && depth) {
      if (text.startsWith("/*", i)) { depth++; i += 2; }
      else if (text.startsWith("*/", i)) { depth--; i += 2; }
      else i++;
    }
    return i;
  }
  if (text[start] !== '"' && text[start] !== "#") return start;
  const opening = /^(#*)("""|")/.exec(text.slice(start));
  if (!opening) return start;
  const closing = opening[2] + opening[1];
  const escape = "\\" + opening[1];
  let i = start + opening[0].length;
  while (i < text.length) {
    if (text.startsWith(closing, i)) return i + closing.length;
    if (text.startsWith(escape, i)) {
      i += escape.length;
      if (text[i] === "(") {
        let depth = 1;
        i++;
        while (i < text.length && depth) {
          const end = nonCodeEnd(text, i);
          if (end > i) { i = end; continue; }
          if (text[i] === "(") depth++;
          if (text[i] === ")") depth--;
          i++;
        }
      } else i++;
    } else i++;
  }
  return i;
}

function normalizeText(text) {
  let result = "";
  let copied = 0;
  for (let i = 0; i < text.length;) {
    const end = nonCodeEnd(text, i);
    if (end > i) { i = end; continue; }
    if (text.startsWith("@available(", i)) {
      const close = text.indexOf(")", i);
      if (close >= 0) {
        const attribute = text.slice(i, close + 1);
        const normalized = normalizeAttribute(attribute);
        if (normalized !== attribute) {
          result += text.slice(copied, i) + normalized;
          i = copied = close + 1;
          continue;
        }
      }
    }
    i++;
  }
  return result + text.slice(copied);
}

function normalizeDirectory(directory) {
  let changed = 0;
  for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
    const file = path.join(directory, entry.name);
    if (entry.isDirectory()) changed += normalizeDirectory(file);
    else if (entry.isFile() && entry.name.endsWith(".swiftinterface")) {
      const original = fs.readFileSync(file, "utf8");
      const normalized = normalizeText(original);
      if (normalized !== original) {
        fs.writeFileSync(file, normalized);
        changed++;
      }
    }
  }
  return changed;
}

if (require.main === module) {
  if (process.argv.length !== 3) {
    console.error("Usage: node Scripts/normalize_swiftinterface.js <modules-directory>");
    process.exitCode = 64;
  } else {
    const count = normalizeDirectory(process.argv[2]);
    console.log(`Normalized availability in ${count} Swift interfaces.`);
  }
}

module.exports = { normalizeText, normalizeDirectory };
