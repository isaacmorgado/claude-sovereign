/**
 * /swarm Command - Swarm Orchestration
 *
 * Implements distributed agent swarms for parallel task execution
 * Based on autonomous-orchestrator-v2 and swarm-orchestrator hooks
 */

import chalk from 'chalk';
import { BaseCommand } from '../BaseCommand';
import type { CommandContext, CommandResult } from '../types';
import { SwarmOrchestrator } from '../../core/agents/swarm';
import { MemoryManagerBridge } from '../../core/llm/bridge/BashBridge';

export interface SwarmConfig {
  action: 'spawn' | 'status' | 'collect' | 'clear';
  task?: string;
  agentCount?: number;
  swarmId?: string;
  workDir?: string;
  verbose?: boolean;
}

export class SwarmCommand extends BaseCommand {
  name = 'swarm';
  description = 'Spawn and manage distributed agent swarms for parallel execution';

  private orchestrator: SwarmOrchestrator;
  private memory: MemoryManagerBridge;

  constructor() {
    super();
    this.orchestrator = new SwarmOrchestrator(10);
    this.memory = new MemoryManagerBridge();
  }

  async execute(context: CommandContext, config: SwarmConfig): Promise<CommandResult> {
    try {
      switch (config.action) {
        case 'spawn':
          return await this.spawnSwarm(context, config);
        case 'status':
          return await this.showStatus(config);
        case 'collect':
          return await this.collectResults(config);
        case 'clear':
          return await this.clearSwarm(config);
        default:
          return this.createFailure(
            `Unknown action: ${config.action}. Use: spawn, status, collect, clear`
          );
      }
    } catch (error) {
      const err = error as Error;
      this.error(err.message);
      return this.createFailure(err.message, err);
    }
  }

  /**
   * Spawn a new swarm
   */
  private async spawnSwarm(
    context: CommandContext,
    config: SwarmConfig
  ): Promise<CommandResult> {
    if (!config.task) {
      return this.createFailure('Task is required. Usage: komplete swarm spawn N "task description"');
    }

    if (!config.agentCount || config.agentCount < 2) {
      return this.createFailure('Agent count must be >= 2');
    }

    this.info(`🚀 Spawning swarm with ${config.agentCount} agents`);
    this.info(`Task: ${chalk.bold(config.task)}`);
    console.log('');

    const workDir = config.workDir || process.cwd();

    this.startSpinner('Spawning swarm...');

    const result = await this.orchestrator.spawnSwarm(
      config.task,
      config.agentCount,
      workDir,
      {
        github: true,  // Assuming GitHub MCP is available
        chrome: false
      }
    );

    this.succeedSpinner(`Swarm spawned: ${result.swarmId}`);

    // Record to memory
    await this.memory.recordEpisode(
      'swarm_spawned',
      `Swarm ${result.swarmId}: ${config.task}`,
      'success',
      `${config.agentCount} agents`
    );

    // Display spawn instructions
    console.log('');
    this.success('Swarm spawned successfully');
    console.log('');
    console.log(chalk.bold('Swarm ID:'), chalk.cyan(result.swarmId));
    console.log(chalk.bold('Agents:'), config.agentCount);
    console.log(chalk.bold('Status:'), 'Running');
    console.log('');

    if (config.verbose) {
      console.log(chalk.bold('Instructions:'));
      console.log(chalk.gray(JSON.stringify(result.instructions, null, 2)));
      console.log('');
    }

    return this.createSuccess('Swarm spawned', {
      swarmId: result.swarmId,
      agentCount: config.agentCount,
      state: result.state
    });
  }

  /**
   * Show swarm status
   */
  private async showStatus(config: SwarmConfig): Promise<CommandResult> {
    if (!config.swarmId) {
      return this.createFailure('Swarm ID is required');
    }

    const state = this.orchestrator.getSwarmState(config.swarmId);

    if (!state) {
      return this.createFailure(`Swarm ${config.swarmId} not found`);
    }

    const status = this.orchestrator.getCompletionStatus(config.swarmId);

    console.log('');
    console.log(chalk.bold('Swarm Status'));
    console.log('');
    console.log(chalk.bold('Swarm ID:'), chalk.cyan(config.swarmId));
    console.log(chalk.bold('Task:'), state.task);
    console.log(chalk.bold('Agents:'), state.agentCount);
    console.log(chalk.bold('Complete:'), status.complete ? chalk.green('Yes') : chalk.yellow('No'));
    console.log('');
    console.log(chalk.bold('Results:'));
    console.log(`  ${chalk.green('✓')} Success: ${status.success}`);
    console.log(`  ${chalk.red('✗')} Failed: ${status.failed}`);
    console.log(`  ${chalk.gray('○')} Pending: ${status.pending}`);
    console.log('');

    return this.createSuccess('Status retrieved', { state, status });
  }

  /**
   * Collect results from swarm
   */
  private async collectResults(config: SwarmConfig): Promise<CommandResult> {
    if (!config.swarmId) {
      return this.createFailure('Swarm ID is required');
    }

    this.info(`📦 Collecting results from swarm: ${config.swarmId}`);
    console.log('');

    this.startSpinner('Collecting and merging results...');

    const result = await this.orchestrator.collectResults(config.swarmId);

    this.succeedSpinner('Results collected');

    // Record to memory
    await this.memory.recordEpisode(
      'swarm_collected',
      `Swarm ${config.swarmId} results collected`,
      'success',
      JSON.stringify(result.merged)
    );

    // Display results
    console.log('');
    this.success('Results collected and merged');
    console.log('');
    console.log(chalk.bold('Report:'));
    console.log('');
    console.log(result.report);
    console.log('');

    if (result.integration) {
      console.log(chalk.bold('Code Integration:'));
      console.log(chalk.gray('Changes merged to main branch'));
      console.log('');
    }

    return this.createSuccess('Results collected', result);
  }

  /**
   * Clear swarm state
   */
  private async clearSwarm(config: SwarmConfig): Promise<CommandResult> {
    if (!config.swarmId) {
      return this.createFailure('Swarm ID is required');
    }

    this.orchestrator.clearSwarm(config.swarmId);

    this.success(`Swarm ${config.swarmId} cleared`);

    return this.createSuccess('Swarm cleared');
  }
}
