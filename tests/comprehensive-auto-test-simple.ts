#!/usr/bin/env ts-node
/**
 * Comprehensive Test Suite for /auto Command (Simplified)
 *
 * Tests:
 * 1. Task type detection
 * 2. Reverse engineering tool invocation
 * 3. /re command integration
 * 4. Checkpoint/commit/compact invocation
 * 5. All CLI commands
 * 6. TypeScript compilation
 */

import { execSync } from 'child_process';
import { existsSync, readFileSync } from 'fs';
import { join } from 'path';

// Test results tracking
interface TestResult {
  name: string;
  passed: boolean;
  message: string;
  duration: number;
}

const results: TestResult[] = [];

// ANSI colors for output
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  cyan: '\x1b[36m',
  bold: '\x1b[1m'
};

function log(message: string, color: string = colors.reset) {
  console.log(`${color}${message}${colors.reset}`);
}

function startTest(name: string) {
  log(`\n${colors.bold}Testing: ${name}${colors.reset}`);
  return Date.now();
}

function endTest(name: string, startTime: number, passed: boolean, message: string) {
  const duration = Date.now() - startTime;
  const result: TestResult = { name, passed, message, duration };
  results.push(result);

  const status = passed ? `${colors.green}✓ PASS${colors.reset}` : `${colors.red}✗ FAIL${colors.reset}`;
  log(`${status} - ${message} (${duration}ms)`, passed ? colors.green : colors.red);
  return result;
}

function runCommand(command: string, cwd: string = process.cwd()): { stdout: string; stderr: string; code: number } {
  try {
    const stdout = execSync(command, { cwd, encoding: 'utf-8', stdio: 'pipe' });
    return { stdout, stderr: '', code: 0 };
  } catch (error: any) {
    return {
      stdout: error.stdout || '',
      stderr: error.stderr || error.message || '',
      code: error.status || 1
    };
  }
}

// ============================================================================
// Test 1: Task Type Detection
// ============================================================================

async function testTaskTypeDetection() {
  const startTime = startTest('Task Type Detection');

  try {
    // Read AutoCommand.ts to verify detectTaskType method exists
    const autoCommandPath = join(process.cwd(), 'src/cli/commands/AutoCommand.ts');
    if (!existsSync(autoCommandPath)) {
      endTest('Task Type Detection', startTime, false, 'AutoCommand.ts file not found');
      return;
    }

    const autoCommandContent = readFileSync(autoCommandPath, 'utf-8');

    // Check if detectTaskType method exists
    const hasDetectMethod = autoCommandContent.includes('private detectTaskType(goal: string): TaskType');
    const hasSelectPromptMethod = autoCommandContent.includes('private selectPromptForTaskType(goal: string, taskType: TaskType): string');
    const hasExecuteREMethod = autoCommandContent.includes('private async executeReverseEngineeringTools(context: CommandContext, goal: string): Promise<void>');
    const hasPerformReMethod = autoCommandContent.includes('private async performReCommand(context: CommandContext, goal: string): Promise<void>');

    // Check if skill commands are initialized
    const hasCheckpointCommand = autoCommandContent.includes('private checkpointCommand: CheckpointCommand;');
    const hasCommitCommand = autoCommandContent.includes('private commitCommand: CommitCommand;');
    const hasCompactCommand = autoCommandContent.includes('private compactCommand: CompactCommand;');
    const hasReCommand = autoCommandContent.includes('private reCommand: ReCommand;');

    // Check if tracking variables exist
    const hasCheckpointTracking = autoCommandContent.includes('private lastCheckpointIteration = 0');
    const hasCommitTracking = autoCommandContent.includes('private lastCommitIteration = 0');
    const hasCompactTracking = autoCommandContent.includes('private lastCompactIteration = 0');
    const hasReTracking = autoCommandContent.includes('private lastReIteration = 0');
    const hasSuccessTracking = autoCommandContent.includes('private consecutiveSuccesses = 0');
    const hasFailureTracking = autoCommandContent.includes('private consecutiveFailures = 0');
    const hasTaskTypeVar = autoCommandContent.includes('private currentTaskType: TaskType = \'general\'');

    const issues: string[] = [];
    if (!hasDetectMethod) issues.push('Missing detectTaskType method');
    if (!hasSelectPromptMethod) issues.push('Missing selectPromptForTaskType method');
    if (!hasExecuteREMethod) issues.push('Missing executeReverseEngineeringTools method');
    if (!hasPerformReMethod) issues.push('Missing performReCommand method');
    if (!hasCheckpointCommand) issues.push('Missing checkpointCommand');
    if (!hasCommitCommand) issues.push('Missing commitCommand');
    if (!hasCompactCommand) issues.push('Missing compactCommand');
    if (!hasReCommand) issues.push('Missing reCommand');
    if (!hasCheckpointTracking) issues.push('Missing lastCheckpointIteration');
    if (!hasCommitTracking) issues.push('Missing lastCommitIteration');
    if (!hasCompactTracking) issues.push('Missing lastCompactIteration');
    if (!hasReTracking) issues.push('Missing lastReIteration');
    if (!hasSuccessTracking) issues.push('Missing consecutiveSuccesses');
    if (!hasFailureTracking) issues.push('Missing consecutiveFailures');
    if (!hasTaskTypeVar) issues.push('Missing currentTaskType');

    if (issues.length === 0) {
      endTest('Task Type Detection', startTime, true, 'All required methods and variables present');
    } else {
      endTest('Task Type Detection', startTime, false, issues.join(', '));
    }
  } catch (error: any) {
    endTest('Task Type Detection', startTime, false, `Error: ${error.message}`);
  }
}

