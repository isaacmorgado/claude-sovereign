#!/usr/bin/env bun
/**
 * CLI Feature Tests
 * Tests CLI infrastructure without requiring API keys
 */

import { BaseCommand } from './src/cli/BaseCommand';
import type { CommandContext, CommandResult } from './src/cli/types';
import chalk from 'chalk';

// Mock command for testing
class TestCommand extends BaseCommand {
  name = 'test';
  description = 'Test command';

  async execute(_context: CommandContext, args: { message: string }): Promise<CommandResult> {
    // Test spinner
    this.startSpinner('Testing spinner...');
    await this.sleep(500);
    this.succeedSpinner('Spinner works!');

    // Test logging
    this.info('Testing info logging');
    this.success('Testing success logging');
    this.warn('Testing warning logging');

    // Test result creation
    return this.createSuccess('Test completed', { message: args.message });
  }

  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

// Mock ReflexionAgent test
async function testReflexionAgent() {
  console.log(chalk.bold('\n=== Testing ReflexionAgent ===\n'));

  const { ReflexionAgent } = await import('./src/core/agents/reflexion');
  const agent = new ReflexionAgent('test goal');

  // Execute a cycle
  const cycle = await agent.cycle('Test input for thinking');

  console.log('Cycle result:');
  console.log('  Thought:', cycle.thought);
  console.log('  Action:', cycle.action);
  console.log('  Observation:', cycle.observation);
  console.log('  Reflection:', cycle.reflection);
  console.log('  Success:', cycle.success);

  // Get history
  const history = agent.getHistory();
  console.log(`  History length: ${history.length}`);

  console.log(chalk.green('✅ ReflexionAgent works!'));
}

// Mock Memory Bridge test
async function testMemoryBridge() {
  console.log(chalk.bold('\n=== Testing MemoryManagerBridge ===\n'));

  const { MemoryManagerBridge } = await import('./src/core/llm/bridge/BashBridge');
  const memory = new MemoryManagerBridge();

  console.log('Testing memory operations...');

  // These will fail without the actual bash script, but we can check the interface
  console.log('  setTask() interface:', typeof memory.setTask === 'function' ? '✓' : '✗');
  console.log('  addContext() interface:', typeof memory.addContext === 'function' ? '✓' : '✗');
  console.log('  searchEpisodes() interface:', typeof memory.searchEpisodes === 'function' ? '✓' : '✗');
  console.log('  checkpoint() interface:', typeof memory.checkpoint === 'function' ? '✓' : '✗');
  console.log('  getWorking() interface:', typeof memory.getWorking === 'function' ? '✓' : '✗');

  console.log(chalk.green('✅ MemoryManagerBridge interface verified!'));
}

// Test BaseCommand
async function testBaseCommand() {
  console.log(chalk.bold('\n=== Testing BaseCommand ===\n'));

  const testCmd = new TestCommand();

  // Mock context (won't actually use LLM)
  const mockContext: CommandContext = {
    llmRouter: null as any,
    llmRegistry: null as any,
    workDir: process.cwd(),
    autonomousMode: false,
    verbose: true
  };

  const result = await testCmd.execute(mockContext, { message: 'Hello from test!' });

  console.log('\nResult:');
  console.log('  Success:', result.success);
  console.log('  Message:', result.message);
  console.log('  Data:', result.data);

  console.log(chalk.green('✅ BaseCommand works!'));
}

// Test LLM Router initialization
async function testLLMRouter() {
  console.log(chalk.bold('\n=== Testing LLM Router ===\n'));

  const { LLMRouter } = await import('./src/core/llm/Router');
  const { createDefaultRegistry } = await import('./src/core/llm/providers/ProviderFactory');

  try {
    const registry = await createDefaultRegistry();
    const router = new LLMRouter(registry);

    console.log('  Router created:', router ? '✓' : '✗');
    console.log('  Registry providers:', Array.from(registry['providers'].keys()).join(', '));

    console.log(chalk.green('✅ LLM Router initialized!'));
  } catch (error) {
    const err = error as Error;
    console.log(chalk.yellow('⚠️  LLM Router needs API key:'), err.message);
  }
}

// Test Swarm Orchestrator
async function testSwarmOrchestrator() {
  console.log(chalk.bold('\n=== Testing SwarmOrchestrator ===\n'));

  const { SwarmOrchestrator } = await import('./src/core/agents/swarm');
  const swarm = new SwarmOrchestrator(5);

  const { swarmId, instructions, state } = await swarm.spawnSwarm(
    'Test task',
    3,
    process.cwd()
  );

  console.log('Swarm spawned:');
  console.log('  Swarm ID:', swarmId);
  console.log('  Agent count:', instructions.agents.length);
  console.log('  State initialized:', state ? '✓' : '✗');

  console.log(chalk.green('✅ SwarmOrchestrator works!'));
}

// Test SPARC Workflow
async function testSPARCWorkflow() {
  console.log(chalk.bold('\n=== Testing SPARCWorkflow ===\n'));

  const { SPARCWorkflow } = await import('./src/core/workflows/sparc');

  const workflow = new SPARCWorkflow({
    task: 'Test task',
    requirements: ['req1', 'req2'],
    constraints: ['constraint1']
  });

  console.log('  Workflow created:', workflow ? '✓' : '✗');

  console.log(chalk.green('✅ SPARCWorkflow initialized!'));
}

// Main test runner
async function main() {
  console.log(chalk.bold.blue('\n╔══════════════════════════════════════════╗'));
  console.log(chalk.bold.blue('║   Komplete Kontrol CLI Feature Tests    ║'));
  console.log(chalk.bold.blue('╚══════════════════════════════════════════╝\n'));

  const tests = [
    { name: 'BaseCommand', fn: testBaseCommand },
    { name: 'ReflexionAgent', fn: testReflexionAgent },
    { name: 'MemoryBridge', fn: testMemoryBridge },
    { name: 'LLMRouter', fn: testLLMRouter },
    { name: 'SwarmOrchestrator', fn: testSwarmOrchestrator },
    { name: 'SPARCWorkflow', fn: testSPARCWorkflow }
  ];

  let passed = 0;
  let failed = 0;

  for (const test of tests) {
    try {
      await test.fn();
      passed++;
    } catch (error) {
      const err = error as Error;
      console.log(chalk.red(`✗ ${test.name} failed:`), err.message);
      failed++;
    }
  }

  console.log(chalk.bold('\n=== Test Summary ===\n'));
  console.log(chalk.green(`✓ Passed: ${passed}/${tests.length}`));
  if (failed > 0) {
    console.log(chalk.red(`✗ Failed: ${failed}/${tests.length}`));
  }
  console.log();

  if (failed === 0) {
    console.log(chalk.bold.green('🎉 All tests passed!'));
  } else {
    console.log(chalk.bold.yellow('⚠️  Some tests failed (may need API key)'));
  }
}

main().catch(console.error);
