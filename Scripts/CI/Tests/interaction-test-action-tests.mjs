import assert from 'node:assert/strict';
import { execFileSync, spawnSync } from 'node:child_process';
import fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import vm from 'node:vm';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../..');
const loadAction = name => JSON.parse(execFileSync('ruby', [
  '-ryaml', '-rjson', '-e', 'puts JSON.generate(YAML.load_file(ARGV[0]))',
  `${root}/.github/actions/${name}/action.yml`,
], { encoding: 'utf8' }));
const action = loadAction('uitests');
const interactionAction = loadAction('interactiontests');
const evaluate = (source, bindings) => vm.runInNewContext(
  source.replace(/\.([A-Za-z_][\w-]*-[\w-]+)/g, (_, name) => `[${JSON.stringify(name)}]`),
  { always: () => true, ...bindings },
);
const expand = (source, bindings) => String(source).replace(/\$\{\{(.*?)\}\}/g, (_, expression) => evaluate(expression, bindings));
const defaults = action => Object.fromEntries(Object.entries(action.inputs).map(([key, value]) => [key, value.default ?? '']));
const schemes = ['SUI_InteractionTests', 'OSUI_InteractionTests'];
const destination = 'platform=iOS Simulator,OS=18.5,name=iPhone 16 Pro';
const recordingFailure = {
  failureText: 'Issue recorded: Record mode is on. Automatically recorded snapshot: …',
};
const recordingSummary = {
  totalTestCount: 1,
  skippedTests: 0,
  failedTests: 1,
  testFailures: [recordingFailure],
};

test('interaction verification does not record SwiftUI references without update', async t => {
  const result = await runTests(t);
  assert.equal(result.status, 0, result.stdout + result.stderr);
  assert.deepEqual(result.commands.map(args => args[args.indexOf('-scheme') + 1]), ['OSUI_InteractionTests']);
});

test('missing interaction references do not start recording without update', async t => {
  const result = await runTests(t, { OSUI_InteractionTests: { status: 65 } }, { references: false });
  assert.equal(result.status, 1, result.stdout + result.stderr);
  assert.deepEqual(result.commands.map(args => args[args.indexOf('-scheme') + 1]), ['OSUI_InteractionTests']);
  assert.equal(result.steps['record-baseline'].outcome, 'skipped');
});

test('verification reports missing references from every parameter case', async t => {
  const missingReference = 'No reference was found on disk. New snapshot was not recorded because recording is disabled';
  const result = await runTests(t, {
    OSUI_InteractionTests: {
      status: 1,
      summary: {
        totalTestCount: 1, skippedTests: 0, failedTests: 1,
        testFailures: [{ failureText: 'Expectation failed: count == 1' }],
      },
      testTree: {
        testNodes: [{
          nodeType: 'Test Case', result: 'Failed', children: [
            { nodeType: 'Arguments', name: '1', result: 'Failed', children: [
              { nodeType: 'Failure Message', name: 'TapGestureInteractionTests.swift:40: Expectation failed: count == 1' },
            ] },
            { nodeType: 'Arguments', name: '2', result: 'Failed', children: [
              { nodeType: 'Failure Message', name: `TapGestureInteractionTests.swift:41: Issue recorded: ${missingReference}` },
            ] },
          ],
        }],
      },
    },
  });
  assert.equal(result.status, 1, result.stdout + result.stderr);
  const output = result.stdout + result.stderr;
  assert.match(output, /Expectation failed: count == 1/);
  assert.ok(output.includes(missingReference));
  assert.match(output, /update_reference=true/);
  assert.deepEqual(result.commands.map(args => args[args.indexOf('-scheme') + 1]), ['OSUI_InteractionTests']);
});

test('verification preserves a command failure when its result summary passes', async t => {
  const result = await runTests(t, {
    OSUI_InteractionTests: { status: 1 },
  });
  assert.equal(result.status, 1, result.stdout + result.stderr);
  assert.match(result.stdout, /Executed 1 UI test\(s\)/);
});

test('SwiftUI recording accepts Tuist exit status 1 only for recording issues', async t => {
  const result = await runTests(t, {
    SUI_InteractionTests: { status: 1 },
  }, { update: true });
  assert.equal(result.status, 0, result.stdout + result.stderr);
  assert.deepEqual(result.commands.map(args => args[args.indexOf('-scheme') + 1]), schemes);
  assert.match(result.stdout, /Accepted 1 snapshot recording issue\(s\)/);
});