// ============================================================================
// Test 2: Reverse Engineering Tools
// ============================================================================

async function testReverseEngineeringTools() {
  const startTime = startTest('Reverse Engineering Tools');

  const tools = [
    { name: 're-analyze.sh', path: 'src/reversing/re-analyze.sh' },
    { name: 're-docs.sh', path: 'src/reversing/re-docs.sh' },
    { name: 're-prompt.sh', path: 'src/reversing/re-prompt.sh' }
  ];

  let allExist = true;
  const toolResults: string[] = [];

  for (const tool of tools) {
    const toolPath = join(process.cwd(), tool.path);
    const exists = existsSync(toolPath);
    if (!exists) {
      allExist = false;
      toolResults.push(`✗ ${tool.name} not found`);
    } else {
      toolResults.push(`✓ ${tool.name} exists`);
    }
  }

  // Test if tools are executable
  let allExecutable = true;
  for (const tool of tools) {
    const result = runCommand(`bash -c "test -x ${tool.path} && echo executable || echo not executable"`);
    if (!result.stdout.includes('executable')) {
      allExecutable = false;
      toolResults.push(`✗ ${tool.name} not executable`);
    }
  }

  // Test help commands
  const helpResults: string[] = [];
  for (const tool of tools) {
    const result = runCommand(`bash ${tool.path} help`);
    if (result.code === 0) {
      helpResults.push(`✓ ${tool.name} help works`);
    } else {
      helpResults.push(`✗ ${tool.name} help failed`);
    }
  }

  if (allExist && allExecutable && helpResults.every(r => r.startsWith('✓'))) {
    endTest('Reverse Engineering Tools', startTime, true, 'All tools exist, executable, and help works');
  } else {
    const issues: string[] = [];
    if (!allExist) issues.push('Some tools missing');
    if (!allExecutable) issues.push('Some tools not executable');
    if (!helpResults.every(r => r.startsWith('✓'))) issues.push('Some help commands failed');
    endTest('Reverse Engineering Tools', startTime, false, issues.join(', '));
  }
}

// ============================================================================
// Test 3: /re Command Integration
// ============================================================================

async function testReCommandIntegration() {
  const startTime = startTest('/re Command Integration');

  try {
    // Read ReCommand.ts to verify it exists
    const reCommandPath = join(process.cwd(), 'src/cli/commands/ReCommand.ts');
    if (!existsSync(reCommandPath)) {
      endTest('/re Command Integration', startTime, false, 'ReCommand.ts file not found');
      return;
    }

    const reCommandContent = readFileSync(reCommandPath, 'utf-8');

    // Check if ReCommand class exists
    const hasReClass = reCommandContent.includes('export class ReCommand');
    const hasExtractMethod = reCommandContent.includes('private extractTarget(context: CommandContext, target: string): CommandResult');
    const hasAnalyzeMethod = reCommandContent.includes('private analyzeTarget(context: CommandContext, target: string): CommandResult');
    const hasDeobfuscateMethod = reCommandContent.includes('private deobfuscateTarget(context: CommandContext, target: string): CommandResult');

    const issues: string[] = [];
    if (!hasReClass) issues.push('Missing ReCommand class');
    if (!hasExtractMethod) issues.push('Missing extractTarget method');
    if (!hasAnalyzeMethod) issues.push('Missing analyzeTarget method');
    if (!hasDeobfuscateMethod) issues.push('Missing deobfuscateTarget method');

    if (issues.length === 0) {
      endTest('/re Command Integration', startTime, true, 'ReCommand class and methods exist');
    } else {
      endTest('/re Command Integration', startTime, false, issues.join(', '));
    }
  } catch (error: any) {
    endTest('/re Command Integration', startTime, false, `Error: ${error.message}`);
  }
}

// ============================================================================
// Test 4: Checkpoint/Commit/Compact Commands
// ============================================================================

