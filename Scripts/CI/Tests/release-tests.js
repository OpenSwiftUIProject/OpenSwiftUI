const assert = require("node:assert/strict");
const fs = require("node:fs/promises");
const os = require("node:os");
const path = require("node:path");
const test = require("node:test");
const release = require("../release.js");

const sha = "a".repeat(40);
const otherSHA = "b".repeat(40);
const version = "0.20.0";
const repo = { owner: "OpenSwiftUIProject", repo: "OpenSwiftUI" };
const notFound = () => Object.assign(new Error("Not found"), { status: 404 });

function client({ tag = null, published = false, assets = [] } = {}) {
  const writes = [];
  let currentTag = tag;
  let currentRelease = published ? { id: 7, draft: false } : null;
  const github = { rest: {
    git: {
      getRef: async () => {
        if (!currentTag) throw notFound();
        return { data: { object: { type: "commit", sha: currentTag } } };
      },
      createRef: async args => { writes.push(args); currentTag = args.sha; },
    },
    repos: {
      getReleaseByTag: async () => {
        if (!currentRelease) throw notFound();
        return { data: currentRelease };
      },
      createRelease: async args => {
        writes.push(args);
        currentRelease = { id: 7, draft: args.draft };
        return { data: currentRelease };
      },
      listReleaseAssets: async () => ({ data: assets }),
      updateRelease: async args => { writes.push(args); currentRelease.draft = args.draft; },
    },
  } };
  github.paginate = async method => (await method()).data;
  return { github, writes, assets };
}

async function artifacts(t) {
  const directory = await fs.mkdtemp(path.join(os.tmpdir(), "openswiftui-release-"));
  t.after(() => fs.rm(directory, { recursive: true, force: true }));
  for (const name of release.frameworks) {
    await fs.writeFile(path.join(directory, `${name}.xcframework.zip`), `fixture: ${name}`);
  }
  await release.writeManifest(directory, version, sha);
  return directory;
}

test("release inputs require a stable version and a full commit SHA", () => {
  assert.equal(release.validateVersion(version), version);
  assert.equal(release.validateSHA(sha), sha);
  for (const value of ["v0.20.0", "01.2.3", "0.20", "0.20.0; echo bad", "../main", "0.20.0-rc.1"]) {
    assert.throws(() => release.validateVersion(value));
  }
  for (const value of ["main", "HEAD", sha.slice(0, 12), `${sha}\n`]) {
    assert.throws(() => release.validateSHA(value));
  }
});

test("release requests use main or the matching maintenance branch", () => {
  release.validateReleaseRef(version, "refs/heads/main");
  release.validateReleaseRef(version, "refs/heads/release/0.20");
  for (const ref of ["refs/tags/0.20.0", "refs/heads/feature/test", "refs/heads/release/0.19"]) {
    assert.throws(() => release.validateReleaseRef(version, ref), /must run from/);
  }
});

test("every required check must succeed on the candidate SHA", () => {
  const results = Object.fromEntries(release.requiredChecks.map(name => [name, {
    result: "success", outputs: { "verified-sha": sha },
  }]));
  release.assertChecks(results, sha);
  for (const name of release.requiredChecks) {
    for (const result of ["failure", "cancelled", "skipped", undefined]) {
      const changed = structuredClone(results);
      changed[name].result = result;
      assert.throws(() => release.assertChecks(changed, sha), new RegExp(name));
    }
    const changed = structuredClone(results);
    delete changed[name];
    assert.throws(() => release.assertChecks(changed, sha), new RegExp(name));
    for (const candidate of [otherSHA, "", undefined]) {
      const changed = structuredClone(results);
      changed[name].outputs["verified-sha"] = candidate;
      assert.throws(() => release.assertChecks(changed, sha), new RegExp(name));
    }
  }
});