for (const nodeType of ['Test Case', 'Arguments']) {
  test(`SwiftUI recording ignores skipped and expected-failure ${nodeType} nodes`, async t => {
    const nodes = [
      { nodeType, name: 'skipped', result: 'Skipped', children: [
        { nodeType: 'Failure Message', name: 'Test skipped: Text is not supported yet' },
      ] },
      { nodeType, name: 'known issue', result: 'Expected Failure', children: [
        { nodeType: 'Failure Message', name: 'clipShape rect bug' },
      ] },
      { nodeType, name: 'recorded', result: 'Failed', children: [
        { nodeType: 'Failure Message', name: recordingFailure.failureText },
      ] },
    ];
    const result = await runTests(t, {
      SUI_InteractionTests: {
        summary: nodeType === 'Test Case'
          ? { ...recordingSummary, totalTestCount: 3, skippedTests: 1, expectedFailures: 1 }
          : recordingSummary,
        testTree: { testNodes: nodeType === 'Test Case' ? nodes : [
          { nodeType: 'Test Case', result: 'Failed', children: nodes },
        ] },
      },
    }, { update: true });
    assert.equal(result.status, 0, result.stdout + result.stderr);
    assert.deepEqual(result.commands.map(args => args[args.indexOf('-scheme') + 1]), schemes);
    assert.match(result.stdout, /Accepted 1 snapshot recording issue\(s\)/);
  });
}

test('verification reports real failures without skipped or expected-failure messages', async t => {
  const result = await runTests(t, {
    OSUI_InteractionTests: {
      status: 1,
      summary: { ...recordingSummary, testFailures: [{ failureText: 'Expectation failed: count == 1' }] },
      testTree: {
        testNodes: [{
          nodeType: 'Test Case', result: 'Failed', children: [
            { nodeType: 'Arguments', result: 'Skipped', children: [
              { nodeType: 'Failure Message', name: 'Test skipped: Text is not supported yet' },
            ] },
            { nodeType: 'Arguments', result: 'Expected Failure', children: [
              { nodeType: 'Failure Message', name: 'clipShape rect bug' },
            ] },
            { nodeType: 'Arguments', result: 'Failed', children: [
              { nodeType: 'Failure Message', name: 'Expectation failed: count == 1' },
            ] },
          ],
        }],
      },
    },
  });
  assert.equal(result.status, 1, result.stdout + result.stderr);
  const output = result.stdout + result.stderr;
  assert.match(output, /Expectation failed: count == 1/);
  assert.doesNotMatch(output, /Test skipped|clipShape rect bug/);
});

test('SwiftUI recording rejects real test failures behind Tuist exit status 1', async t => {
  const result = await runTests(t, {
    SUI_InteractionTests: {
      status: 1,
      summary: { ...recordingSummary, testFailures: [recordingFailure, { failureText: 'Expectation failed: count == 1' }] },
    },
  }, { update: true });
  assert.equal(result.status, 1, result.stdout + result.stderr);
  assert.equal(result.steps.uitest.outcome, 'skipped');
  assert.match(result.stdout + result.stderr, /Unexpected failure during snapshot recording.*Expectation failed: count == 1/);
});

test('update records even when persistent interaction references already exist', async t => {
  const result = await runTests(t, {}, { update: true, references: true });
  assert.equal(result.status, 0, result.stdout + result.stderr);
  assert.deepEqual(result.commands.map(args => args[args.indexOf('-scheme') + 1]), schemes);
});

test('recording and verification receive the same case-sensitive test selection', async t => {
  const onlyTesting = 'OpenSwiftUIInteractionTests/TapGestureInteractionTests/snapshotsBeforeAndAfterTap(tapCount:)';
  const result = await runTests(t, {}, { update: true, onlyTesting });
  assert.equal(result.status, 0, result.stdout + result.stderr);
  for (const args of result.commands) assert.ok(args.includes(`-only-testing:${onlyTesting}`));
});

test('a selected interaction test can update successfully without producing snapshots', async t => {
  const result = await runTests(t, {
    SUI_InteractionTests: {
      status: 0, missingReferences: true,
      summary: { totalTestCount: 1, skippedTests: 0, failedTests: 0 },
    },
  }, { update: true, onlyTesting: 'OpenSwiftUIInteractionTests/ObservationInteractionTests' });
  assert.equal(result.status, 0, result.stdout + result.stderr);
});

