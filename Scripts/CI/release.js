const { createHash } = require("node:crypto");
const { createReadStream } = require("node:fs");
const fs = require("node:fs/promises");
const path = require("node:path");

const frameworks = [
  "OpenSwiftUI", "OpenSwiftUICore", "OpenAttributeGraphShims",
  "OpenCoreGraphicsShims", "OpenObservation", "OpenQuartzCoreShims", "OpenRenderBoxShims",
];
const requiredChecks = ["macos", "ios", "ubuntu", "ui", "compatibility", "stdout"];
const manifestName = "release-manifest.json";

function validateVersion(version) {
  if (typeof version !== "string" || version !== version.trim() ||
      !/^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$/.test(version)) {
    throw new Error("Use a stable version such as 0.20.0, without a v prefix.");
  }
  return version;
}

function validateSHA(sha) {
  if (typeof sha !== "string" || sha.length !== 40 || !/^[0-9a-f]+$/.test(sha)) {
    throw new Error("A full commit SHA is required.");
  }
  return sha;
}

function validateReleaseRef(version, ref) {
  validateVersion(version);
  const series = version.split(".").slice(0, 2).join(".");
  if (ref !== "refs/heads/main" && ref !== `refs/heads/release/${series}`) {
    throw new Error(`Release ${version} must run from main or release/${series}.`);
  }
}

function assertChecks(results, sha) {
  validateSHA(sha);
  const failures = requiredChecks.filter(name =>
    results[name]?.result !== "success" || results[name]?.outputs?.["verified-sha"] !== sha
  );
  if (failures.length) {
    throw new Error(`Checks did not verify ${sha}: ${failures.join(", ")}`);
  }
}

async function getTagSHA(github, repo, version) {
  validateVersion(version);
  let object;
  try {
    ({ data: { object } } = await github.rest.git.getRef({ ...repo, ref: `tags/${version}` }));
  } catch (error) {
    if (error.status === 404) return null;
    throw error;
  }
  const visited = new Set();
  while (object.type === "tag") {
    if (visited.has(object.sha)) throw new Error("Tag contains a reference cycle.");
    visited.add(object.sha);
    ({ data: { object } } = await github.rest.git.getTag({ ...repo, tag_sha: object.sha }));
  }
  if (object.type !== "commit") throw new Error("Tag must refer to a commit.");
  return validateSHA(object.sha);
}

async function ensureTag({ github, repo, version, sha }) {
  validateSHA(sha);
  const existing = await getTagSHA(github, repo, version);
  if (existing && existing !== sha) throw new Error(`Tag ${version} already points to ${existing}.`);
  if (existing) return;
  try {
    await github.rest.git.createRef({ ...repo, ref: `refs/tags/${version}`, sha });
  } catch (error) {
    // Another attempt may have created this exact tag after the initial read.
    if (error.status !== 422 || await getTagSHA(github, repo, version) !== sha) throw error;
  }
}

async function hashFile(file) {
  const hash = createHash("sha256");
  for await (const chunk of createReadStream(file)) hash.update(chunk);
  return hash.digest("hex");
}

function validateManifest(manifest, version, sha) {
  validateVersion(version);
  validateSHA(sha);
  if (manifest.version !== version) throw new Error("Artifact version does not match the release.");
  if (manifest.sha !== sha) throw new Error("Artifact SHA does not match the checked commit.");
  const names = frameworks.map(name => `${name}.xcframework.zip`);
  if (Object.keys(manifest.files || {}).sort().join() !== names.sort().join()) {
    throw new Error("Release must contain all seven XCFramework archives.");
  }
  for (const digest of Object.values(manifest.files)) {
    if (typeof digest !== "string" || digest.length !== 64 || !/^[0-9a-f]+$/.test(digest)) {
      throw new Error("Invalid artifact digest.");
    }
  }
  return manifest;
}

async function writeManifest(directory, version, sha) {
  validateVersion(version);
  validateSHA(sha);
  const files = {};
  for (const framework of frameworks) {
    const name = `${framework}.xcframework.zip`;
    files[name] = await hashFile(path.join(directory, name));
  }
  const manifest = { version, sha, files };
  await fs.writeFile(path.join(directory, manifestName), `${JSON.stringify(manifest, null, 2)}\n`);
  return manifest;
}

async function verifyManifest(directory, version, sha) {
  const manifest = validateManifest(JSON.parse(await fs.readFile(path.join(directory, manifestName), "utf8")), version, sha);
  for (const [name, digest] of Object.entries(manifest.files)) {
    if (await hashFile(path.join(directory, name)) !== digest) throw new Error(`Artifact digest mismatch: ${name}`);
  }
  return manifest;
}

