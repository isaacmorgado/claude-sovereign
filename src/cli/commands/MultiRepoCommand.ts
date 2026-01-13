import type { CommandContext, CommandResult } from '../types';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import { join } from 'path';
import { execSync } from 'child_process';
import chalk from 'chalk';

export interface MultiRepoOptions {
  action: 'status' | 'add' | 'sync' | 'checkpoint' | 'exec';
  repos?: string[];
  message?: string;
  command?: string;
}

export class MultiRepoCommand {
  name = 'multi-repo';

  async execute(context: CommandContext, options: MultiRepoOptions): Promise<CommandResult> {
    try {
      const configDir = join(context.workDir, '.claude', 'multi-repo');
      const configPath = join(configDir, 'config.json');
      
      if (!existsSync(configDir)) {
        execSync('mkdir -p .claude/multi-repo', { cwd: context.workDir });
      }

      switch (options.action) {
        case 'status':
          return this.showStatus(context, configPath);
        case 'add':
          return this.addRepos(context, configPath, options.repos || []);
        case 'sync':
          return this.syncRepos(context, configPath);
        case 'checkpoint':
          return this.createCheckpoint(context, configPath, options.message);
        case 'exec':
          return this.execCommand(context, configPath, options.command);
        default:
          return {
            success: false,
            message: `Unknown action: ${options.action}. Use: status, add, sync, checkpoint, exec`
          };
      }
    } catch (error: any) {
      return {
        success: false,
        message: error.message || 'Multi-repo command failed'
      };
    }
  }

  private showStatus(context: CommandContext, configPath: string): CommandResult {
    if (!existsSync(configPath)) {
      console.log(chalk.yellow('\nNo repositories registered.'));
      console.log(chalk.gray('Use: /multi-repo add <path1> <path2> ...\n'));
      return {
        success: true,
        message: 'No repositories registered'
      };
    }

    const config = JSON.parse(readFileSync(configPath, 'utf-8'));
    const repos = config.repos || [];

    console.log(chalk.bold('\n=== Registered Repositories ===\n'));

    for (const repo of repos) {
      const status = this.getRepoStatus(repo.path);
      console.log(chalk.cyan(`  ${repo.name}`));
      console.log(chalk.gray(`    Path: ${repo.path}`));
      console.log(chalk.gray(`    Status: ${status}\n`));
    }

    return {
      success: true,
      message: `Found ${repos.length} registered repo(s)`
    };
  }

  private addRepos(context: CommandContext, configPath: string, repoPaths: string[]): CommandResult {
    if (repoPaths.length === 0) {
      return {
        success: false,
        message: 'Repository paths required. Use: /multi-repo add <path1> <path2> ...'
      };
    }

    let config: any = { repos: [] };
    if (existsSync(configPath)) {
      config = JSON.parse(readFileSync(configPath, 'utf-8'));
    }

    for (const repoPath of repoPaths) {
      const absolutePath = join(context.workDir, repoPath);
      if (!existsSync(absolutePath)) {
        console.log(chalk.yellow(`Warning: ${repoPath} does not exist`));
        continue;
      }

      const repoName = repoPath.split('/').pop() || repoPath;
      const existingIndex = config.repos.findIndex((r: any) => r.path === repoPath);

      if (existingIndex !== -1) {
        console.log(chalk.yellow(`Repository already registered: ${repoName}`));
      } else {
        config.repos.push({
          name: repoName,
          path: repoPath,
          addedAt: new Date().toISOString()
        });
        console.log(chalk.green(`✓ Added: ${repoName}`));
      }
    }

    writeFileSync(configPath, JSON.stringify(config, null, 2));
    console.log(chalk.gray(`\nTotal repositories: ${config.repos.length}\n`));

    return {
      success: true,
      message: `Added repositories. Total: ${config.repos.length}`
    };
  }