test('macOS reference paths include all three version components', async t => {
  const result = await runTests(t, {}, { platform: 'macos' });
  assert.equal(result.status, 0, result.stdout + result.stderr);
  assert.equal(result.steps.reference.outputs.directory, path.join(result.referenceRoot, 'macOS/26.6.0/OpenSwiftUIInteractionTests'));
});

test('recording releases its own lock but preserves another owner', async t => {
  const result = await runTests(t, { SUI_InteractionTests: { replaceLock: true } }, { update: true });
  assert.equal(result.status, 0, result.stdout + result.stderr);
  assert.equal(await fs.readFile(result.steps.reference.outputs.lockfile, 'utf8'), 'another recorder');
});

for (const references of [true, false]) {
  test(`UI keeps automatic recording for missing references: cached=${references}`, async t => {
    const result = await runTests(t, {}, { suite: 'UITests', references, compute: false });
    assert.equal(result.status, 0, result.stdout + result.stderr);
    assert.deepEqual(result.commands.map(args => args[args.indexOf('-scheme') + 1]), references ? ['OSUI_UITests'] : ['SUI_UITests', 'OSUI_UITests']);
    for (const args of result.commands) assert.deepEqual(args.slice(0, 3), ['exec', '--', 'tuist']);
  });
}

async function runTests(t, fixtures = {}, options = {}) {
  const directory = await fs.mkdtemp(path.join(os.tmpdir(), 'openswiftui-snapshot tests-'));
  t.after(() => fs.rm(directory, { recursive: true, force: true }));
  const bin = path.join(directory, 'bin');
  const referenceRoot = path.join(directory, 'Persistent references');
  const commandLog = path.join(directory, 'commands.jsonl');
  const simulatorLog = path.join(directory, 'simulator-commands.jsonl');
  const simulatorState = path.join(directory, 'simulators.json');
  await fs.writeFile(simulatorLog, '');
  await fs.writeFile(simulatorState, '[]');
  const suite = options.suite ?? 'InteractionTests';
  const platform = options.platform ?? 'ios';
  const snapshotPlatform = platform === 'ios' ? 'iOS_Simulator' : 'macOS';
  const snapshotVersion = platform === 'ios' ? '18.5.0' : '26.6.0';
  await fs.mkdir(bin);
  await fs.writeFile(commandLog, '');
  await fs.writeFile(path.join(bin, 'sw_vers'), '#!/bin/sh\necho 26.6\n', { mode: 0o755 });
  const referenceDirectory = path.join(referenceRoot, snapshotPlatform, snapshotVersion, `OpenSwiftUI${suite}`, 'TapGestureInteractionTests.swift');
  if (options.references ?? !options.update) {
    await fs.mkdir(referenceDirectory, { recursive: true });
    await fs.writeFile(path.join(referenceDirectory, 'initial.png'), 'existing reference');
  }
  await fs.writeFile(path.join(bin, 'mise'), `#!/usr/bin/env node
const fs = require('node:fs');
const path = require('node:path');
const args = process.argv.slice(2);
fs.appendFileSync(process.env.INTERACTION_TEST_COMMAND_LOG, JSON.stringify(args) + '\\n');
const scheme = args[args.indexOf('-scheme') + 1];
const result = args[args.indexOf('-resultBundlePath') + 1];
const fixture = JSON.parse(process.env.INTERACTION_TEST_FIXTURES)[scheme] ?? {};
const recording = scheme.startsWith('SUI_');
const referenceRoot = process.env.TEST_RUNNER_SNAPSHOT_REFERENCE_DIR;
fs.writeFileSync(path.join(path.dirname(result), scheme + '-environment.json'), JSON.stringify({ referenceRoot }));
console.log('Executed ' + scheme);
if (!fixture.missingResult) {
  fs.mkdirSync(result, { recursive: true });
  const summary = fixture.summary ?? (recording
    ? JSON.parse(process.env.INTERACTION_TEST_RECORDING_SUMMARY)
    : { totalTestCount: 1, skippedTests: 0, failedTests: 0, testFailures: [] });
  fs.writeFileSync(path.join(result, 'summary.json'), JSON.stringify(summary));
  const testTree = fixture.testTree ?? {
    testNodes: [{
      nodeType: 'Test Case',
      name: 'snapshotsBeforeAndAfterTap(tapCount:)',
      result: summary.failedTests > 0 ? 'Failed' : 'Passed',
      children: (summary.testFailures ?? []).map(failure => ({
        nodeType: 'Failure Message',
        name: 'TapGestureInteractionTests.swift:50: ' + failure.failureText,
      })),
    }],
  };
  fs.writeFileSync(path.join(result, 'tests.json'), JSON.stringify(testTree));
}
if (recording && referenceRoot && !fixture.missingReferences) {
  const referenceDirectory = path.join(referenceRoot, process.env.SNAPSHOT_PLATFORM, process.env.SNAPSHOT_VERSION, 'OpenSwiftUI' + process.env.TEST_SUITE, 'TapGestureInteractionTests.swift');
  fs.mkdirSync(referenceDirectory, { recursive: true });
  fs.writeFileSync(path.join(referenceDirectory, 'initial.png'), 'reference fixture');
}
if (fixture.replaceLock) fs.writeFileSync(path.join(referenceRoot, process.env.SNAPSHOT_PLATFORM, '.lock'), 'another recorder');
process.exit(fixture.status ?? (recording ? 65 : 0));
`, { mode: 0o755 });
  await fs.writeFile(path.join(bin, 'xcrun'), `#!/usr/bin/env node
const fs = require('node:fs');
const path = require('node:path');
const args = process.argv.slice(2);
if (args[0] === 'simctl') {
  fs.appendFileSync(process.env.SIMULATOR_LOG, JSON.stringify(args) + '\\n');
  const statePath = process.env.SIMULATOR_STATE;
  const devices = JSON.parse(fs.readFileSync(statePath));
  const runtime = 'com.apple.CoreSimulator.SimRuntime.iOS-18-5';
  const testing = args[1] === '--set';
  const command = args[testing ? 3 : 1];
  const parameters = args.slice(testing ? 4 : 2);
  if (command === 'list' && parameters[0] === 'runtimes') {
    console.log(JSON.stringify({ runtimes: [{ identifier: runtime, version: '18.5', isAvailable: true,
      supportedDeviceTypes: [{ name: 'iPhone 16 Pro', identifier: 'phone-type' }] }] }));
  } else if (command === 'create') {
    const udid = require('node:crypto').randomUUID();
    devices.push({ name: parameters[0], udid, state: 'Shutdown', testing: false });
    // Model a worker left by Xcode and an unrelated device that cleanup must preserve.
    const hasTestingSet = process.env.SIMULATOR_LIST_FAILURE !== 'missing-testing';
    if (hasTestingSet) devices.push({ name: 'Clone 1 of ' + parameters[0], udid: require('node:crypto').randomUUID(), state: 'Booted', testing: true });
    devices.push({ name: 'Unrelated iPhone', udid: require('node:crypto').randomUUID(), state: 'Booted', testing: hasTestingSet });
    fs.writeFileSync(statePath, JSON.stringify(devices));
    if (process.env.SIMULATOR_CREATE_FAILURE === 'true') process.exit(1);
    console.log(udid);
  } else if (command === 'list' && parameters[0] === 'devices') {
    const failure = process.env.SIMULATOR_LIST_FAILURE;
    if ((testing && failure === 'missing-testing') || (!testing && failure === 'missing-default')) {
      console.error('Provided set path does not exist: /Users/runner/Library/Developer/' + (testing ? 'XCTestDevices' : 'CoreSimulator/Devices'));
      process.exit(1);
    }
    if (testing && failure === 'unavailable-testing') {
      console.error('CoreSimulatorService connection became invalid.');
      process.exit(1);
    }
    console.log(JSON.stringify({ devices: { [runtime]: devices.filter(device => device.testing === testing) } }));
  } else if (command === 'delete' || command === 'shutdown') {
    const device = devices.find(device => device.udid === parameters[0] && device.testing === testing);
    if (!device || device.name === 'Unrelated iPhone') process.exit(2);
    if (command === 'delete') {
      if (process.env.SIMULATOR_DELETE_FAILURE === 'true') process.exit(1);
      devices.splice(devices.indexOf(device), 1);
    } else device.state = 'Shutdown';
    fs.writeFileSync(statePath, JSON.stringify(devices));
  } else process.exit(2);
  process.exit(0);
}
if (args.slice(0, 3).join(' ') !== 'xcresulttool get test-results' || !['summary', 'tests'].includes(args[3])) process.exit(2);
process.stdout.write(fs.readFileSync(path.join(args[args.indexOf('--path') + 1], args[3] + '.json')));
`, { mode: 0o755 });

  let inputs = {
    ...defaults(suite === 'InteractionTests' ? interactionAction : action),
    platform,
    destination: platform === 'ios' ? (options.destination ?? destination) : 'platform=macOS',
    'artifact-name': 'snapshot-tests',
    'reference-root': referenceRoot,
    'only-testing': options.onlyTesting ?? '',
    compute: String(options.compute ?? true),
    'update-reference': String(options.update ?? false),
    mode: options.mode ?? 'test',
  };
  if (suite === 'InteractionTests') {
    const caller = interactionAction.runs.steps.find(step => step.uses === './.github/actions/uitests');
    inputs = { ...defaults(action), ...Object.fromEntries(Object.entries(caller.with).map(([key, value]) => [key, expand(value, { inputs })])) };
  }
  const steps = Object.fromEntries(action.runs.steps.filter(step => step.id).map(step => [step.id, { outputs: {}, outcome: 'skipped' }]));
  let stdout = '';
  let stderr = '';
  let failed = false;
  const selectedSteps = new Set(['reference', 'paths', 'record-baseline', 'uitest']);
  for (const step of action.runs.steps) {
    if (!selectedSteps.has(step.id) && !['Clean up snapshot reference lock', 'Fail if baseline recording failed', 'Clean up test simulators'].includes(step.name) && !(options.collectArtifacts && step.name === 'Collect failure artifacts')) continue;
    const bindings = { inputs, steps };
    // Steps without always() only run while no earlier step has failed.
    if (failed && !/always\(\)/.test(step.if ?? '')) continue;
    if (step.if && !evaluate(step.if, bindings)) continue;
    const output = path.join(directory, 'output');
    await fs.writeFile(output, '');
    const result = spawnSync('bash', ['--noprofile', '--norc', '-e', '-o', 'pipefail', '-c', expand(step.run, bindings)], {
      cwd: root,
      encoding: 'utf8',
      timeout: 10000,
      env: {
        ...process.env,
        PATH: `${bin}${path.delimiter}${process.env.PATH}`,
        TUIST_MISE_ENVIRONMENT: inputs.compute === 'true' ? 'compute' : '',
        RUNNER_TEMP: directory,
        GITHUB_OUTPUT: output,
        GITHUB_RUN_ID: '123', GITHUB_JOB: 'snapshot-tests', GITHUB_RUN_ATTEMPT: '1',
        INTERACTION_TEST_COMMAND_LOG: commandLog,
        SIMULATOR_LOG: simulatorLog, SIMULATOR_STATE: simulatorState,
        SIMULATOR_CREATE_FAILURE: String(options.simulatorCreateFailure ?? false),
        SIMULATOR_DELETE_FAILURE: String(options.simulatorDeleteFailure ?? false),
        SIMULATOR_LIST_FAILURE: options.simulatorListFailure ?? '',
        INTERACTION_TEST_FIXTURES: JSON.stringify(fixtures),
        INTERACTION_TEST_RECORDING_SUMMARY: JSON.stringify(recordingSummary),
        SNAPSHOT_PLATFORM: snapshotPlatform, SNAPSHOT_VERSION: snapshotVersion, TEST_SUITE: suite,
        ...Object.fromEntries(Object.entries(step.env ?? {}).map(([key, value]) => [key, expand(value, bindings)])),
      },
    });
    assert.ifError(result.error);
    stdout += result.stdout;
    stderr += result.stderr;
    if (step.id) {
      steps[step.id] = {
        outcome: result.status === 0 ? 'success' : 'failure',
        outputs: Object.fromEntries((await fs.readFile(output, 'utf8')).trim().split('\n').filter(Boolean).map(line => {
          const index = line.indexOf('=');
          return [line.slice(0, index), line.slice(index + 1)];
        })),
      };
    }
    if (result.status !== 0 && !step['continue-on-error']) failed = true;
  }
  const commands = (await fs.readFile(commandLog, 'utf8')).trim().split('\n').filter(Boolean).map(line => JSON.parse(line));
  const verified = inputs.mode === 'record' ? steps['record-baseline'].outcome === 'success' : steps.uitest.outcome === 'success';
  return {
    simulatorCommands: (await fs.readFile(simulatorLog, 'utf8')).trim().split('\n').filter(Boolean).map(line => JSON.parse(line)),
    remainingSimulators: JSON.parse(await fs.readFile(simulatorState, 'utf8')),
    status: failed || !verified ? 1 : 0,
    stdout, stderr, commands, steps, directory, referenceRoot, referenceDirectory,
    artifacts: steps.paths.outputs.artifacts,
    derivedData: steps.paths.outputs['derived-data-path'],
  };
}

