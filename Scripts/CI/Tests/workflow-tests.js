const assert = require("node:assert/strict");
const { execFileSync } = require("node:child_process");
const path = require("node:path");
const test = require("node:test");
const vm = require("node:vm");
const release = require("../release.js");

const names = ["release_checks", "release_create", "documentation"];
const workflows = Object.fromEntries(names.map(name => [name, JSON.parse(execFileSync("ruby", [
  "-ryaml", "-rjson", "-e", 'doc = YAML.load_file(ARGV[0]); puts JSON.generate(doc)',
  path.join(__dirname, "../../../.github/workflows", `${name}.yml`),
], { encoding: "utf8" }))]));
const sha = "a".repeat(40);
const otherSHA = "b".repeat(40);
const repo = { owner: "OpenSwiftUIProject", repo: "OpenSwiftUI" };

async function script(step, env, context = {}, github = {}, observations = {}) {
  const outputs = {};
  observations.warnings = [];
  observations.codeBlocks = [];
  const summary = {
    addHeading: () => summary, addTable: () => summary, addRaw: () => summary,
    addCodeBlock: value => { observations.codeBlocks.push(value); return summary; },
    write: async () => {},
  };
  await vm.runInNewContext(`(async () => { ${step.with.script}\n })()`, {
    require: () => release, process: { env }, context: { repo, sha, ref: "refs/heads/main", eventName: "workflow_dispatch", ...context }, github,
    core: { setOutput: (key, value) => { outputs[key] = value; }, warning: value => observations.warnings.push(value), summary },
  });
  return outputs;
}

