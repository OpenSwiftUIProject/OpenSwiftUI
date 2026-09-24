import assert from 'node:assert/strict';
import { execFileSync, spawnSync } from 'node:child_process';
import fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../..');
const action = JSON.parse(execFileSync('ruby', [
  '-ryaml', '-rjson', '-e', 'puts JSON.generate(YAML.load_file(ARGV[0]))',
  `${root}/.github/actions/uxtests/action.yml`,
], { encoding: 'utf8' }));
const step = action.runs.steps.find(step => step.name === 'Run SwiftUI then OpenSwiftUI UX tests');
const schemes = ['SUI_UXTests', 'OSUI_UXTests'];
const destination = 'platform=iOS Simulator,OS=18.5,name=iPhone 16 Pro';

async function runTests(t, fixtures = {}) {
  const directory = await fs.mkdtemp(path.join(os.tmpdir(), 'openswiftui-ux tests-'));
  t.after(() => fs.rm(directory, { recursive: true, force: true }));
  const bin = path.join(directory, 'bin');
  const artifacts = path.join(directory, 'Artifacts');
  const commandLog = path.join(directory, 'commands.jsonl');
  await fs.mkdir(bin);
  await fs.mkdir(artifacts);
  await fs.writeFile(commandLog, '');
  await fs.writeFile(path.join(bin, 'mise'), `#!/usr/bin/env node
const fs = require('node:fs');
const path = require('node:path');
const args = process.argv.slice(2);
fs.appendFileSync(process.env.UXTEST_COMMAND_LOG, JSON.stringify(args) + '\\n');
const scheme = args[args.indexOf('-scheme') + 1];
const result = args[args.indexOf('-resultBundlePath') + 1];
const fixture = JSON.parse(process.env.UXTEST_FIXTURES)[scheme] ?? {};
console.log('Executed ' + scheme);
if (!fixture.missingResult) {
  fs.mkdirSync(result, { recursive: true });
  const summary = fixture.summary ?? { totalTestCount: 1, skippedTests: 0 };
  fs.writeFileSync(path.join(result, 'summary.json'), JSON.stringify(summary));
}
process.exit(fixture.status ?? 0);
`, { mode: 0o755 });
  await fs.writeFile(path.join(bin, 'xcrun'), `#!/usr/bin/env node
const fs = require('node:fs');
const path = require('node:path');
const args = process.argv.slice(2);
if (args.slice(0, 4).join(' ') !== 'xcresulttool get test-results summary') process.exit(2);
process.stdout.write(fs.readFileSync(path.join(args[args.indexOf('--path') + 1], 'summary.json')));
`, { mode: 0o755 });
  const result = spawnSync('bash', ['--noprofile', '--norc', '-e', '-o', 'pipefail', '-c', step.run], {
    cwd: root,
    encoding: 'utf8',
    timeout: 10000,
    env: {
      ...process.env,
      PATH: `${bin}${path.delimiter}${process.env.PATH}`,
      TUIST_MISE_ENVIRONMENT: 'compute',
      UXTEST_ROOT: directory,
      UXTEST_DESTINATION: destination,
      UXTEST_COMMAND_LOG: commandLog,
      UXTEST_FIXTURES: JSON.stringify(fixtures),
    },
  });
  assert.ifError(result.error);
  const commands = (await fs.readFile(commandLog, 'utf8')).trim().split('\n').filter(Boolean).map(line => JSON.parse(line));
  assert.deepEqual(commands.map(args => args[args.indexOf('-scheme') + 1]), schemes, result.stdout + result.stderr);
  return { ...result, directory, artifacts, commands };
}

test('UX action runs SwiftUI before OpenSwiftUI with isolated builds and keeps both results', async t => {
  const result = await runTests(t);
  assert.equal(result.status, 0, result.stdout + result.stderr);
  for (const [index, args] of result.commands.entries()) {
    assert.deepEqual(args.slice(0, 7), ['--env', 'compute', 'exec', '--', 'tuist', 'xcodebuild', 'test']);
    assert.equal(args[args.indexOf('-destination') + 1], destination);
    assert.equal(args[args.indexOf('-parallel-testing-enabled') + 1], 'NO');
    assert.equal(args[args.indexOf('-derivedDataPath') + 1], path.join(result.directory, 'DerivedData', schemes[index]));
    assert.equal(args[args.indexOf('-resultBundlePath') + 1], path.join(result.artifacts, `${schemes[index]}.xcresult`));
    const log = await fs.readFile(path.join(result.artifacts, `${schemes[index]}.log`), 'utf8');
    assert.match(log, /Executed 1 UI test\(s\)/);
    assert.ok((await fs.stat(path.join(result.artifacts, `${schemes[index]}.xcresult`))).isDirectory());
  }
});

for (const scheme of schemes) {
  for (const [name, fixture] of Object.entries({
    'test failure': { status: 65 },
    'build failure without a result': { status: 65, missingResult: true },
    'zero tests': { summary: { totalTestCount: 0, skippedTests: 0 } },
    'all tests skipped': { summary: { totalTestCount: 2, skippedTests: 2 } },
    'missing result': { missingResult: true },
  })) {
    test(`${scheme}: ${name} fails the action while both frameworks still run`, async t => {
      const result = await runTests(t, { [scheme]: fixture });
      assert.equal(result.status, 1, result.stdout + result.stderr);
      for (const name of schemes) {
        assert.match(await fs.readFile(path.join(result.artifacts, `${name}.log`), 'utf8'), new RegExp(`Executed ${name}`));
      }
    });
  }
}
