import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import test from 'node:test';
import vm from 'node:vm';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../..');
const files = ['uitests', 'compatibility_tests', 'stdout_renderer', 'prepare_optional_ci'];
const workflows = Object.fromEntries(files.map(name => [name, JSON.parse(execFileSync('ruby', [
  '-ryaml', '-rjson', '-e',
  'doc = YAML.load_file(ARGV[0]); doc["on"] = doc.delete(true); puts JSON.generate(doc)',
  `${root}/.github/workflows/${name}.yml`,
], { encoding: 'utf8' }))]));
const prepare = workflows.prepare_optional_ci.jobs.prepare;
const repository = 'OpenSwiftUIProject/OpenSwiftUI';
const headSha = 'a'.repeat(40);
const dispatchSha = 'b'.repeat(40);
const contains = (haystack, needle) => Array.isArray(haystack)
  ? haystack.some(value => String(value).toLowerCase() === String(needle).toLowerCase())
  : String(haystack ?? '').toLowerCase().includes(String(needle).toLowerCase());
const expression = (source, bindings) => vm.runInNewContext(
  source.replace(/^\$\{\{\s*|\s*\}\}$/g, ''),
  { contains, fromJSON: JSON.parse, ...bindings },
);

async function scriptRun(script, context, env, pull) {
  const outputs = {};
  const statuses = [];
  const lookups = [];
  const warnings = [];
  await vm.runInNewContext(`(async () => { ${script}\n })()`, {
    context,
    process: { env: { GITHUB_SERVER_URL: 'https://github.com', ...env } },
    core: { setOutput: (name, value) => { outputs[name] = value; }, warning: value => warnings.push(value) },
    github: { rest: {
      pulls: { get: async args => { lookups.push(args); return { data: pull }; } },
      repos: { createCommitStatus: async args => { statuses.push(args); } },
    } },
  });
  return JSON.parse(JSON.stringify({ outputs, statuses, lookups, warnings }));
}

async function request(workflowName, options = {}) {
  const workflow = workflows[workflowName];
  const caller = Object.values(workflow.jobs).find(job => job.uses);
  const command = caller.with.command;
  const comment = {
    body: options.body ?? command,
    author_association: options.association ?? 'OWNER',
    user: { login: 'maintainer' },
  };
  const context = {
    repo: { owner: 'OpenSwiftUIProject', repo: 'OpenSwiftUI' },
    eventName: options.event ?? 'issue_comment',
    payload: options.payload ?? { issue: { number: 42, ...(options.issue ? {} : { pull_request: {} }) }, comment },
    sha: dispatchSha,
    runId: 123,
  };
  const inputs = { ref: options.ref ?? '', command, target: options.target ?? 'all', 'status-contexts': caller.with['status-contexts'] };
  const admitted = Boolean(expression(prepare.if, {
    github: { event_name: context.eventName, event: context.payload }, inputs,
  }));
  const pull = {
    state: options.closed ? 'closed' : 'open',
    head: { sha: headSha, repo: options.deleted ? null : { full_name: options.fork ? 'contributor/OpenSwiftUI' : repository } },
  };
  const result = await scriptRun(prepare.steps[0].with.script, context, {
    REQUESTED_REF: inputs.ref, COMMAND: command, TARGET: inputs.target, STATUS_CONTEXTS: inputs['status-contexts'],
  }, pull);
  return { ...result, admitted, context, caller };
}

function expandMatrix(matrix, targets) {
  const axes = Object.entries(matrix).filter(([key]) => key !== 'include' && key !== 'exclude');
  const base = axes.reduce((rows, [key, values]) => rows.flatMap(row =>
    (key === 'backend' ? targets : values).map(value => ({ ...row, [key]: value }))
  ), [{}]);
  const rows = base.map(row => ({ ...row }));
  for (const extra of matrix.include ?? []) {
    const matches = base.flatMap((row, index) =>
      Object.keys(row).every(key => !(key in extra) || row[key] === extra[key]) ? [index] : []
    );
    if (matches.length === 0) rows.push(extra);
    else for (const index of matches) Object.assign(rows[index], extra);
  }
  return rows;
}