test('interaction action records SwiftUI references before OpenSwiftUI verification and keeps both results', async t => {
  const result = await runTests(t, {}, { update: true });
  assert.equal(result.status, 0, result.stdout + result.stderr);
  await assert.rejects(fs.access(result.steps.reference.outputs.lockfile), { code: 'ENOENT' });
  for (const [index, args] of result.commands.entries()) {
    assert.deepEqual(args.slice(0, 7), ['--env', 'compute', 'exec', '--', 'tuist', 'xcodebuild', 'test']);
    assert.match(args[args.indexOf('-destination') + 1], /^platform=iOS Simulator,id=[0-9a-f-]{36}$/);
    assert.equal(args[args.indexOf('-parallel-testing-enabled') + 1], 'NO');
    assert.equal(args[args.indexOf('-derivedDataPath') + 1], result.derivedData);
    assert.equal(args[args.indexOf('-resultBundlePath') + 1], path.join(result.artifacts, `${schemes[index]}.xcresult`));
    const log = await fs.readFile(path.join(result.artifacts, `${schemes[index]}.log`), 'utf8');
    assert.match(log, /Executed 1 UI test\(s\)/);
    assert.ok((await fs.stat(path.join(result.artifacts, `${schemes[index]}.xcresult`))).isDirectory());
    const environment = JSON.parse(await fs.readFile(path.join(result.artifacts, `${schemes[index]}-environment.json`), 'utf8'));
    assert.equal(environment.referenceRoot, result.referenceRoot);
  }
});