test("pre-release covers all six check families at one SHA and all optional configurations", () => {
  const { jobs } = workflows.release_checks;
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

function canRun(jobId, results, overrides = {}, cancelled = false, github = { event_name: "workflow_dispatch", event: {} }) {
  const { jobs } = workflows.release_create;
  const job = jobs[jobId];
  const dependencies = [].concat(job.needs || []);
  const succeeded = id => results[id] === "success" && [].concat(jobs[id].needs || []).every(succeeded);
  const success = () => dependencies.every(succeeded);
  const defaults = workflows.release_create.true.workflow_dispatch.inputs;
  const inputs = { ...Object.fromEntries(Object.entries(defaults).map(([key, value]) => [key, value.default])), ...overrides };
  const needs = Object.fromEntries(dependencies.map(id => [id, { result: results[id] }]));
  const condition = (job.if || "success()").replace(/^\$\{\{\s*|\s*\}\}$/g, "");
  const value = vm.runInNewContext(condition, { inputs, needs, github, success, cancelled: () => cancelled });
  const hasStatusCheck = /\b(success|failure|cancelled|always)\s*\(/.test(condition);
  return Boolean(value && (hasStatusCheck || success()));
}

test("default release requests require successful checks without falling back to a bypass", () => {
  const results = { prepare: "success", checks: "success", build: "success", tag: "success", publish: "success" };
  assert.equal(canRun("checks", results), true);
  assert.equal(canRun("build", results), true);
  for (const checks of ["failure", "cancelled", "skipped", undefined]) {
    const changed = { ...results, checks };
    assert.equal(canRun("build", changed), false);
    assert.equal(canRun("tag", changed), false);
  }
});

test("explicit check skipping permits the complete publication chain", () => {
  const results = { prepare: "success", checks: "skipped", build: "success", tag: "success", publish: "success" };
  const inputs = { skip_checks: true };
  assert.equal(canRun("checks", results, inputs), false);
  for (const job of ["build", "tag", "publish", "documentation"]) {
    assert.equal(canRun(job, results, inputs), true, job);
    assert.equal(canRun(job, results, inputs, true), false, `${job} after cancellation`);
  }
  assert.equal(canRun("build", { ...results, prepare: "failure" }, inputs), false);
  assert.equal(canRun("tag", { ...results, build: "failure" }, inputs), false);
  assert.equal(canRun("publish", { ...results, tag: "failure" }, inputs), false);
  assert.equal(canRun("documentation", { ...results, publish: "failure" }, inputs), false);
});

test("skipping checks requires a reason and records the explicit bypass", async () => {
  const step = workflows.release_create.jobs.prepare.steps.find(step => step.id === "prepare");
  const env = {
    VERSION: "0.20.0", CHECKOUT_SHA: sha,
    HAS_SIGNING_CERTIFICATE: "true", HAS_SIGNING_PASSWORD: "true", HAS_BINARY_REPO_TOKEN: "true",
    SKIP_CHECKS: "true", SKIP_CHECKS_REASON: "",
  };
  let tagReads = 0;
  const github = { rest: { git: { getRef: async () => {
    tagReads++;
    throw Object.assign(new Error("Not found"), { status: 404 });
  } } } };
  for (const reason of ["", "   ", "\n"]) {
    await assert.rejects(script(step, { ...env, SKIP_CHECKS_REASON: reason }, {}, github), /reason/i);
  }
  assert.equal(tagReads, 0);
  const observations = {};
  const reason = "Runner failure fixed and verified in run 123.";
  assert.equal((await script(step, { ...env, SKIP_CHECKS_REASON: reason }, { actor: "maintainer" }, github, observations)).sha, sha);
  assert.equal(observations.warnings.length, 1);
  assert.deepEqual(observations.codeBlocks, [reason]);
  await script(step, { ...env, SKIP_CHECKS: "false", SKIP_CHECKS_REASON: "" }, {}, github, observations);
  assert.equal(observations.warnings.length, 0);
});

test("explicit check skipping still requires the candidate build and stored artifacts before tagging", async () => {
  const step = workflows.release_create.jobs.tag.steps.find(step => step.name === "Validate tag prerequisites");
  assert.ok(step);
  const env = { CANDIDATE_SHA: sha, VERIFIED_SHA: "", BUILT_SHA: sha, ARTIFACT_ID: "123", SKIP_CHECKS: "true" };
  await script(step, env);
  await assert.rejects(script(step, { ...env, SKIP_CHECKS: "false" }), /candidate commit/);
  for (const values of [{ BUILT_SHA: otherSHA }, { BUILT_SHA: "" }, { ARTIFACT_ID: "" }]) {
    await assert.rejects(script(step, { ...env, ...values }), /candidate commit/);
  }
});

test("pre-release cannot report success if a child workflow was skipped or checked another SHA", async () => {
  const step = workflows.release_checks.jobs.verify.steps.find(step => step.id === "verify");
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

test("release preflight needs only signing and binary credentials and rejects unsupported requests", async () => {
  const step = workflows.release_create.jobs.prepare.steps.find(step => step.id === "prepare");
  const env = {
    VERSION: "0.20.0", CHECKOUT_SHA: sha,
    HAS_SIGNING_CERTIFICATE: "true", HAS_SIGNING_PASSWORD: "true", HAS_BINARY_REPO_TOKEN: "true",
  };
  let tagReads = 0;
  const github = { rest: { git: { getRef: async () => {
    tagReads++;
    throw Object.assign(new Error("Not found"), { status: 404 });
  } } } };
  for (const key of ["HAS_SIGNING_CERTIFICATE", "HAS_SIGNING_PASSWORD", "HAS_BINARY_REPO_TOKEN"]) {
    await assert.rejects(script(step, { ...env, [key]: "" }, {}, github));
  }
  await assert.rejects(script(step, env, { ref: "refs/heads/feature/release" }, github), /must run from/);
  assert.equal(tagReads, 0);
  assert.equal((await script(step, env, {}, github)).sha, sha);
  assert.equal((await script(step, env, { ref: "refs/heads/release/0.20" }, github)).sha, sha);
  await assert.rejects(script(step, { ...env, CHECKOUT_SHA: otherSHA }, {}, github), /checked-out commit/i);
  await assert.rejects(script(step, { ...env, CHECKOUT_SHA: "" }, {}, github), /full commit SHA/);
});

test("tag pushes pin the checked-out commit for lightweight and annotated tags", async () => {
  const { steps } = workflows.release_create.jobs.prepare;
  const checkout = steps.find(step => step.uses === "actions/checkout@v4");
  const step = steps.find(step => step.id === "prepare");
  assert.equal(checkout.id, "checkout");
  assert.equal(checkout.with.ref, "${{ github.sha }}");
  assert.equal(step.env.CHECKOUT_SHA, "${{ steps.checkout.outputs.commit }}");
  const env = {
    VERSION: "0.20.0", CHECKOUT_SHA: sha,
    HAS_SIGNING_CERTIFICATE: "true", HAS_SIGNING_PASSWORD: "true", HAS_BINARY_REPO_TOKEN: "true",
  };
  for (const type of ["commit", "tag"]) {
    const eventSHA = type === "tag" ? otherSHA : sha;
    const github = { rest: { git: {
      getRef: async args => {
        assert.equal(args.ref, "tags/0.20.0");
        return { data: { object: { type, sha: eventSHA } } };
      },
      getTag: async args => {
        assert.equal(args.tag_sha, otherSHA);
        return { data: { object: { type: "commit", sha } } };
      },
    } } };
    const outputs = await script(step, env, { eventName: "push", ref: "refs/tags/0.20.0", sha: eventSHA }, github);
    assert.deepEqual(outputs, { version: "0.20.0", sha });
  }
});

test("tag preflight rejects missing or changed tags and invalid tag requests", async () => {
  const step = workflows.release_create.jobs.prepare.steps.find(step => step.id === "prepare");
  const env = {
    VERSION: "0.20.0", CHECKOUT_SHA: sha,
    HAS_SIGNING_CERTIFICATE: "true", HAS_SIGNING_PASSWORD: "true", HAS_BINARY_REPO_TOKEN: "true",
  };
  const context = { eventName: "push", ref: "refs/tags/0.20.0" };
  const github = { rest: { git: { getRef: async () => { throw Object.assign(new Error("Not found"), { status: 404 }); } } } };
  await assert.rejects(script(step, env, context, github), /no longer exists/i);
  github.rest.git.getRef = async () => ({ data: { object: { type: "commit", sha: otherSHA } } });
  await assert.rejects(script(step, env, context, github), /already points to/);
  for (const ref of ["refs/tags/0.21.0", "refs/heads/main"]) {
    await assert.rejects(script(step, env, { ...context, ref }, github), /version tag/i);
  }
  for (const version of ["v0.20.0", "0.20.0-rc.1", "00.20.0"]) {
    await assert.rejects(script(step, { ...env, VERSION: version }, { ...context, ref: `refs/tags/${version}` }, github), /stable version/i);
  }
  await assert.rejects(script(step, env, { ...context, eventName: "workflow_dispatch" }, github), /must run from/);
});

test("tag deletion skips preparation and tag pushes require the complete check gate", () => {
  const event = { event_name: "push", event: { deleted: false } };
  assert.equal(canRun("prepare", {}, {}, false, event), true);
  assert.equal(canRun("prepare", {}, {}, false, { ...event, event: { deleted: true } }), false);
  const results = { prepare: "success", checks: "success", build: "success", tag: "success", publish: "success" };
  const inputs = { skip_checks: undefined };
  for (const job of ["checks", "build", "tag", "publish", "documentation"]) {
    assert.equal(canRun(job, results, inputs, false, event), true, job);
  }
  for (const checks of ["failure", "cancelled", "skipped", undefined]) {
    assert.equal(canRun("build", { ...results, checks }, inputs, false, event), false);
    assert.equal(canRun("tag", { ...results, checks }, inputs, false, event), false);
  }
});

test("tag-triggered publication verifies the existing tag without recreating or moving it", async () => {
  const step = workflows.release_create.jobs.tag.steps.find(step => step.name === "Create or verify version tag");
  assert.ok(step);
  const env = { VERSION: "0.20.0", CANDIDATE_SHA: sha };
  let current = sha;
  const writes = [];
  const github = { rest: { git: {
    getRef: async () => {
      if (!current) throw Object.assign(new Error("Not found"), { status: 404 });
      return { data: { object: { type: "commit", sha: current } } };
    },
    createRef: async args => { writes.push(args); },
  } } };
  await script(step, env, { eventName: "push" }, github);
  for (const changed of [null, otherSHA]) {
    current = changed;
    await assert.rejects(script(step, env, { eventName: "push" }, github), /tag must still point to/i);
  }
  assert.equal(writes.length, 0);
  current = null;
  await script(step, env, {}, github);
  assert.deepEqual(writes, [{ ...repo, ref: "refs/tags/0.20.0", sha }]);
});

test("tagging has repository write permission and validates checks and artifacts before creating a tag", async () => {
  const { jobs } = workflows.release_create;
  assert.deepEqual(jobs.build.needs, ["prepare", "checks"]);
  assert.deepEqual(jobs.tag.needs, ["prepare", "checks", "build"]);
  assert.equal(jobs.tag.permissions.contents, "write");
  const gateIndex = jobs.tag.steps.findIndex(step => step.name === "Validate tag prerequisites");
  const tagIndex = jobs.tag.steps.findIndex(step => step.name === "Create or verify version tag");
  assert.ok(gateIndex >= 0 && gateIndex < tagIndex);
  const env = { CANDIDATE_SHA: sha, VERIFIED_SHA: sha, BUILT_SHA: sha, ARTIFACT_ID: "123" };
  await script(jobs.tag.steps[gateIndex], env);
  for (const key of ["VERIFIED_SHA", "BUILT_SHA", "ARTIFACT_ID"]) {
    await assert.rejects(script(jobs.tag.steps[gateIndex], { ...env, [key]: "" }), /candidate commit/);
  }
  await assert.rejects(script(jobs.tag.steps[gateIndex], { ...env, BUILT_SHA: otherSHA }), /candidate commit/);
});

test("tag pushes and manual requests share the release entry and version concurrency group", () => {
  const workflow = workflows.release_create;
  assert.deepEqual(Object.keys(workflow.true).sort(), ["push", "workflow_dispatch"]);
  assert.deepEqual(workflow.true.push, { tags: ["[0-9]+.[0-9]+.[0-9]+"] });
  const step = workflow.jobs.prepare.steps.find(step => step.id === "prepare");
  for (const bindings of [
    { inputs: { version: "0.20.0" }, github: { ref_name: "main" } },
    { inputs: {}, github: { ref_name: "0.20.0" } },
  ]) {
    const expand = text => text.replace(/\$\{\{(.*?)\}\}/g, (_, expression) => vm.runInNewContext(expression, bindings));
    assert.equal(expand(step.env.VERSION), "0.20.0");
    assert.equal(expand(workflow["run-name"]), "Release 0.20.0");
    assert.equal(expand(workflow.concurrency.group), "release-0.20.0");
  }
  assert.equal(workflow.concurrency["cancel-in-progress"], false);
  assert.deepEqual(Object.keys(workflows.documentation.true).sort(), ["workflow_call", "workflow_dispatch"]);
  assert.equal(workflows.release_create.jobs.documentation.uses, "./.github/workflows/documentation.yml");
  const deploy = workflows.documentation.jobs.deploy;
  assert.equal(deploy.needs, "build");
  assert.equal(vm.runInNewContext(deploy.if || "success()", { success: () => true }), true);
  assert.equal(vm.runInNewContext(deploy.if || "success()", { success: () => false }), false);
});
