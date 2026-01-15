/**
 * Base Command Class
 * Provides common functionality for all CLI commands
 */

import chalk from 'chalk';
import ora, { type Ora } from 'ora';
import type { CommandContext, CommandResult, ICommand } from './types';

export abstract class BaseCommand implements ICommand {
  abstract name: string;
  abstract description: string;

  protected spinner?: Ora;

  /**
   * Execute the command
   */
  abstract execute(context: CommandContext, args: any): Promise<CommandResult>;

  /**
   * Start a spinner with a message
   */
  protected startSpinner(message: string): void {
    this.spinner = ora(message).start();
  }

  /**
   * Update spinner text
   */
  protected updateSpinner(message: string): void {
    if (this.spinner) {
      this.spinner.text = message;
    }
  }

  /**
   * Stop spinner with success
   */
  protected succeedSpinner(message: string): void {
    if (this.spinner) {
      this.spinner.succeed(message);
      this.spinner = undefined;
    }
  }

  /**
   * Stop spinner with failure
   */
  protected failSpinner(message: string): void {
    if (this.spinner) {
      this.spinner.fail(message);
      this.spinner = undefined;
    }
  }

  /**
   * Log info message
   */
  protected info(message: string): void {
    console.log(chalk.blue('ℹ'), message);
  }

  /**
   * Log success message
   */
  protected success(message: string): void {
    console.log(chalk.green('✅'), message);
  }

  /**
   * Log warning message
   */
  protected warn(message: string): void {
    console.log(chalk.yellow('⚠'), message);
  }

  /**
   * Log error message
   */
  protected error(message: string): void {
    console.log(chalk.red('❌'), message);
  }

  /**
   * Create success result
   */
  protected createSuccess(message?: string, data?: any): CommandResult {
    return {
      success: true,
      message,
      data
    };
  }

  /**
   * Create failure result
   */
  protected createFailure(message: string, error?: Error): CommandResult {
    return {
      success: false,
      message,
      error
    };
  }
}
