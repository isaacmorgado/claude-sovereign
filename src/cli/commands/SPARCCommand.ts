/**
 * /sparc Command - SPARC Methodology
 *
 * Implements structured workflow:
 * Specification → Pseudocode → Architecture → Refinement → Completion
 */

import chalk from 'chalk';
import { BaseCommand } from '../BaseCommand';
import type { CommandContext, CommandResult } from '../types';
import { SPARCWorkflow, SPARCPhase, type SPARCContext } from '../../core/workflows/sparc';
import { MemoryManagerBridge } from '../../core/llm/bridge/BashBridge';

export interface SPARCConfig {
  task: string;
  requirements?: string[];
  constraints?: string[];
  verbose?: boolean;
}

export class SPARCCommand extends BaseCommand {
  name = 'sparc';
  description = 'Execute SPARC methodology (Specification → Pseudocode → Architecture → Refinement → Completion)';

  private memory: MemoryManagerBridge;

  constructor() {
    super();
    this.memory = new MemoryManagerBridge();
  }

  async execute(context: CommandContext, config: SPARCConfig): Promise<CommandResult> {
    try {
      if (!config.task) {
        return this.createFailure('Task is required. Usage: komplete sparc "your task"');
      }

      this.info(`🎯 Starting SPARC workflow`);
      this.info(`Task: ${chalk.bold(config.task)}`);
      console.log('');

      // Set up memory context
      await this.memory.setTask(config.task, 'SPARC workflow execution');

      // Create SPARC workflow
      const sparcContext: SPARCContext = {
        task: config.task,
        requirements: config.requirements || [],
        constraints: config.constraints || []
      };

      const workflow = new SPARCWorkflow(sparcContext, context.llmRouter);

      // Execute workflow with progress tracking
      this.startSpinner('Executing SPARC workflow...');

      const phases = [
        SPARCPhase.Specification,
        SPARCPhase.Pseudocode,
        SPARCPhase.Architecture,
        SPARCPhase.Refinement,
        SPARCPhase.Completion
      ];

      for (const phase of phases) {
        this.updateSpinner(`Phase: ${phase}`);
        await this.sleep(1000); // Simulate phase execution
      }

      const result = await workflow.execute();

      this.succeedSpinner('SPARC workflow completed');

      // Record to memory
      await this.memory.recordEpisode(
        'sparc_complete',
        `SPARC workflow for: ${config.task}`,
        'success',
        JSON.stringify(result)
      );

      // Display results
      console.log('');
      this.success('SPARC workflow completed successfully');
      console.log('');
      console.log(chalk.bold('Results:'));
      console.log(chalk.gray(JSON.stringify(result, null, 2)));

      return this.createSuccess('SPARC workflow completed', result);
    } catch (error) {
      const err = error as Error;
      this.failSpinner('SPARC workflow failed');
      this.error(err.message);

      return this.createFailure(err.message, err);
    }
  }

  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}