for (const scheme of schemes) {
  for (const [name, fixture] of Object.entries({
    'test failure': {
      status: 65,
      summary: { ...recordingSummary, testFailures: [{ failureText: 'Expectation failed: count == 1' }] },
    },
    'build failure without a result': { status: 65, missingResult: true },
    'zero tests': { summary: { totalTestCount: 0, skippedTests: 0 } },
    'all tests skipped': { summary: { totalTestCount: 2, skippedTests: 2 } },
    'missing result': { missingResult: true },
  })) {
    test(`${scheme}: ${name} fails the action`, async t => {
      const result = await runTests(t, { [scheme]: fixture }, { update: true });
      assert.equal(result.status, 1, result.stdout + result.stderr);
      if (scheme === 'SUI_InteractionTests') assert.equal(result.steps.uitest.outcome, 'skipped');
      for (const name of scheme === 'SUI_InteractionTests' ? ['SUI_InteractionTests'] : schemes) {
        assert.match(await fs.readFile(path.join(result.artifacts, `${name}.log`), 'utf8'), new RegExp(`Executed ${name}`));
      }
    });
  }
}

test('SwiftUI recording keeps references after an abnormal xcodebuild exit', async t => {
  for (const fixture of [{ status: 70 }, { status: 70, missingResult: true }]) {
    const result = await runTests(t, { SUI_InteractionTests: fixture }, { update: true });
    assert.equal(result.status, 0, result.stdout + result.stderr);
    assert.match(result.stdout, /::warning::xcodebuild exited with status 70/);
    assert.deepEqual(result.commands.map(args => args[args.indexOf('-scheme') + 1]), schemes);
  }
});

