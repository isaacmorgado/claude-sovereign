import type { CommandContext, CommandResult } from '../types';
import { existsSync, readFileSync, writeFileSync, readdirSync } from 'fs';
import { join } from 'path';
import chalk from 'chalk';

export interface PersonalityOptions {
  action: 'list' | 'load' | 'create' | 'edit' | 'current';
  name?: string;
}

export class PersonalityCommand {
  name = 'personality';

  async execute(context: CommandContext, options: PersonalityOptions): Promise<CommandResult> {
    try {
      const personalitiesDir = join(context.workDir, 'personalities');
      
      if (!existsSync(personalitiesDir)) {
        return {
          success: false,
          message: 'Personalities directory not found'
        };
      }

      switch (options.action) {
        case 'list':
          return this.listPersonalities(personalitiesDir);
        case 'load':
          return this.loadPersonality(context, personalitiesDir, options.name);
        case 'create':
          return this.createPersonality(personalitiesDir, options.name);
        case 'edit':
          return this.editPersonality(personalitiesDir, options.name);
        case 'current':
          return this.showCurrent(context, personalitiesDir);
        default:
          return {
            success: false,
            message: `Unknown action: ${options.action}. Use: list, load, create, edit, current`
          };
      }
    } catch (error: any) {
      return {
        success: false,
        message: error.message || 'Personality command failed'
      };
    }
  }

  private listPersonalities(personalitiesDir: string): CommandResult {
    const files = readdirSync(personalitiesDir);
    const personalities: any[] = [];

    for (const file of files) {
      if (file.endsWith('.yaml') || file.endsWith('.yml')) {
        const personalityPath = join(personalitiesDir, file);
        const content = readFileSync(personalityPath, 'utf-8');
        const nameMatch = content.match(/^name:\s*"(.+)"/m);
        const descMatch = content.match(/^description:\s*"(.+)"/m);

        if (nameMatch) {
          personalities.push({
            name: nameMatch[1],
            file: file,
            description: descMatch ? descMatch[1] : 'No description'
          });
        }
      }
    }

    if (personalities.length === 0) {
      console.log(chalk.yellow('\nNo personalities found.'));
      return {
        success: true,
        message: 'No personalities found'
      };
    }

    console.log(chalk.bold('\n=== Available Personalities ===\n'));

    for (const personality of personalities) {
      console.log(chalk.cyan(`  ${personality.name}`));
      console.log(chalk.gray(`    ${personality.description}`));
    }

    console.log(chalk.gray('\nUse: /personality load <name>'));
    console.log(chalk.gray('Use: /personality create <name>'));

    return {
      success: true,
      message: `Found ${personalities.length} personality(ies)`
    };
  }

  private loadPersonality(context: CommandContext, personalitiesDir: string, name?: string): CommandResult {
    if (!name) {
      return {
        success: false,
        message: 'Personality name required. Use: /personality load <name>'
      };
    }

    const personalityPath = join(personalitiesDir, `${name}.yaml`);
    const personalityYmlPath = join(personalitiesDir, `${name}.yml`);

    if (!existsSync(personalityPath) && !existsSync(personalityYmlPath)) {
      return {
        success: false,
        message: `Personality not found: ${name}`
      };
    }

    const activePath = join(context.workDir, '.claude', 'active-personality.txt');
    const personalityFile = existsSync(personalityPath) ? personalityPath : personalityYmlPath;
    
    writeFileSync(activePath, name);

    const content = readFileSync(personalityFile, 'utf-8');
    const descMatch = content.match(/^description:\s*"(.+)"/m);
    const focusMatch = content.match(/focus:\s*([\s\S]*?)/);

    console.log(chalk.bold('\n=== Personality Loaded ==='));
    console.log(chalk.green(`Name: ${name}`));
    if (descMatch) {
      console.log(chalk.cyan(`Description: ${descMatch[1]}`));
    }
    if (focusMatch) {
      console.log(chalk.gray(`Focus: ${focusMatch[1].substring(0, 100)}...`));
    }

    return {
      success: true,
      message: `Loaded personality: ${name}`
    };
  }