test('pushes and PR updates cannot start any optional workflow', () => {
  for (const name of files.slice(0, 3)) {
    assert.deepEqual(Object.keys(workflows[name].on).sort(), ['issue_comment', 'workflow_call', 'workflow_dispatch']);
    assert.deepEqual(workflows[name].on.issue_comment.types, ['created']);
  }
});

for (const name of ['compatibility_tests', 'stdout_renderer']) {
  const workflow = workflows[name];
  const caller = Object.values(workflow.jobs).find(job => job.uses);
  const command = caller.with.command;
  const contexts = JSON.parse(caller.with['status-contexts']);
  const targetNames = Object.keys(contexts);

  for (const target of ['all', ...targetNames]) {
    for (const event of ['issue_comment', 'workflow_dispatch']) {
      test(`${name}: ${event} selects ${target} and pins the correct commit`, async () => {
        const result = await request(name, { event, body: `  ${command}\t${target.toUpperCase()} \n`, target });
        const selected = target === 'all' ? targetNames : [target];
        assert.equal(result.admitted, true);
        assert.deepEqual(JSON.parse(result.outputs.targets), selected);
        assert.equal(result.outputs.repository, repository);
        assert.equal(result.outputs.ref, event === 'issue_comment' ? headSha : dispatchSha);
        assert.equal(result.lookups.length, event === 'issue_comment' ? 1 : 0);
        assert.deepEqual(result.statuses.map(status => status.context), event === 'issue_comment' ? selected.map(id => contexts[id]) : []);
        for (const status of result.statuses) {
          assert.equal(status.sha, headSha);
          assert.equal(status.state, 'pending');
          assert.equal(status.target_url, `https://github.com/${repository}/actions/runs/123`);
        }
      });
    }
  }

  for (const options of [
    { association: 'NONE' }, { association: 'CONTRIBUTOR' }, { association: 'FIRST_TIME_CONTRIBUTOR' },
    { issue: true }, { event: 'push' }, { event: 'pull_request' }, { body: 'Looks good' },
  ]) {
    test(`${name}: rejects unrelated or untrusted event ${JSON.stringify(options)}`, async () => {
      const result = await request(name, options);
      assert.equal(result.admitted, false);
      assert.equal(result.outputs.targets, '[]');
      assert.equal(result.lookups.length, 0);
      assert.equal(result.statuses.length, 0);
    });
  }

  for (const suffix of ['-extra', ' invalid', ' all extra', ' all\nplease run this', ' $(touch /tmp/ci-probe)']) {
    test(`${name}: rejects malformed command ${suffix}`, async () => {
      const result = await request(name, { body: command + suffix });
      assert.equal(result.outputs.targets, '[]');
      assert.equal(result.outputs.ref, '');
      assert.equal(result.lookups.length, 0);
      assert.equal(result.statuses.length, 0);
    });
  }

  for (const association of ['OWNER', 'MEMBER', 'COLLABORATOR']) {
    test(`${name}: permits ${association} to request a fork commit without statuses`, async () => {
      const result = await request(name, { association, fork: true });
      assert.equal(result.admitted, true);
      assert.equal(result.outputs.repository, 'contributor/OpenSwiftUI');
      assert.equal(result.outputs.ref, headSha);
      assert.equal(result.outputs['status-enabled'], 'false');
      assert.deepEqual(JSON.parse(result.outputs.targets), targetNames);
      assert.equal(result.statuses.length, 0);
    });
  }

  for (const options of [{ closed: true }, { deleted: true }]) {
    test(`${name}: rejects unavailable PR ${JSON.stringify(options)}`, async () => {
      const result = await request(name, options);
      assert.equal(result.outputs.targets, '[]');
      assert.equal(result.outputs.ref, '');
      assert.equal(result.statuses.length, 0);
    });
  }

  for (const [jobName, job] of Object.entries(workflow.jobs).filter(([, job]) => !job.uses)) {
    for (const state of ['success', 'failure', 'cancelled']) {
      test(`${jobName}: reports ${state} on the resolved PR commit`, async () => {
        const step = job.steps.find(step => step.name === 'Complete PR status');
        assert.match(step.if, /always\(\)/);
        const result = await scriptRun(step.with.script, {
          repo: { owner: 'OpenSwiftUIProject', repo: 'OpenSwiftUI' }, runId: 123,
        }, { STATUS_SHA: headSha, STATUS_CONTEXT: job.env.STATUS_CONTEXT, JOB_STATUS: state });
        assert.equal(result.statuses.length, 1);
        assert.equal(result.statuses[0].sha, headSha);
        assert.equal(result.statuses[0].state, state === 'cancelled' ? 'error' : state);
        assert.equal(result.statuses[0].context, job.env.STATUS_CONTEXT);
      });
    }
  }
}