test('record mode records SwiftUI references without OpenSwiftUI verification', async t => {
  const result = await runTests(t, {}, { update: true, mode: 'record' });
  assert.equal(result.status, 0, result.stdout + result.stderr);
  assert.deepEqual(result.commands.map(args => args[args.indexOf('-scheme') + 1]), ['SUI_InteractionTests']);
  assert.equal(result.steps['record-baseline'].outcome, 'success');
  assert.equal(result.steps.uitest.outcome, 'skipped');
  assert.equal(expand(action.outputs['record-result'].value, { steps: result.steps }), 'success');
  assert.equal(expand(action.outputs['test-result'].value, { steps: result.steps }), 'skipped');
  await assert.rejects(fs.access(result.steps.reference.outputs.lockfile), { code: 'ENOENT' });
});

test('record mode fails on a recording failure without starting verification', async t => {
  const result = await runTests(t, {
    SUI_InteractionTests: {
      status: 1,
      summary: { ...recordingSummary, testFailures: [recordingFailure, { failureText: 'Expectation failed: count == 1' }] },
    },
  }, { update: true, mode: 'record' });
  assert.equal(result.status, 1, result.stdout + result.stderr);
  assert.equal(result.steps['record-baseline'].outcome, 'failure');
  assert.equal(result.steps.uitest.outcome, 'skipped');
});

