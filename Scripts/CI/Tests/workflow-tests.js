const assert = require("node:assert/strict");
const { execFileSync } = require("node:child_process");
const path = require("node:path");
const test = require("node:test");
const vm = require("node:vm");
const release = require("../release.js");

const names = ["pre_release", "create_release", "release", "documentation"];
const workflows = Object.fromEntries(names.map(name => [name, JSON.parse(execFileSync("ruby", [
  "-ryaml", "-rjson", "-e", 'doc = YAML.load_file(ARGV[0]); puts JSON.generate(doc)',
  path.join(__dirname, "../../../.github/workflows", `${name}.yml`),
], { encoding: "utf8" }))]));
const sha = "a".repeat(40);
const otherSHA = "b".repeat(40);
const repo = { owner: "OpenSwiftUIProject", repo: "OpenSwiftUI" };

async function script(step, env, context = {}, github = {}) {
  const outputs = {};
  const summary = { addHeading: () => summary, addTable: () => summary, addRaw: () => summary, write: async () => {} };
  await vm.runInNewContext(`(async () => { ${step.with.script}\n })()`, {
    require: () => release, process: { env }, context: { repo, sha, ref: "refs/heads/main", ...context }, github,
    core: { setOutput: (key, value) => { outputs[key] = value; }, summary },
  });
  return outputs;
}

test("pre-release covers all six check families at one SHA and all optional configurations", () => {
  const { jobs } = workflows.pre_release;
  assert.deepEqual(jobs.verify.needs, ["prepare", ...release.requiredChecks]);
  assert.equal(jobs.verify.if, "always()");
  for (const name of release.requiredChecks) {
    assert.equal(jobs[name].with.ref, "${{ needs.prepare.outputs.sha }}");
    assert.equal(jobs[name].needs, "prepare");
  }
  assert.equal(jobs.ui.with.platform, "all");
  assert.equal(jobs.ui.with.configuration, "all");
  assert.equal(jobs.ui.with.update_reference, false);
  assert.equal(jobs.compatibility.with.platform, "all");
  assert.equal(jobs.stdout.with.backend, "all");
});

test("pre-release cannot report success if a child workflow was skipped or checked another SHA", async () => {
  const step = workflows.pre_release.jobs.verify.steps.find(step => step.id === "verify");
  const results = Object.fromEntries(release.requiredChecks.map(name => [name, {
    result: "success", outputs: { "verified-sha": sha },
  }]));
  const run = () => script(step, { CANDIDATE_SHA: sha, CHECK_RESULTS: JSON.stringify(results) });
  assert.equal((await run()).sha, sha);
  results.ui.result = "skipped";
  await assert.rejects(run(), /ui/);
  results.ui.result = "success";
  results.stdout.outputs["verified-sha"] = otherSHA;
  await assert.rejects(run(), /stdout/);
});

test("release preflight rejects disabled configuration and unsupported refs before expensive work", async () => {
  const step = workflows.create_release.jobs.prepare.steps.find(step => step.id === "prepare");
  const env = {
    VERSION: "0.20.0", PIPELINE_ENABLED: "true", APP_ID: "123",
    HAS_APP_KEY: "true", HAS_SIGNING_CERTIFICATE: "true", HAS_SIGNING_PASSWORD: "true", HAS_BINARY_REPO_TOKEN: "true",
  };
  let tagReads = 0;
  const github = { rest: { git: { getRef: async () => {
    tagReads++;
    throw Object.assign(new Error("Not found"), { status: 404 });
  } } } };
  for (const key of ["PIPELINE_ENABLED", "APP_ID", "HAS_APP_KEY", "HAS_SIGNING_CERTIFICATE", "HAS_SIGNING_PASSWORD", "HAS_BINARY_REPO_TOKEN"]) {
    await assert.rejects(script(step, { ...env, [key]: "" }, {}, github));
  }
  await assert.rejects(script(step, env, { ref: "refs/heads/feature/release" }, github), /must run from/);
  assert.equal(tagReads, 0);
  assert.equal((await script(step, env, {}, github)).sha, sha);
  assert.equal((await script(step, env, { ref: "refs/heads/release/0.20" }, github)).sha, sha);
});

test("tagging requires matching check and build results before creating the App token", async () => {
  const { jobs } = workflows.create_release;
  assert.deepEqual(jobs.build.needs, ["prepare", "checks"]);
  assert.deepEqual(jobs.tag.needs, ["prepare", "checks", "build"]);
  const gateIndex = jobs.tag.steps.findIndex(step => step.name === "Require matching checks and artifacts");
  const tokenIndex = jobs.tag.steps.findIndex(step => step.id === "app-token");
  assert.ok(gateIndex < tokenIndex);
  const env = { CANDIDATE_SHA: sha, VERIFIED_SHA: sha, BUILT_SHA: sha, ARTIFACT_ID: "123" };
  await script(jobs.tag.steps[gateIndex], env);
  for (const key of ["VERIFIED_SHA", "BUILT_SHA", "ARTIFACT_ID"]) {
    await assert.rejects(script(jobs.tag.steps[gateIndex], { ...env, [key]: "" }), /candidate commit/);
  }
  await assert.rejects(script(jobs.tag.steps[gateIndex], { ...env, BUILT_SHA: otherSHA }), /candidate commit/);
});

test("the rollout flag disables legacy tag publication while retaining explicit documentation runs", () => {
  for (const flag of ["", "false", "true"]) {
    const bindings = { vars: { RELEASE_PIPELINE_ENABLED: flag }, github: { event_name: "push" } };
    assert.equal(vm.runInNewContext(workflows.release.jobs.prepare.if, bindings), flag !== "true");
    assert.equal(vm.runInNewContext(workflows.documentation.jobs.build.if, bindings), flag !== "true");
    bindings.github.event_name = "workflow_dispatch";
    assert.equal(vm.runInNewContext(workflows.documentation.jobs.build.if, bindings), true);
  }
});