async function findRelease(github, repo, version) {
  try {
    return (await github.rest.repos.getReleaseByTag({ ...repo, tag: version })).data;
  } catch (error) {
    if (error.status === 404) return null;
    throw error;
  }
}

async function missingAssets(github, repo, releaseId, files) {
  const assets = await github.paginate(github.rest.repos.listReleaseAssets, { ...repo, release_id: releaseId, per_page: 100 });
  const missing = [];
  for (const [name, digest] of Object.entries(files)) {
    const asset = assets.find(asset => asset.name === name);
    if (!asset) {
      missing.push(name);
    } else if (asset.state !== "uploaded" || asset.digest !== `sha256:${digest}`) {
      throw new Error(`Release asset digest mismatch: ${name}. Existing assets are not replaced.`);
    }
  }
  return missing;
}

async function prepareRelease({ github, repo, version, sha, directory }) {
  const manifest = await verifyManifest(directory, version, sha);
  if (await getTagSHA(github, repo, version) !== sha) throw new Error("Release tag must already name the checked commit.");
  let release = await findRelease(github, repo, version);
  if (!release) {
    ({ data: release } = await github.rest.repos.createRelease({
      ...repo, tag_name: version, target_commitish: sha, name: version, draft: true,
    }));
  }
  const files = { ...manifest.files, [manifestName]: await hashFile(path.join(directory, manifestName)) };
  const missing = await missingAssets(github, repo, release.id, files);
  if (!release.draft && missing.length) throw new Error("Missing assets in an already published release.");
  return { version, sha, releaseId: release.id, files, missing, manifest };
}

async function publishRelease({ github, repo, plan }) {
  validateManifest(plan.manifest, plan.version, plan.sha);
  if (await getTagSHA(github, repo, plan.version) !== plan.sha) throw new Error("Release tag changed before publication.");
  const release = await findRelease(github, repo, plan.version);
  if (!release || release.id !== plan.releaseId) throw new Error("The prepared release no longer exists.");
  const missing = await missingAssets(github, repo, release.id, plan.files);
  if (missing.length) throw new Error(`Missing release assets: ${missing.join(", ")}`);
  if (release.draft) {
    await github.rest.repos.updateRelease({ ...repo, release_id: release.id, draft: false, make_latest: "legacy" });
  }
}

async function renderBinaryPackage(source, binary, manifest) {
  validateManifest(manifest, manifest.version, manifest.sha);
  const template = await fs.readFile(path.join(binary, "Package.swift.template"), "utf8");
  const values = { VERSION: manifest.version };
  for (const framework of frameworks) values[`CHECKSUM_${framework}`] = manifest.files[`${framework}.xcframework.zip`];
  const contents = template.replace(/\{\{(\w+)\}\}/g, (_, key) => {
    if (!Object.hasOwn(values, key)) throw new Error(`Unknown package template field: ${key}`);
    return values[key];
  });
  await fs.writeFile(path.join(binary, "Package.swift"), contents);
  const readmePath = path.join(binary, "README.md");
  const readme = await fs.readFile(readmePath, "utf8");
  await fs.writeFile(readmePath, readme.replace(
    /(\.package\(url:\s*"https:\/\/github\.com\/OpenSwiftUIProject\/OpenSwiftUI-spm",\s*from:\s*")[^"]+("\))/g,
    (_, prefix, suffix) => `${prefix}${manifest.version}${suffix}`,
  ));
  const macros = path.join(binary, "Sources/OpenSwiftUIMacros");
  await fs.rm(macros, { recursive: true, force: true });
  await fs.cp(path.join(source, "Sources/OpenSwiftUIMacros"), macros, { recursive: true });
}

module.exports = {
  frameworks, requiredChecks, validateVersion, validateSHA, validateReleaseRef, assertChecks,
  getTagSHA, ensureTag, writeManifest, verifyManifest, prepareRelease, publishRelease, renderBinaryPackage,
};

if (require.main === module) {
  const [command, ...args] = process.argv.slice(2);
  const run = async () => {
    if (command === "manifest") return writeManifest(...args);
    if (command === "render-package") {
      const manifest = JSON.parse(process.env.RELEASE_MANIFEST);
      validateManifest(manifest, process.env.VERSION, manifest.sha);
      return renderBinaryPackage(...args, manifest);
    }
    throw new Error("Expected manifest or render-package.");
  };
  run().catch(error => { console.error(error.message); process.exitCode = 1; });
}