  private createPersonality(personalitiesDir: string, name?: string): CommandResult {
    if (!name) {
      return {
        success: false,
        message: 'Personality name required. Use: /personality create <name>'
      };
    }

    const personalityPath = join(personalitiesDir, `${name}.yaml`);

    if (existsSync(personalityPath)) {
      return {
        success: false,
        message: `Personality already exists: ${name}`
      };
    }

    const template = `name: "${name}"
description: "Brief description of this personality"

focus:
  - Primary domain area
  - Secondary areas
  - Specific technologies

knowledge:
  frameworks: []
  patterns: []
  tools: []

behavior:
  communication_style: "concise"  # or "detailed", "beginner-friendly"
  code_style: "functional"  # or "oop", "procedural"
  testing_preference: "tdd"  # or "integration-first", "e2e-first"
  documentation_level: "comprehensive"  # or "minimal", "inline-only"

priorities:
  - Security
  - Performance
  - Maintainability
  - Speed of delivery

constraints:
  - "Never skip error handling"
  - "Always include tests"
  - "Prefer TypeScript over JavaScript"

prompts:
  pre_task: "Before starting, analyze requirements"
  post_task: "After completion, review for quality"
`;

    writeFileSync(personalityPath, template);

    console.log(chalk.bold('\n=== Personality Created ==='));
    console.log(chalk.green(`Name: ${name}`));
    console.log(chalk.cyan(`File: ${personalityPath}`));
    console.log(chalk.gray('\nEdit the file to configure personality settings.\n'));

    return {
      success: true,
      message: `Created personality: ${name}`
    };
  }

  private editPersonality(personalitiesDir: string, name?: string): CommandResult {
    if (!name) {
      return {
        success: false,
        message: 'Personality name required. Use: /personality edit <name>'
      };
    }

    const personalityPath = join(personalitiesDir, `${name}.yaml`);
    const personalityYmlPath = join(personalitiesDir, `${name}.yml`);

    if (!existsSync(personalityPath) && !existsSync(personalityYmlPath)) {
      return {
        success: false,
        message: `Personality not found: ${name}`
      };
    }

    const personalityFile = existsSync(personalityPath) ? personalityPath : personalityYmlPath;

    console.log(chalk.bold('\n=== Edit Personality ==='));
    console.log(chalk.cyan(`File: ${personalityFile}`));
    console.log(chalk.gray('\nOpen the file to edit personality settings.\n'));

    return {
      success: true,
      message: `Edit personality: ${name}`
    };
  }

  private showCurrent(context: CommandContext, personalitiesDir: string): CommandResult {
    const activePath = join(context.workDir, '.claude', 'active-personality.txt');

    if (!existsSync(activePath)) {
      console.log(chalk.yellow('\nNo personality currently loaded.'));
      console.log(chalk.gray('Use: /personality load <name>\n'));
      return {
        success: true,
        message: 'No personality loaded'
      };
    }

    const activeName = readFileSync(activePath, 'utf-8').trim();
    const personalityPath = join(personalitiesDir, `${activeName}.yaml`);
    const personalityYmlPath = join(personalitiesDir, `${activeName}.yml`);

    if (!existsSync(personalityPath) && !existsSync(personalityYmlPath)) {
      console.log(chalk.yellow(`\nPersonality file not found: ${activeName}`));
      return {
        success: true,
        message: `Personality file missing: ${activeName}`
      };
    }

    const personalityFile = existsSync(personalityPath) ? personalityPath : personalityYmlPath;
    const content = readFileSync(personalityFile, 'utf-8');
    const descMatch = content.match(/^description:\s*"(.+)"/m);
    const focusMatch = content.match(/focus:\s*([\s\S]*?)/);

    console.log(chalk.bold('\n=== Active Personality ==='));
    console.log(chalk.green(`Name: ${activeName}`));
    if (descMatch) {
      console.log(chalk.cyan(`Description: ${descMatch[1]}`));
    }
    if (focusMatch) {
      console.log(chalk.gray(`Focus: ${focusMatch[1].substring(0, 100)}...`));
    }

    return {
      success: true,
      message: `Active personality: ${activeName}`
    };
  }
}
