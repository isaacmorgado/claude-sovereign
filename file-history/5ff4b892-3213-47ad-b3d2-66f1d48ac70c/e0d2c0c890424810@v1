/**
 * /auto Command - Autonomous Mode
 *
 * Implements the ReAct + Reflexion loop with:
 * - Smart LLM routing
 * - Memory integration
 * - Auto-checkpoint at thresholds
 * - Continuous execution until goal achieved
 */

import chalk from 'chalk';
import { BaseCommand } from '../BaseCommand';
import type { CommandContext, CommandResult, AutoConfig } from '../types';
import { ReflexionAgent, type ReflexionCycle } from '../../core/agents/reflexion';
import { MemoryManagerBridge } from '../../core/llm/bridge/BashBridge';
import { ErrorHandler } from '../../core/llm/ErrorHandler';
import { ContextManager, COMPACTION_STRATEGIES } from '../../core/llm/ContextManager';
import type { Message } from '../../core/llm/types';

export class AutoCommand extends BaseCommand {
  name = 'auto';
  description = 'Enter autonomous mode with ReAct + Reflexion loop';

  private iterations = 0;
  private memory: MemoryManagerBridge;
  private errorHandler: ErrorHandler;
  private contextManager?: ContextManager;
  private conversationHistory: Message[] = [];

  constructor() {
    super();
    this.memory = new MemoryManagerBridge();
    this.errorHandler = new ErrorHandler();
  }

  async execute(context: CommandContext, config: AutoConfig): Promise<CommandResult> {
    try {
      // Validate config
      if (!config.goal) {
        return this.createFailure('Goal is required. Usage: komplete auto "your goal"');
      }

      // Initialize
      this.info(`🤖 Autonomous mode activated`);
      this.info(`Goal: ${chalk.bold(config.goal)}`);
      console.log('');

      // Set up memory context
      await this.memory.setTask(config.goal, 'Autonomous mode execution');
      await this.memory.addContext(`Model: ${config.model || 'auto-routed'}`, 9);

      // Initialize ContextManager with 80% compaction threshold
      this.contextManager = new ContextManager(
        {
          maxTokens: 128000,  // Claude Sonnet 4.5 context window
          warningThreshold: 70,
          compactionThreshold: 80,
          strategy: COMPACTION_STRATEGIES.balanced
        },
        context.llmRouter
      );

      // Create ReflexionAgent
      const agent = new ReflexionAgent(config.goal);

      // Run autonomous loop
      const result = await this.runAutonomousLoop(agent, context, config);

      if (result.success) {
        this.success(`Goal achieved in ${this.iterations} iterations`);

        // Record success to memory
        await this.memory.recordEpisode(
          'task_complete',
          `Completed: ${config.goal}`,
          'success',
          `Iterations: ${this.iterations}`
        );
      } else {
        this.error(`Failed after ${this.iterations} iterations`);
      }

      return result;
    } catch (error) {
      const err = error as Error;
      this.failSpinner('Autonomous mode failed');

      // Classify error and provide helpful remediation
      const classified = this.errorHandler.classify(error);
      const errorMessage = this.errorHandler.formatError(classified);
      const remediations = this.errorHandler.getRemediation(classified.type);

      // Display error details
      this.error(errorMessage);
      if (remediations.length > 0) {
        console.log(chalk.gray('\nSuggested actions:'));
        remediations.forEach(r => console.log(chalk.gray(`  • ${r}`)));
      }

      return this.createFailure(errorMessage, err);
    }
  }

  /**
   * Run the autonomous ReAct + Reflexion loop
   */
  private async runAutonomousLoop(
    agent: ReflexionAgent,
    context: CommandContext,
    config: AutoConfig
  ): Promise<CommandResult> {
    const maxIterations = config.maxIterations || 50;
    let goalAchieved = false;

    this.startSpinner('Starting autonomous loop...');

    while (this.iterations < maxIterations && !goalAchieved) {
      this.iterations++;

      this.updateSpinner(`Iteration ${this.iterations}/${maxIterations}`);

      try {
        // Check context health and auto-compact if needed
        if (this.contextManager && this.conversationHistory.length > 0) {
          const health = this.contextManager.checkContextHealth(this.conversationHistory);

          if (health.status === 'warning') {
            this.warn(`Context at ${health.percentage.toFixed(1)}% - approaching limit`);
          }

          if (health.shouldCompact) {
            this.info(`🔄 Context at ${health.percentage.toFixed(1)}% - compacting...`);
            const { messages, result } = await this.contextManager.compactMessages(
              this.conversationHistory,
              `Goal: ${config.goal}`
            );

            this.conversationHistory = messages;
            this.success(
              `Compacted ${result.originalMessageCount} → ${result.compactedMessageCount} messages ` +
              `(${(result.compressionRatio * 100).toFixed(0)}% of original)`
            );

            // Record compaction to memory
            await this.memory.addContext(
              `Context compacted: ${result.compressionRatio.toFixed(2)}x compression`,
              6
            );
          }
        }

        // Execute one ReAct + Reflexion cycle
        const cycle = await this.executeReflexionCycle(agent, context, config);

        // Display cycle results
        this.displayCycle(cycle, config.verbose || false);

        // Check if goal is achieved
        goalAchieved = await this.checkGoalAchievement(
          agent,
          context,
          config.goal
        );

        // Auto-checkpoint at threshold (every 10 iterations by default)
        if (this.iterations % (config.checkpointThreshold || 10) === 0) {
          await this.performCheckpoint(config.goal);
        }

        // Brief pause between iterations
        await this.sleep(500);

      } catch (error) {
        const err = error as Error;
        this.warn(`Iteration ${this.iterations} failed: ${err.message}`);

        // Record failure and continue
        await this.memory.recordEpisode(
          'error_encountered',
          `Iteration ${this.iterations} error`,
          'failed',
          err.message
        );

        // Don't stop - autonomous mode should be resilient
        continue;
      }
    }

    this.succeedSpinner(`Autonomous loop completed`);

    if (!goalAchieved && this.iterations >= maxIterations) {
      return this.createFailure(
        `Max iterations (${maxIterations}) reached without achieving goal`
      );
    }

    return this.createSuccess('Goal achieved', {
      iterations: this.iterations,
      history: agent.getHistory()
    });
  }