test('record mode applies to UI tests and rejects unknown modes', async t => {
  const recorded = await runTests(t, {}, { suite: 'UITests', update: true, mode: 'record', compute: false });
  assert.equal(recorded.status, 0, recorded.stdout + recorded.stderr);
  assert.deepEqual(recorded.commands.map(args => args[args.indexOf('-scheme') + 1]), ['SUI_UITests']);
  const rejected = await runTests(t, {}, { update: true, mode: 'verify' });
  assert.equal(rejected.status, 1);
  assert.match(rejected.stdout + rejected.stderr, /Unsupported test mode: verify/);
  assert.deepEqual(rejected.commands, []);
});

for (const [name, fixture] of Object.entries({
  'missing reference images': { missingReferences: true },
  'abnormal xcodebuild exit without reference images': { status: 70, missingReferences: true },
  'mixed recording and test failures': {
    summary: { ...recordingSummary, testFailures: [recordingFailure, { failureText: 'Caught error: timeout' }] },
  },
  'failed tests without failure details': {
    summary: { ...recordingSummary, testFailures: [] },
  },
  'a real failure after the first recording issue in one test case': {
    testTree: {
      testNodes: [{
        nodeType: 'Test Case', result: 'Failed', children: [{
          nodeType: 'Arguments', result: 'Failed', children: [
            { nodeType: 'Failure Message', name: `TapGestureInteractionTests.swift:50: ${recordingFailure.failureText}` },
            { nodeType: 'Failure Message', name: 'TapGestureInteractionTests.swift:52: Caught error: timeout' },
          ],
        }],
      }],
    },
  },
  'a failed parameter case without failure details': {
    testTree: {
      testNodes: [{
        nodeType: 'Test Case', result: 'Failed', children: [
          { nodeType: 'Failure Message', name: `TapGestureInteractionTests.swift:50: ${recordingFailure.failureText}` },
          { nodeType: 'Arguments', name: '2', result: 'Failed', children: [] },
        ],
      }],
    },
  },
})) {
  test(`SwiftUI recording rejects ${name}`, async t => {
    const result = await runTests(t, { SUI_InteractionTests: fixture }, { update: true });
    assert.equal(result.status, 1, result.stdout + result.stderr);
  });
}

test('SwiftUI recording accepts a successful run with reference images', async t => {
  const result = await runTests(t, {
    SUI_InteractionTests: {
      status: 0,
      summary: { totalTestCount: 1, skippedTests: 0, failedTests: 0, testFailures: [] },
    },
  }, { update: true });
  assert.equal(result.status, 0, result.stdout + result.stderr);
});

for (const scheme of schemes) {
  test(`${scheme}: failure artifacts retain logs and zipped result bundles`, async t => {
    const result = await runTests(t, {
      [scheme]: { status: 65, summary: { totalTestCount: 1, skippedTests: 0, failedTests: 1, testFailures: [{ failureText: 'Expectation failed' }] } },
    }, { update: true, collectArtifacts: true });
    assert.equal(result.status, 1, result.stdout + result.stderr);
    assert.ok((await fs.stat(path.join(result.artifacts, `${scheme}.xcresult.zip`))).isFile());
    assert.match(await fs.readFile(path.join(result.artifacts, scheme, 'logs/test_output.log'), 'utf8'), /Executed/);
  });
}

for (const mode of ['record', 'test']) {
  test(`iOS UI ${mode} uses fresh destinations and cleans up only its devices`, async t => {
    const result = await runTests(t, {}, { suite: 'UITests', update: true, mode });
    assert.equal(result.status, 0, result.stdout + result.stderr);
    const destinations = result.commands.map(args => args[args.indexOf('-destination') + 1]);
    assert.equal(new Set(destinations).size, mode === 'record' ? 1 : 2);
    for (const args of result.commands) {
      assert.match(args[args.indexOf('-destination') + 1], /^platform=iOS Simulator,id=[0-9a-f-]{36}$/);
      assert.ok(!args.includes('-parallel-testing-enabled'));
    }
    assert.ok(!result.simulatorCommands.some(args => args.includes('boot') || args.includes('erase')));
    assert.ok(result.remainingSimulators.length > 0);
    assert.ok(result.remainingSimulators.every(device => device.name === 'Unrelated iPhone' && device.state === 'Booted'));
    await assert.rejects(fs.access(path.join(result.steps.paths.outputs.root, 'record-simulator.json')), { code: 'ENOENT' });
  });
}

