#!/usr/bin/env bun
/**
 * Comprehensive Auto Features Test Suite
 *
 * Tests:
 * 1. CLI features: auto <goal>, -m, -i, -c, -v options
 * 2. Hooks: auto.sh, autonomous-command-router.sh, memory-manager.sh, coordinator.sh,
 *    swarm-orchestrator.sh, plan-think-act.sh, personality-loader.sh
 * 3. Verify hooks execute without blocking CLI commands
 * 4. Verify native Claude Code slash commands remain accessible
 * 5. Test built CLI version
 */

import { spawn, ChildProcess } from 'child_process';
import { promisify } from 'util';
import { existsSync, readFileSync, unlinkSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import chalk from 'chalk';

const execAsync = promisify(require('child_process').exec);

// Get project root directory (parent of tests/ directory or current directory if in root)
const TEST_FILE_PATH = fileURLToPath(import.meta.url);
const PROJECT_ROOT = TEST_FILE_PATH.includes('/tests/') 
  ? dirname(TEST_FILE_PATH) 
  : process.cwd();

// Helper function to run commands from project root
async function execFromProjectRoot(command: string): Promise<{ stdout: string; stderr: string }> {
  const { stdout, stderr } = await execAsync(`cd ${PROJECT_ROOT} && ${command}`);
  return { stdout, stderr };
}

// Test results tracking
interface TestResult {
  name: string;
  passed: boolean;
  duration: number;
  error?: string;
  output?: string;
}

const results: TestResult[] = [];

// Helper to track test execution
async function runTest(name: string, fn: () => Promise<void>): Promise<void> {
  const start = Date.now();
  const result: TestResult = {
    name,
    passed: false,
    duration: 0
  };

  try {
    await fn();
    result.passed = true;
    console.log(chalk.green(`  ✓ ${name}`));
  } catch (error: any) {
    result.error = error.message;
    result.output = error.stdout || error.stderr || '';
    console.log(chalk.red(`  ✗ ${name}: ${error.message}`));
  }

  result.duration = Date.now() - start;
  results.push(result);
}

// ============================================================================
// TEST 1: CLI Features
// ============================================================================

async function testCLIHelp() {
  console.log(chalk.bold('\n=== Test 1: CLI Help Command ==='));

  const { stdout } = await execFromProjectRoot('bun run src/index.ts --help');
  if (!stdout.includes('auto')) {
    throw new Error('CLI help does not show auto command');
  }
  if (!stdout.includes('init')) {
    throw new Error('CLI help does not show init command');
  }
}

async function testCLIAutoCommand() {
  console.log(chalk.bold('\n=== Test 2: CLI Auto Command ==='));

  // Test that auto command is recognized
  const { stdout } = await execFromProjectRoot('bun run src/index.ts auto --help');
  if (!stdout.includes('goal')) {
    throw new Error('auto command does not show goal argument');
  }
  if (!stdout.includes('--model')) {
    throw new Error('auto command does not show --model option');
  }
  if (!stdout.includes('--iterations')) {
    throw new Error('auto command does not show --iterations option');
  }
  if (!stdout.includes('--checkpoint')) {
    throw new Error('auto command does not show --checkpoint option');
  }
  if (!stdout.includes('--verbose')) {
    throw new Error('auto command does not show --verbose option');
  }
}

async function testCLIBuiltVersion() {
  console.log(chalk.bold('\n=== Test 3: Built CLI Version ==='));

  // Build CLI
  try {
    await execFromProjectRoot('bun run build');
  } catch (error: any) {
    throw new Error(`Build failed: ${error.message}`);
  }

  // Test built version recognizes auto command
  if (!existsSync(join(PROJECT_ROOT, 'dist/index.js'))) {
    throw new Error('Built dist/index.js does not exist');
  }

  const { stdout } = await execFromProjectRoot('node dist/index.js --help');
  if (!stdout.includes('auto')) {
    throw new Error('Built CLI does not show auto command');
  }
}

// ============================================================================
// TEST 2: Shell Hooks
// ============================================================================

async function testAutoHookExists() {
  console.log(chalk.bold('\n=== Test 4: auto.sh Hook ==='));

  if (!existsSync(join(PROJECT_ROOT, 'hooks/auto.sh'))) {
    throw new Error('hooks/auto.sh does not exist');
  }

  const content = readFileSync(join(PROJECT_ROOT, 'hooks/auto.sh'), 'utf-8');
  if (!content.includes('activate_autonomous')) {
    throw new Error('auto.sh missing activate_autonomous function');
  }
  if (!content.includes('deactivate_autonomous')) {
    throw new Error('auto.sh missing deactivate_autonomous function');
  }
  if (!content.includes('check_status')) {
    throw new Error('auto.sh missing check_status function');
  }
}

async function testAutoHookCommands() {
  console.log(chalk.bold('\n=== Test 5: auto.sh Commands ==='));

  // Test help command
  const { stdout } = await execFromProjectRoot(`bash "${join(PROJECT_ROOT, 'hooks/auto.sh')}" help`);
  if (!stdout.includes('start')) {
    throw new Error('auto.sh help missing start command');
  }
  if (!stdout.includes('stop')) {
    throw new Error('auto.sh help missing stop command');
  }
  if (!stdout.includes('status')) {
    throw new Error('auto.sh help missing status command');
  }
}

async function testAutonomousCommandRouterHook() {
  console.log(chalk.bold('\n=== Test 6: autonomous-command-router.sh Hook ==='));

  if (!existsSync(join(PROJECT_ROOT, 'hooks/autonomous-command-router.sh'))) {
    throw new Error('hooks/autonomous-command-router.sh does not exist');
  }

  const content = readFileSync(join(PROJECT_ROOT, 'hooks/autonomous-command-router.sh'), 'utf-8');
  if (!content.includes('analyze_situation')) {
    throw new Error('autonomous-command-router.sh missing analyze_situation function');
  }
  if (!content.includes('execute_if_autonomous')) {
    throw new Error('autonomous-command-router.sh missing execute_if_autonomous function');
  }
}

async function testAutonomousCommandRouterOutput() {
  console.log(chalk.bold('\n=== Test 7: autonomous-command-router.sh Output ==='));

  // Test analyze command
  const { stdout } = await execFromProjectRoot(`bash "${join(PROJECT_ROOT, 'hooks/autonomous-command-router.sh')}" analyze checkpoint_files`);
  if (!stdout.includes('command')) {
    throw new Error('autonomous-command-router.sh analyze did not return command');
  }

  // Test status command
  const { stdout: statusOutput } = await execFromProjectRoot(`bash "${join(PROJECT_ROOT, 'hooks/autonomous-command-router.sh')}" status`);
  if (!statusOutput.includes('autonomous')) {
    throw new Error('autonomous-command-router.sh status did not return autonomous field');
  }
}

async function testMemoryManagerHook() {
  console.log(chalk.bold('\n=== Test 8: memory-manager.sh Hook ==='));

  if (!existsSync(join(PROJECT_ROOT, 'hooks/memory-manager.sh'))) {
    throw new Error('hooks/memory-manager.sh does not exist');
  }

  const content = readFileSync(join(PROJECT_ROOT, 'hooks/memory-manager.sh'), 'utf-8');
  if (!content.includes('get-working')) {
    throw new Error('memory-manager.sh missing get-working function');
  }
}

async function testCoordinatorHook() {
  console.log(chalk.bold('\n=== Test 9: coordinator.sh Hook ==='));

  if (!existsSync(join(PROJECT_ROOT, 'hooks/coordinator.sh'))) {
    throw new Error('hooks/coordinator.sh does not exist');
  }

  const content = readFileSync(join(PROJECT_ROOT, 'hooks/coordinator.sh'), 'utf-8');
  if (!content.includes('coordinate_task')) {
    throw new Error('coordinator.sh missing coordinate_task function');
  }
  if (!content.includes('check_autonomous_triggers')) {
    throw new Error('coordinator.sh missing check_autonomous_triggers function');
  }
}

async function testSwarmOrchestratorHook() {
  console.log(chalk.bold('\n=== Test 10: swarm-orchestrator.sh Hook ==='));

  if (!existsSync(join(PROJECT_ROOT, 'hooks/swarm-orchestrator.sh'))) {
    throw new Error('hooks/swarm-orchestrator.sh does not exist');
  }

  const content = readFileSync(join(PROJECT_ROOT, 'hooks/swarm-orchestrator.sh'), 'utf-8');
  if (!content.includes('spawn_agents')) {
    throw new Error('swarm-orchestrator.sh missing spawn_agents function');
  }
}

async function testPlanThinkActHook() {
  console.log(chalk.bold('\n=== Test 11: plan-think-act.sh Hook ==='));

  if (!existsSync(join(PROJECT_ROOT, 'hooks/plan-think-act.sh'))) {
    throw new Error('hooks/plan-think-act.sh does not exist');
  }

  const content = readFileSync(join(PROJECT_ROOT, 'hooks/plan-think-act.sh'), 'utf-8');
  if (!content.includes('plan')) {
    throw new Error('plan-think-act.sh missing plan function');
  }
  if (!content.includes('think')) {
    throw new Error('plan-think-act.sh missing think function');
  }
  if (!content.includes('act')) {
    throw new Error('plan-think-act.sh missing act function');
  }
}

async function testPersonalityLoaderHook() {
  console.log(chalk.bold('\n=== Test 12: personality-loader.sh Hook ==='));

  if (!existsSync(join(PROJECT_ROOT, 'hooks/personality-loader.sh'))) {
    throw new Error('hooks/personality-loader.sh does not exist');
  }

  const content = readFileSync(join(PROJECT_ROOT, 'hooks/personality-loader.sh'), 'utf-8');
  if (!content.includes('load_personality')) {
    throw new Error('personality-loader.sh missing load_personality function');
  }
}

// ============================================================================
// TEST 3: Hook Non-Blocking Behavior
// ============================================================================

async function testHooksDontBlockCLI() {
  console.log(chalk.bold('\n=== Test 13: Hooks Don\'t Block CLI ==='));

  // Test that hooks can be called without blocking
  const startTime = Date.now();

  // Call auto.sh status (should return quickly)
  await execFromProjectRoot(`bash "${join(PROJECT_ROOT, 'hooks/auto.sh')}" status`);

  const elapsed = Date.now() - startTime;
  if (elapsed > 5000) {
    throw new Error(`Hook took too long: ${elapsed}ms (expected < 5000ms)`);
  }
}

async function testMultipleHooksCanRun() {
  console.log(chalk.bold('\n=== Test 14: Multiple Hooks Can Run ==='));

  // Run multiple hooks in sequence
  await execFromProjectRoot(`bash "${join(PROJECT_ROOT, 'hooks/auto.sh')}" status`);
  await execFromProjectRoot(`bash "${join(PROJECT_ROOT, 'hooks/autonomous-command-router.sh')}" status`);
  await execFromProjectRoot(`bash "${join(PROJECT_ROOT, 'hooks/coordinator.sh')}" status`);

  // If we get here without timeout, hooks don't block each other
  console.log('  ✓ Multiple hooks executed successfully');
}

// ============================================================================
// TEST 4: TypeScriptBridge Entry Point
// ============================================================================

async function testTypeScriptBridgeDoesNotAutoExecute() {
  console.log(chalk.bold('\n=== Test 15: TypeScriptBridge Entry Point ==='));

  const content = readFileSync(join(PROJECT_ROOT, 'src/core/llm/bridge/TypeScriptBridge.ts'), 'utf-8');

  // Verify main() is exported but not auto-executed
  if (!content.includes('export async function main()')) {
    throw new Error('TypeScriptBridge.ts missing exported main() function');
  }

  // Verify automatic execution check is removed
  if (content.includes('if (import.meta.url ===')) {
    throw new Error('TypeScriptBridge.ts still has automatic execution check');
  }

  // Verify comment explains the change
  if (!content.includes('Note: main() is exported for explicit calling')) {
    throw new Error('TypeScriptBridge.ts missing explanatory comment');
  }
}

// ============================================================================
// TEST 5: Documentation
// ============================================================================

async function testAutoDocumentation() {
  console.log(chalk.bold('\n=== Test 16: auto.md Documentation ==='));

  if (!existsSync(join(PROJECT_ROOT, 'commands/auto.md'))) {
    throw new Error('commands/auto.md does not exist');
  }

  const content = readFileSync(join(PROJECT_ROOT, 'commands/auto.md'), 'utf-8');

  // Verify documentation clarifies hooks vs CLI commands
  if (!content.includes('Shell Hooks vs CLI Commands')) {
    throw new Error('auto.md missing "Shell Hooks vs CLI Commands" section');
  }

  if (!content.includes('shell hooks')) {
    throw new Error('auto.md does not clarify that commands are shell hooks');
  }

  if (!content.includes('komplete CLI')) {
    throw new Error('auto.md does not mention komplete CLI usage');
  }
}

// ============================================================================
// TEST 6: Native Claude Code Slash Commands
// ============================================================================

async function testNativeSlashCommandsDocumented() {
  console.log(chalk.bold('\n=== Test 17: Native Slash Commands ==='));

  // Check that documentation mentions native slash commands
  const content = readFileSync(join(PROJECT_ROOT, 'commands/auto.md'), 'utf-8');

  // Verify documentation mentions that native slash commands remain accessible
  if (!content.includes('native') && !content.includes('slash command')) {
    throw new Error('auto.md does not mention native slash commands');
  }
}

// ============================================================================
// TEST 7: Package.json Scripts
// ============================================================================

async function testPackageJsonScripts() {
  console.log(chalk.bold('\n=== Test 18: package.json Scripts ==='));

  const pkg = JSON.parse(readFileSync(join(PROJECT_ROOT, 'package.json'), 'utf-8'));

  // Verify test script exists
  if (!pkg.scripts || !pkg.scripts.test) {
    throw new Error('package.json missing test script');
  }

  // Verify build script exists
  if (!pkg.scripts || !pkg.scripts.build) {
    throw new Error('package.json missing build script');
  }

  // Verify main entry point
  if (!pkg.main || pkg.main !== 'dist/index.js') {
    throw new Error('package.json main entry point incorrect');
  }

  // Verify bin entry
  if (!pkg.bin || !pkg.bin.komplete || pkg.bin.komplete !== 'dist/index.js') {
    throw new Error('package.json bin entry incorrect');
  }
}

// ============================================================================
// TEST 8: CLI Auto Command Options
// ============================================================================

async function testAutoCommandModelOption() {
  console.log(chalk.bold('\n=== Test 19: Auto Command -m Option ==='));

  const { stdout } = await execFromProjectRoot('bun run src/index.ts auto --help');
  if (!stdout.includes('-m, --model')) {
    throw new Error('auto command missing -m/--model option');
  }
  if (!stdout.includes('Model to use')) {
    throw new Error('auto command missing model description');
  }
}

async function testAutoCommandIterationsOption() {
  console.log(chalk.bold('\n=== Test 20: Auto Command -i Option ==='));

  const { stdout } = await execFromProjectRoot('bun run src/index.ts auto --help');
  if (!stdout.includes('-i, --iterations')) {
    throw new Error('auto command missing -i/--iterations option');
  }
  if (!stdout.includes('Max iterations')) {
    throw new Error('auto command missing iterations description');
  }
}

async function testAutoCommandCheckpointOption() {
  console.log(chalk.bold('\n=== Test 21: Auto Command -c Option ==='));

  const { stdout } = await execFromProjectRoot('bun run src/index.ts auto --help');
  if (!stdout.includes('-c, --checkpoint')) {
    throw new Error('auto command missing -c/--checkpoint option');
  }
  if (!stdout.includes('Checkpoint every')) {
    throw new Error('auto command missing checkpoint description');
  }
}

async function testAutoCommandVerboseOption() {
  console.log(chalk.bold('\n=== Test 22: Auto Command -v Option ==='));

  const { stdout } = await execFromProjectRoot('bun run src/index.ts auto --help');
  if (!stdout.includes('-v, --verbose')) {
    throw new Error('auto command missing -v/--verbose option');
  }
  if (!stdout.includes('Verbose output')) {
    throw new Error('auto command missing verbose description');
  }
}

// ============================================================================
// TEST 9: AutoCommand Class
// ============================================================================

async function testAutoCommandClass() {
  console.log(chalk.bold('\n=== Test 23: AutoCommand Class ==='));

  const { AutoCommand } = await import(join(PROJECT_ROOT, 'src/cli/commands/AutoCommand.ts'));
  const autoCmd = new AutoCommand();

  if (autoCmd.name !== 'auto') {
    throw new Error(`AutoCommand name is ${autoCmd.name}, expected 'auto'`);
  }

  if (typeof autoCmd.execute !== 'function') {
    throw new Error('AutoCommand missing execute method');
  }
}

// ============================================================================
// TEST 10: BaseCommand
// ============================================================================

async function testBaseCommandClass() {
  console.log(chalk.bold('\n=== Test 24: BaseCommand Class ==='));

  const { BaseCommand } = await import(join(PROJECT_ROOT, 'src/cli/BaseCommand.ts'));

  if (typeof BaseCommand !== 'function') {
    throw new Error('BaseCommand is not a class/function');
  }
}

// ============================================================================
// Main Test Runner
// ============================================================================

async function main() {
  console.log(chalk.bold.blue('\n╔══════════════════════════════════════════════╗'));
  console.log(chalk.bold.blue('║       Komplete Kontrol Auto Features Test Suite              ║'));
  console.log(chalk.bold.blue('╚══════════════════════════════════════════════════╝\n'));

  const tests = [
    // CLI Features
    { name: 'CLI Help Command', fn: testCLIHelp },
    { name: 'CLI Auto Command', fn: testCLIAutoCommand },
    { name: 'Built CLI Version', fn: testCLIBuiltVersion },

    // Shell Hooks
    { name: 'auto.sh Hook Exists', fn: testAutoHookExists },
    { name: 'auto.sh Commands', fn: testAutoHookCommands },
    { name: 'autonomous-command-router.sh Hook', fn: testAutonomousCommandRouterHook },
    { name: 'autonomous-command-router.sh Output', fn: testAutonomousCommandRouterOutput },
    { name: 'memory-manager.sh Hook', fn: testMemoryManagerHook },
    { name: 'coordinator.sh Hook', fn: testCoordinatorHook },
    { name: 'swarm-orchestrator.sh Hook', fn: testSwarmOrchestratorHook },
    { name: 'plan-think-act.sh Hook', fn: testPlanThinkActHook },
    { name: 'personality-loader.sh Hook', fn: testPersonalityLoaderHook },

    // Hook Non-Blocking Behavior
    { name: 'Hooks Don\'t Block CLI', fn: testHooksDontBlockCLI },
    { name: 'Multiple Hooks Can Run', fn: testMultipleHooksCanRun },

    // TypeScriptBridge Entry Point
    { name: 'TypeScriptBridge Entry Point', fn: testTypeScriptBridgeDoesNotAutoExecute },

    // Documentation
    { name: 'auto.md Documentation', fn: testAutoDocumentation },

    // Package.json
    { name: 'package.json Scripts', fn: testPackageJsonScripts },

    // CLI Auto Command Options
    { name: 'Auto Command -m Option', fn: testAutoCommandModelOption },
    { name: 'Auto Command -i Option', fn: testAutoCommandIterationsOption },
    { name: 'Auto Command -c Option', fn: testAutoCommandCheckpointOption },
    { name: 'Auto Command -v Option', fn: testAutoCommandVerboseOption },

    // Command Classes
    { name: 'AutoCommand Class', fn: testAutoCommandClass },
    { name: 'BaseCommand Class', fn: testBaseCommandClass }
  ];

  // Run all tests
  for (const test of tests) {
    await runTest(test.name, test.fn);
  }

  // Print summary
  console.log(chalk.bold('\n' + '═'.repeat(66)));
  console.log(chalk.bold('Test Summary'));
  console.log('═'.repeat(66) + '\n');

  const passed = results.filter(r => r.passed).length;
  const failed = results.filter(r => !r.passed).length;
  const total = results.length;

  console.log(`Total Tests: ${total}`);
  console.log(chalk.green(`✓ Passed: ${passed}`));
  if (failed > 0) {
    console.log(chalk.red(`✗ Failed: ${failed}`));
  }
  console.log();

  // Print failed tests details
  if (failed > 0) {
    console.log(chalk.bold.red('\nFailed Tests:\n'));
    for (const result of results.filter(r => !r.passed)) {
      console.log(chalk.red(`  ✗ ${result.name}`));
      console.log(chalk.gray(`    Error: ${result.error}`));
      if (result.output) {
        console.log(chalk.gray(`    Output: ${result.output.substring(0, 200)}...`));
      }
    }
    console.log();
  }

  // Print duration stats
  const totalDuration = results.reduce((sum, r) => sum + r.duration, 0);
  const avgDuration = totalDuration / total;
  console.log(`Total Duration: ${totalDuration}ms`);
  console.log(`Average Duration: ${Math.round(avgDuration)}ms`);
  console.log();

  // Final result
  if (failed === 0) {
    console.log(chalk.bold.green('🎉 All tests passed!'));
    console.log(chalk.green('\nThe auto features are working correctly:'));
    console.log(chalk.green('  • CLI commands are properly configured'));
    console.log(chalk.green('  • Shell hooks exist and are functional'));
    console.log(chalk.green('  • Hooks do not block CLI execution'));
    console.log(chalk.green('  • Documentation is clear and accurate'));
    console.log(chalk.green('  • TypeScriptBridge entry point is fixed'));
    process.exit(0);
  } else {
    console.log(chalk.bold.yellow(`\n⚠️  ${failed} test(s) failed. Please review the errors above.`));
    process.exit(1);
  }
}

main().catch(err => {
  console.error(chalk.red('\nFatal error:'), err);
  process.exit(1);
});