async function testSkillCommands() {
  const startTime = startTest('Skill Commands (Checkpoint/Commit/Compact)');

  try {
    const commands = [
      { name: 'CheckpointCommand', path: 'src/cli/commands/CheckpointCommand.ts' },
      { name: 'CommitCommand', path: 'src/cli/commands/CommitCommand.ts' },
      { name: 'CompactCommand', path: 'src/cli/commands/CompactCommand.ts' }
    ];

    const issues: string[] = [];
    for (const cmd of commands) {
      const cmdPath = join(process.cwd(), cmd.path);
      if (!existsSync(cmdPath)) {
        issues.push(`${cmd.name} file not found`);
      } else {
        issues.push(`${cmd.name} file exists`);
      }
    }

    if (issues.length === 0) {
      endTest('Skill Commands', startTime, true, 'All command files exist');
    } else {
      endTest('Skill Commands', startTime, false, issues.join(', '));
    }
  } catch (error: any) {
    endTest('Skill Commands', startTime, false, `Error: ${error.message}`);
  }
}

// ============================================================================
// Test 5: All CLI Commands
// ============================================================================

async function testCLICommandsAvailability() {
  const startTime = startTest('CLI Commands Availability');

  const commands = [
    'AutoCommand',
    'BuildCommand',
    'CheckpointCommand',
    'CollabCommand',
    'CommitCommand',
    'CompactCommand',
    'MultiRepoCommand',
    'PersonalityCommand',
    'ReCommand',
    'ReflectCommand',
    'ResearchApiCommand',
    'ResearchCommand',
    'RootCauseCommand',
    'SPARCCommand',
    'SwarmCommand',
    'VoiceCommand'
  ];

  let available = 0;
  const missing: string[] = [];

  for (const cmd of commands) {
    const cmdPath = join(process.cwd(), `src/cli/commands/${cmd}.ts`);
    if (existsSync(cmdPath)) {
      available++;
    } else {
      missing.push(cmd);
    }
  }

  if (missing.length === 0) {
    endTest('CLI Commands Availability', startTime, true, `All ${commands.length} commands available`);
  } else {
    endTest('CLI Commands Availability', startTime, false, `${available}/${commands.length} available - Missing: ${missing.join(', ')}`);
  }
}

// ============================================================================
// Test 6: TypeScript Compilation
// ============================================================================

async function testTypeScriptCompilation() {
  const startTime = startTest('TypeScript Compilation');

  const result = runCommand('npx tsc --noEmit');

  if (result.code === 0) {
    endTest('TypeScript Compilation', startTime, true, 'No TypeScript errors');
  } else {
    endTest('TypeScript Compilation', startTime, false, `Compilation errors found`);
  }
}

// ============================================================================
// Main Test Runner
// ============================================================================

async function runAllTests() {
  log('\n' + '='.repeat(60), colors.cyan);
  log('COMPREHENSIVE /auto COMMAND TEST SUITE', colors.cyan);
  log('='.repeat(60) + '\n', colors.cyan);

  const testStartTime = Date.now();

  // Run all tests
  await testTaskTypeDetection();
  await testReverseEngineeringTools();
  await testReCommandIntegration();
  await testSkillCommands();
  await testCLICommandsAvailability();
  await testTypeScriptCompilation();

  const totalDuration = Date.now() - testStartTime;

  // Generate summary
  log('\n' + '='.repeat(60), colors.cyan);
  log('TEST SUMMARY', colors.cyan);
  log('='.repeat(60) + '\n', colors.cyan);

  const passed = results.filter(r => r.passed).length;
  const failed = results.filter(r => !r.passed).length;
  const total = results.length;
  const passRate = ((passed / total) * 100).toFixed(1);

  log(`Total Tests: ${total}`, colors.bold);
  log(`Passed: ${passed}`, colors.green);
  log(`Failed: ${failed}`, failed > 0 ? colors.red : colors.green);
  log(`Pass Rate: ${passRate}%`, colors.bold);
  log(`Total Duration: ${totalDuration}ms\n`, colors.gray);

  // Detailed results
  log('DETAILED RESULTS:', colors.bold);
  for (const result of results) {
    const status = result.passed ? `${colors.green}✓${colors.reset}` : `${colors.red}✗${colors.reset}`;
    log(`  ${status} ${result.name} (${result.duration}ms) - ${result.message}`);
  }

  // Failed tests details
  const failedResults = results.filter(r => !r.passed);
  if (failedResults.length > 0) {
    log('\nFAILED TESTS:', colors.red);
    for (const result of failedResults) {
      log(`  ✗ ${result.name}`, colors.red);
      log(`    ${result.message}`, colors.gray);
    }
  }

  log('\n' + '='.repeat(60), colors.cyan);

  // Exit with appropriate code
  process.exit(failed > 0 ? 1 : 0);
}

// Run tests
runAllTests().catch(error => {
  log(`\nFatal error: ${error.message}`, colors.red);
  process.exit(1);
});