for (const backend of ['AttributeGraph', 'Compute']) {
  test(`Stdout Renderer single backend request runs only ${backend}`, async () => {
    const result = await request('stdout_renderer', { body: `/stdout-renderer ${backend}` });
    const matrix = workflows.stdout_renderer.jobs.stdout_renderer_macos.strategy.matrix;
    const rows = expandMatrix(matrix, JSON.parse(result.outputs.targets));
    assert.deepEqual(rows.map(row => row.backend), [backend]);
    assert.equal(rows[0].os, 'macos-15');
    assert.equal(rows[0]['xcode-version'], '26.6');
    const env = workflows.stdout_renderer.jobs.stdout_renderer_macos.env;
    assert.equal(expression(env.OPENSWIFTUI_OPENATTRIBUTESHIMS_ATTRIBUTEGRAPH, { matrix: rows[0] }), backend === 'AttributeGraph' ? '1' : '0');
    assert.equal(expression(env.OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE, { matrix: rows[0] }), backend === 'Compute' ? '1' : '0');
  });
}

test('compatibility platform selection gates jobs and checkout uses the resolved PR head', async () => {
  const workflow = workflows.compatibility_tests;
  for (const platform of ['ios', 'macos', 'all']) {
    const result = await request('compatibility_tests', { body: `/compatibilitytest ${platform}` });
    const needs = { prepare_compatibility_tests: { outputs: result.outputs } };
    for (const job of [workflow.jobs.compatibility_tests_ios, workflow.jobs.compatibility_tests_macos]) {
      assert.equal(Boolean(expression(job.if, { needs })), platform === 'all' || job.name.endsWith(platform === 'ios' ? 'iOS' : 'macOS'));
      const checkout = job.steps.find(step => step.uses === 'actions/checkout@v4');
      assert.equal(expression(checkout.with.repository, { needs }), repository);
      assert.equal(expression(checkout.with.ref, { needs }), headSha);
    }
  }
  for (const job of [workflow.jobs.compatibility_tests_ios, workflow.jobs.compatibility_tests_macos]) {
    assert.equal(Boolean(expression(job.if, { needs: { prepare_compatibility_tests: { outputs: {} } } })), false);
  }
});

test('reusable workflow outputs reach callers through the prepare job', () => {
  const outputs = workflows.prepare_optional_ci.on.workflow_call.outputs;
  for (const key of ['repository', 'ref', 'targets', 'status-enabled']) {
    assert.equal(outputs[key].value, '${{ jobs.prepare.outputs.' + key + ' }}');
    assert.equal(prepare.outputs[key], '${{ steps.prepare.outputs.' + key + ' }}');
  }
});