  /**
   * Execute one ReAct + Reflexion cycle
   */
  private async executeReflexionCycle(
    agent: ReflexionAgent,
    context: CommandContext,
    config: AutoConfig
  ): Promise<ReflexionCycle> {
    // Get current context from memory
    const memoryContext = await this.memory.getWorking();
    const recentEpisodes = await this.memory.searchEpisodes(config.goal, 5);

    // Build prompt with context
    const prompt = this.buildCyclePrompt(config.goal, memoryContext, recentEpisodes);

    // Add to conversation history
    const userMessage: Message = { role: 'user', content: prompt };
    this.conversationHistory.push(userMessage);

    // Use LLM to generate thought
    const llmResponse = await context.llmRouter.route(
      {
        messages: [{ role: 'user', content: prompt }],
        system: 'You are an autonomous AI agent executing tasks. Think step by step.'
      },
      {
        taskType: 'reasoning',
        priority: 'quality',
        preferredModel: config.model,  // Supports provider/model syntax
        requiresUnrestricted: false
      }
    );

    // Extract text from response (handle different content types)
    const firstContent = llmResponse.content[0];
    const thought = firstContent.type === 'text' ? firstContent.text : 'Unable to extract thought';

    // Add assistant response to history
    const assistantMessage: Message = {
      role: 'assistant',
      content: llmResponse.content
    };
    this.conversationHistory.push(assistantMessage);

    // Execute the cycle with LLM-generated thought
    const cycle = await agent.cycle(thought);

    // Record to memory
    await this.memory.addContext(
      `Iteration ${this.iterations}: ${cycle.thought}`,
      7
    );

    return cycle;
  }

  /**
   * Build prompt for ReAct cycle
   */
  private buildCyclePrompt(
    goal: string,
    memoryContext: string,
    recentEpisodes: string
  ): string {
    return `
Goal: ${goal}

Context:
${memoryContext}

Recent History:
${recentEpisodes}

What is the next step to achieve this goal? Think through:
1. What has been done so far?
2. What remains to be done?
3. What is the best next action?

Provide your reasoning and proposed action.
`.trim();
  }

  /**
   * Check if goal has been achieved
   */
  private async checkGoalAchievement(
    agent: ReflexionAgent,
    context: CommandContext,
    goal: string
  ): Promise<boolean> {
    const history = agent.getHistory();

    // Simple heuristic: Check last 3 cycles for success
    const recentCycles = history.slice(-3);
    const allSuccessful = recentCycles.every(c => c.success);

    if (allSuccessful && recentCycles.length >= 3) {
      try {
        // Use LLM to verify goal achievement
        const verificationPrompt = `
Goal: ${goal}

Recent actions and results:
${recentCycles.map(c => `
Thought: ${c.thought}
Action: ${c.action}
Result: ${c.observation}
`).join('\n')}

Has the goal been achieved? Answer with just "YES" or "NO" and brief explanation.
`.trim();

        const response = await context.llmRouter.route(
          {
            messages: [{ role: 'user', content: verificationPrompt }],
            system: 'You are evaluating if a goal has been achieved. Be objective.'
          },
          {
            taskType: 'reasoning',
            priority: 'speed'
          }
        );

        // Extract text from response
        const firstContent = response.content[0];
        const answer = firstContent.type === 'text' ? firstContent.text : 'NO';
        return answer.toUpperCase().startsWith('YES');
      } catch (error) {
        // If LLM verification fails, use simple heuristic
        this.warn('LLM verification unavailable, using heuristic');
        return allSuccessful && recentCycles.length >= 3;
      }
    }

    return false;
  }

  /**
   * Perform checkpoint
   */
  private async performCheckpoint(goal: string): Promise<void> {
    this.info('📸 Auto-checkpoint triggered');

    try {
      await this.memory.checkpoint(
        `Auto checkpoint at iteration ${this.iterations}: ${goal}`
      );
      this.success('Checkpoint saved');
    } catch (error) {
      this.warn('Checkpoint failed (continuing anyway)');
    }
  }

  /**
   * Display cycle results
   */
  private displayCycle(cycle: ReflexionCycle, verbose: boolean): void {
    console.log('');
    console.log(chalk.bold(`Iteration ${this.iterations}:`));

    if (verbose) {
      console.log(chalk.gray(`Thought: ${cycle.thought}`));
      console.log(chalk.gray(`Action: ${cycle.action}`));
      console.log(chalk.gray(`Result: ${cycle.observation}`));
      console.log(chalk.gray(`Reflection: ${cycle.reflection}`));
    }

    const status = cycle.success ? chalk.green('✓ Success') : chalk.red('✗ Failed');
    console.log(status);
    console.log('');
  }

  /**
   * Sleep helper
   */
  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}