test("tag creation is idempotent and cannot move an existing tag", async () => {
  const mock = client();
  await release.ensureTag({ ...mock, repo, version, sha });
  await release.ensureTag({ ...mock, repo, version, sha });
  assert.deepEqual(mock.writes, [{ ...repo, ref: `refs/tags/${version}`, sha }]);
  await assert.rejects(release.ensureTag({ ...mock, repo, version, sha: otherSHA }), /already points/);
  assert.equal(mock.writes.length, 1);
});

test("annotated tags resolve to the commit they name", async () => {
  const mock = client();
  mock.github.rest.git.getRef = async () => ({ data: { object: { type: "tag", sha: otherSHA } } });
  mock.github.rest.git.getTag = async () => ({ data: { object: { type: "commit", sha } } });
  assert.equal(await release.getTagSHA(mock.github, repo, version), sha);
});

test("API errors cannot be mistaken for an absent tag", async () => {
  const mock = client();
  mock.github.rest.git.getRef = async () => { throw Object.assign(new Error("Forbidden"), { status: 403 }); };
  await assert.rejects(release.ensureTag({ ...mock, repo, version, sha }), /Forbidden/);
  assert.equal(mock.writes.length, 0);
});

test("release artifacts retain their version, SHA, and file digests", async t => {
  const directory = await artifacts(t);
  const manifest = await release.verifyManifest(directory, version, sha);
  assert.equal(Object.keys(manifest.files).length, 7);
  await assert.rejects(release.verifyManifest(directory, "0.21.0", sha), /version/);
  await assert.rejects(release.verifyManifest(directory, version, otherSHA), /SHA/);
  await fs.appendFile(path.join(directory, "OpenSwiftUI.xcframework.zip"), "changed");
  await assert.rejects(release.verifyManifest(directory, version, sha), /digest/);
});

test("missing artifacts prevent a release manifest", async t => {
  const directory = await artifacts(t);
  await fs.unlink(path.join(directory, "OpenSwiftUICore.xcframework.zip"));
  await assert.rejects(release.writeManifest(directory, version, sha), /ENOENT/);
});

test("publication requires an existing matching tag", async t => {
  const directory = await artifacts(t);
  for (const tag of [null, otherSHA]) {
    const mock = client({ tag });
    await assert.rejects(release.prepareRelease({ ...mock, repo, version, sha, directory }), /tag/i);
    assert.equal(mock.writes.length, 0);
  }
});

test("draft publication resumes without replacing matching assets", async t => {
  const directory = await artifacts(t);
  const mock = client({ tag: sha });
  const plan = await release.prepareRelease({ ...mock, repo, version, sha, directory });
  assert.equal(mock.writes[0].draft, true);
  assert.equal(plan.missing.length, 8);
  mock.assets.push({ name: plan.missing[0], state: "uploaded", digest: `sha256:${plan.files[plan.missing[0]]}` });
  const retry = await release.prepareRelease({ ...mock, repo, version, sha, directory });
  assert.equal(retry.missing.length, 7);
  await assert.rejects(release.publishRelease({ ...mock, repo, plan: retry }), /Missing/);
  for (const name of retry.missing) {
    mock.assets.push({ name, state: "uploaded", digest: `sha256:${retry.files[name]}` });
  }
  await release.publishRelease({ ...mock, repo, plan: retry });
  assert.equal(mock.writes.at(-1).draft, false);
  const writeCount = mock.writes.length;
  await release.publishRelease({ ...mock, repo, plan: retry });
  assert.equal(mock.writes.length, writeCount);
});

test("conflicting published assets are never overwritten", async t => {
  const directory = await artifacts(t);
  const mock = client({ tag: sha, published: true, assets: [
    { name: "OpenSwiftUI.xcframework.zip", state: "uploaded", digest: `sha256:${"0".repeat(64)}` },
  ] });
  await assert.rejects(release.prepareRelease({ ...mock, repo, version, sha, directory }), /digest/);
  assert.equal(mock.writes.length, 0);
});
