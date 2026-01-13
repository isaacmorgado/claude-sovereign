/**
 * /reflect Command - Reflexion Loop
 *
 * Implements ReAct + Reflexion pattern:
 * Think → Act → Observe → Reflect
 */

import chalk from 'chalk';
import { BaseCommand } from '../BaseCommand';
import type { CommandContext, CommandResult } from '../types';
import { ReflexionAgent, type ReflexionCycle } from '../../core/agents/reflexion';
import { MemoryManagerBridge } from '../../core/llm/bridge/BashBridge';

export interface ReflectConfig {
  goal: string;
  iterations?: number;
  verbose?: boolean;
}

export class ReflectCommand extends BaseCommand {
  name = 'reflect';
  description = 'Run ReAct + Reflexion loop (Think → Act → Observe → Reflect)';

  private memory: MemoryManagerBridge;

  constructor() {
    super();
    this.memory = new MemoryManagerBridge();
  }

  async execute(context: CommandContext, config: ReflectConfig): Promise<CommandResult> {
    try {
      if (!config.goal) {
        return this.createFailure('Goal is required. Usage: komplete reflect "your goal"');
      }

      const iterations = config.iterations || 3;

      this.info(`🔄 Starting Reflexion loop`);
      this.info(`Goal: ${chalk.bold(config.goal)}`);
      this.info(`Iterations: ${iterations}`);
      console.log('');

      // Set up memory context
      await this.memory.setTask(config.goal, 'Reflexion loop execution');

      // Create Reflexion agent
      const agent = new ReflexionAgent(config.goal);

      // Run reflexion cycles
      this.startSpinner('Running reflexion cycles...');

      const cycles: ReflexionCycle[] = [];

      for (let i = 0; i < iterations; i++) {
        this.updateSpinner(`Cycle ${i + 1}/${iterations}`);

        // Execute cycle with LLM-generated input
        const input = await this.generateInput(context, config.goal, agent.getHistory());
        const cycle = await agent.cycle(input);

        cycles.push(cycle);

        // Display cycle if verbose
        if (config.verbose) {
          this.displayCycle(i + 1, cycle);
        }

        // Brief pause between cycles
        await this.sleep(500);

        // Record to memory
        await this.memory.addContext(
          `Cycle ${i + 1}: ${cycle.thought}`,
          7
        );
      }

      this.succeedSpinner('Reflexion loop completed');

      // Record to memory
      await this.memory.recordEpisode(
        'reflexion_complete',
        `Reflexion for: ${config.goal}`,
        'success',
        `${cycles.length} cycles`
      );

      // Display summary
      console.log('');
      this.success('Reflexion loop completed successfully');
      console.log('');
      this.displaySummary(cycles);

      return this.createSuccess('Reflexion loop completed', {
        cycles,
        history: agent.getHistory()
      });
    } catch (error) {
      const err = error as Error;
      this.failSpinner('Reflexion loop failed');
      this.error(err.message);

      return this.createFailure(err.message, err);
    }
  }

  /**
   * Generate input for next cycle using LLM
   */
  private async generateInput(
    context: CommandContext,
    goal: string,
    history: ReflexionCycle[]
  ): Promise<string> {
    const prompt = this.buildInputPrompt(goal, history);

    const response = await context.llmRouter.route(
      {
        messages: [{ role: 'user', content: prompt }],
        system: 'You are generating input for a reflexion cycle. Be concise and actionable.'
      },
      {
        taskType: 'reasoning',
        priority: 'speed'
      }
    );

    const firstContent = response.content[0];
    return firstContent.type === 'text' ? firstContent.text : 'Continue working on goal';
  }

  /**
   * Build prompt for generating cycle input
   */
  private buildInputPrompt(goal: string, history: ReflexionCycle[]): string {
    if (history.length === 0) {
      return `Goal: ${goal}\n\nWhat is the first step to achieve this goal?`;
    }

    const lastCycle = history[history.length - 1];

    return `
Goal: ${goal}

Previous cycle:
- Thought: ${lastCycle.thought}
- Action: ${lastCycle.action}
- Observation: ${lastCycle.observation}
- Reflection: ${lastCycle.reflection}
- Success: ${lastCycle.success ? 'Yes' : 'No'}

What should be the next step?
`.trim();
  }

  /**
   * Display a single cycle
   */
  private displayCycle(iteration: number, cycle: ReflexionCycle): void {
    console.log('');
    console.log(chalk.bold(`Cycle ${iteration}:`));
    console.log(chalk.gray(`Thought: ${cycle.thought}`));
    console.log(chalk.gray(`Action: ${cycle.action}`));
    console.log(chalk.gray(`Observation: ${cycle.observation}`));
    console.log(chalk.gray(`Reflection: ${cycle.reflection}`));
    console.log(cycle.success ? chalk.green('✓ Success') : chalk.red('✗ Failed'));
  }

  /**
   * Display summary of all cycles
   */
  private displaySummary(cycles: ReflexionCycle[]): void {
    const successCount = cycles.filter(c => c.success).length;
    const failCount = cycles.length - successCount;

    console.log(chalk.bold('Summary:'));
    console.log(`  Total cycles: ${cycles.length}`);
    console.log(`  ${chalk.green('✓')} Successful: ${successCount}`);
    console.log(`  ${chalk.red('✗')} Failed: ${failCount}`);
    console.log('');

    if (cycles.length > 0) {
      console.log(chalk.bold('Key Insights:'));
      cycles.forEach((cycle, i) => {
        console.log(`  ${i + 1}. ${chalk.gray(cycle.reflection)}`);
      });
    }
  }

  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}