test('simulator cleanup runs after test failure and partial creation failure', async t => {
  for (const creationFails of [false, true]) {
    const result = await runTests(t, { OSUI_InteractionTests: { status: 65 } }, { simulatorCreateFailure: creationFails });
    assert.equal(result.status, 1);
    if (creationFails) assert.deepEqual(result.commands, []);
    assert.ok(result.remainingSimulators.every(device => device.name === 'Unrelated iPhone'));
  }
});

test('simulator cleanup reports deletion failure and retains ownership state', async t => {
  const result = await runTests(t, {}, { simulatorDeleteFailure: true });
  assert.equal(result.status, 1);
  assert.match(result.stderr, /Simulator cleanup failed/);
  await fs.access(path.join(result.steps.paths.outputs.root, 'verify-simulator.json'));
  const cleanup = action.runs.steps.find(step => step.name === 'Clean up isolated test directories');
  assert.equal(evaluate(cleanup.if, { steps: result.steps }), false);
});

test('macOS keeps its destination and does not manage simulators', async t => {
  const result = await runTests(t, {}, { platform: 'macos' });
  assert.equal(result.status, 0, result.stdout + result.stderr);
  assert.equal(result.commands[0][result.commands[0].indexOf('-destination') + 1], 'platform=macOS');
  assert.deepEqual(result.simulatorCommands, []);
});

test('simulator selection rejects a missing runtime or device type before running tests', async t => {
  for (const destination of [
    'platform=iOS Simulator,OS=18.6,name=iPhone 16 Pro',
    'platform=iOS Simulator,OS=18.5,name=Unknown iPhone',
  ]) {
    const result = await runTests(t, {}, { destination });
    assert.equal(result.status, 1);
    assert.deepEqual(result.commands, []);
    assert.ok(!result.simulatorCommands.some(args => args.includes('create')));
    assert.deepEqual(result.remainingSimulators, []);
  }
});

test('simulator selection accepts an explicit zero patch version', async t => {
  const result = await runTests(t, {}, { destination: 'platform=iOS Simulator,OS=18.5.0,name=iPhone 16 Pro' });
  assert.equal(result.status, 0, result.stdout + result.stderr);
});

test('serial interaction cleanup succeeds without a testing device set', async t => {
  const result = await runTests(t, {}, { update: true, simulatorListFailure: 'missing-testing' });
  assert.equal(result.status, 0, result.stdout + result.stderr);
  assert.equal(result.steps['simulator-cleanup'].outcome, 'success');
  assert.equal(result.commands.length, 2);
  for (const args of result.commands) assert.equal(args[args.indexOf('-parallel-testing-enabled') + 1], 'NO');
  assert.ok(result.remainingSimulators.length > 0);
  assert.ok(result.remainingSimulators.every(device => device.name === 'Unrelated iPhone' && device.state === 'Booted'));
  for (const phase of ['record', 'verify']) {
    await assert.rejects(fs.access(path.join(result.steps.paths.outputs.root, `${phase}-simulator.json`)), { code: 'ENOENT' });
  }
});

test('simulator cleanup reports other list failures and retains ownership state', async t => {
  for (const failure of ['unavailable-testing', 'missing-default']) {
    const result = await runTests(t, {}, { simulatorListFailure: failure });
    assert.equal(result.steps.uitest.outcome, 'success');
    assert.equal(result.steps['simulator-cleanup'].outcome, 'failure');
    assert.equal(result.status, 1);
    await fs.access(path.join(result.steps.paths.outputs.root, 'verify-simulator.json'));
    if (failure === 'unavailable-testing') {
      assert.match(result.stderr, /CoreSimulatorService connection became invalid/);
      assert.ok(!result.remainingSimulators.some(device => !device.testing && device.name.startsWith('OpenSwiftUI-')));
    } else {
      assert.match(result.stderr, /Provided set path does not exist/);
    }
  }
});