test('UI dispatch and existing comment options still work; pushes no longer request tests', async () => {
  const job = workflows.uitests.jobs.prepare_uitests;
  const context = {
    repo: { owner: 'OpenSwiftUIProject', repo: 'OpenSwiftUI' }, runId: 123,
    sha: dispatchSha, eventName: 'workflow_dispatch', payload: { inputs: { platform: 'ios', configuration: 'openswiftui-renderer-iag', update_reference: 'true' } },
  };
  let result = await scriptRun(job.steps[0].with.script, context, { PLATFORM: 'ios', CONFIGURATION: 'openswiftui-renderer-iag', UPDATE_REFERENCE: 'true' });
  assert.equal(result.outputs['ios-requested'], 'true');
  assert.equal(result.outputs['macos-requested'], 'false');
  assert.equal(result.outputs['update-reference'], 'true');
  assert.equal(JSON.parse(result.outputs['configuration-matrix'])[0].id, 'openswiftui-renderer-iag');
  context.eventName = 'push';
  result = await scriptRun(job.steps[0].with.script, context, {});
  assert.equal(result.outputs['ios-requested'], 'false');
  assert.equal(result.outputs['macos-requested'], 'false');
  for (const body of ['/uitest', '/uitest ios', '/uitest macos osui-iag', '/uitest all all-configs', '/uitest ios config=openswiftui-renderer-iag', '/uitest macos update osui-ag']) {
    context.eventName = 'issue_comment';
    context.payload = { issue: { number: 42, pull_request: {} }, comment: { body, author_association: 'MEMBER', user: { login: 'maintainer' } } };
    assert.equal(Boolean(expression(job.if, { inputs: { ref: '' }, github: { event_name: context.eventName, event: context.payload } })), true);
    result = await scriptRun(job.steps[0].with.script, context, {}, { head: { repo: { full_name: repository }, sha: headSha } });
    assert.equal(result.outputs.ref, headSha);
    assert.equal(result.outputs['status-enabled'], 'true');
    assert.ok(result.statuses.length > 0);
  }
});

for (const name of ['compatibility_tests', 'stdout_renderer']) {
  for (const event of ['workflow_dispatch', 'push']) {
    test(`${name}: reusable calls from ${event} use the supplied SHA and run every target`, async () => {
      const options = { event, ref: headSha, payload: event === 'push' ? { ref: 'refs/tags/0.20.0' } : { inputs: { version: '0.20.0' } } };
      const result = await request(name, options);
      assert.equal(result.admitted, true);
      assert.equal(result.outputs.ref, headSha);
      assert.equal(JSON.parse(result.outputs.targets).length, 2);
      assert.equal(result.outputs['status-enabled'], 'false');
      assert.equal(result.lookups.length, 0);
      await assert.rejects(request(name, { ...options, ref: headSha + '\n' }), /full commit SHA/);
    });
  }

  test(`${name}: a reusable ref cannot bypass comment authorization`, async () => {
    const result = await request(name, { association: 'NONE', ref: headSha });
    assert.equal(result.admitted, false);
    assert.equal(result.outputs.targets, '[]');
    assert.equal(result.statuses.length, 0);
  });
}

for (const event of ['workflow_dispatch', 'push']) {
  test(`reusable UI checks use their own inputs despite the caller ${event} payload`, async () => {
    const job = workflows.uitests.jobs.prepare_uitests;
    const context = {
      repo: { owner: 'OpenSwiftUIProject', repo: 'OpenSwiftUI' }, sha: dispatchSha,
      eventName: event,
      payload: event === 'push' ? { ref: 'refs/tags/0.20.0' } : { inputs: { version: '0.20.0', platform: 'ios', update_reference: 'true' } },
    };
    const env = { REQUESTED_REF: headSha, PLATFORM: 'all', CONFIGURATION: 'all', UPDATE_REFERENCE: 'false' };
    assert.equal(Boolean(expression(job.if, { inputs: { ref: headSha }, github: { event_name: event, event: context.payload } })), true);
    const result = await scriptRun(job.steps[0].with.script, context, env);
    assert.equal(result.outputs.ref, headSha);
    assert.equal(result.outputs['ios-requested'], 'true');
    assert.equal(result.outputs['macos-requested'], 'true');
    assert.equal(result.outputs['update-reference'], 'false');
    assert.equal(JSON.parse(result.outputs['configuration-matrix']).length, 4);
    assert.equal(result.statuses.length, 0);
    await assert.rejects(scriptRun(job.steps[0].with.script, context, { ...env, REQUESTED_REF: 'main' }), /full commit SHA/);
  });
}