  private syncRepos(context: CommandContext, configPath: string): CommandResult {
    if (!existsSync(configPath)) {
      return {
        success: false,
        message: 'No repositories registered'
      };
    }

    const config = JSON.parse(readFileSync(configPath, 'utf-8'));
    const repos = config.repos || [];

    console.log(chalk.bold('\n=== Synchronizing Repositories ===\n'));

    for (const repo of repos) {
      const repoPath = join(context.workDir, repo.path);
      console.log(chalk.cyan(`Syncing: ${repo.name}...`));

      try {
        execSync('git pull', { cwd: repoPath, stdio: 'pipe' });
        console.log(chalk.green(`  ✓ ${repo.name}: Updated`));
      } catch (e) {
        console.log(chalk.yellow(`  ⚠ ${repo.name}: ${e.message || 'Failed'}`));
      }
    }

    console.log(chalk.gray('\nSynchronization complete.\n'));

    return {
      success: true,
      message: `Synchronized ${repos.length} repo(s)`
    };
  }

  private createCheckpoint(context: CommandContext, configPath: string, message?: string): CommandResult {
    if (!existsSync(configPath)) {
      return {
        success: false,
        message: 'No repositories registered'
      };
    }

    const config = JSON.parse(readFileSync(configPath, 'utf-8'));
    const repos = config.repos || [];

    console.log(chalk.bold('\n=== Creating Synchronized Checkpoint ===\n'));

    for (const repo of repos) {
      const repoPath = join(context.workDir, repo.path);
      console.log(chalk.cyan(`Checkpointing: ${repo.name}...`));

      try {
        execSync('git add -A', { cwd: repoPath });
        const commitMsg = message || `checkpoint: ${new Date().toISOString()}`;
        execSync(`git commit -m "${commitMsg}"`, { cwd: repoPath });
        console.log(chalk.green(`  ✓ ${repo.name}: Committed`));
      } catch (e) {
        console.log(chalk.yellow(`  ⚠ ${repo.name}: ${e.message || 'Failed'}`));
      }
    }

    console.log(chalk.gray('\nCheckpoint complete.\n'));

    return {
      success: true,
      message: `Checkpointed ${repos.length} repo(s)`
    };
  }

  private execCommand(context: CommandContext, configPath: string, command?: string): CommandResult {
    if (!command) {
      return {
        success: false,
        message: 'Command required. Use: /multi-repo exec "<command>"'
      };
    }

    if (!existsSync(configPath)) {
      return {
        success: false,
        message: 'No repositories registered'
      };
    }

    const config = JSON.parse(readFileSync(configPath, 'utf-8'));
    const repos = config.repos || [];

    console.log(chalk.bold('\n=== Executing Command in All Repositories ===\n'));
    console.log(chalk.cyan(`Command: ${command}\n`));

    for (const repo of repos) {
      const repoPath = join(context.workDir, repo.path);
      console.log(chalk.cyan(`Executing in: ${repo.name}...`));

      try {
        const result = execSync(command, { cwd: repoPath, stdio: 'pipe' });
        console.log(chalk.gray(`  Output: ${result.substring(0, 200)}...`));
        console.log(chalk.green(`  ✓ ${repo.name}: Success`));
      } catch (e) {
        console.log(chalk.red(`  ✗ ${repo.name}: Failed`));
        console.log(chalk.gray(`  Error: ${e.message}\n`));
      }
    }

    console.log(chalk.gray('\nExecution complete.\n'));

    return {
      success: true,
      message: `Executed in ${repos.length} repo(s)`
    };
  }

  private getRepoStatus(repoPath: string): string {
    try {
      execSync('git rev-parse --git-dir', { cwd: repoPath, stdio: 'ignore' });
      const status = execSync('git status --short', { cwd: repoPath, stdio: 'pipe' });
      if (status.trim() === '') {
        return 'Clean';
      }
      return 'Modified';
    } catch {
      return 'Not a git repo';
    }
  }
}
