import type { CommandContext, CommandResult } from '../types';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import { join } from 'path';
import chalk from 'chalk';

export interface VoiceOptions {
  action: 'start' | 'stop' | 'status' | 'settings';
}

export class VoiceCommand {
  name = 'voice';

  async execute(context: CommandContext, options: VoiceOptions): Promise<CommandResult> {
    try {
      const voiceDir = join(context.workDir, '.claude', 'voice');
      const configPath = join(voiceDir, 'config.json');
      const statusPath = join(voiceDir, 'status.json');
      
      if (!existsSync(voiceDir)) {
        require('fs').mkdirSync(voiceDir, { recursive: true });
      }

      switch (options.action) {
        case 'start':
          return this.startVoice(context, configPath, statusPath);
        case 'stop':
          return this.stopVoice(context, configPath, statusPath);
        case 'status':
          return this.showStatus(context, configPath, statusPath);
        case 'settings':
          return this.showSettings(context, configPath);
        default:
          return {
            success: false,
            message: `Unknown action: ${options.action}. Use: start, stop, status, settings`
          };
      }
    } catch (error: any) {
      return {
        success: false,
        message: error.message || 'Voice command failed'
      };
    }
  }

  private startVoice(context: CommandContext, configPath: string, statusPath: string): CommandResult {
    const config = this.loadConfig(configPath);
    
    const status = {
      active: true,
      startedAt: new Date().toISOString(),
      wakeWord: config.wakeWord || 'Hey Claude',
      language: config.language || 'en-US',
      ttsEnabled: config.ttsEnabled !== false
    };

    writeFileSync(statusPath, JSON.stringify(status, null, 2));

    console.log(chalk.bold('\n=== Voice Control Started ==='));
    console.log(chalk.green('✓ Listening for wake word...'));
    console.log(chalk.cyan(`  Wake Word: "${status.wakeWord}"`));
    console.log(chalk.gray(`  Language: ${status.language}`));
    console.log(chalk.gray(`  TTS: ${status.ttsEnabled ? 'Enabled' : 'Disabled'}\n`));
    console.log(chalk.yellow('Available Commands:'));
    console.log(chalk.gray('  Navigation: "Hey Claude, show me project structure"'));
    console.log(chalk.gray('  Navigation: "Open file [filename]"'));
    console.log(chalk.gray('  Navigation: "Go to function [name]"'));
    console.log(chalk.gray('  Autonomous: "Hey Claude, start autonomous mode"'));
    console.log(chalk.gray('  Autonomous: "Stop autonomous mode"'));
    console.log(chalk.gray('  Autonomous: "What are you working on?"'));
    console.log(chalk.gray('  Checkpoints: "Create checkpoint with message [text]"'));
    console.log(chalk.gray('  Checkpoints: "Show recent checkpoints"'));
    console.log(chalk.gray('  Checkpoints: "Restore checkpoint [id]"'));
    console.log(chalk.gray('  Status: "What\'s current status?"'));
    console.log(chalk.gray('  Status: "Show me recent changes"'));
    console.log(chalk.gray('  Status: "How many tokens are we using?"'));
    console.log(chalk.gray('  Tasks: "Add task [description]"'));
    console.log(chalk.gray('  Tasks: "Mark task complete"'));
    console.log(chalk.gray('  Tasks: "Show todo list"\n'));

    return {
      success: true,
      message: 'Voice control activated'
    };
  }

  private stopVoice(context: CommandContext, configPath: string, statusPath: string): CommandResult {
    const status = this.loadStatus(statusPath);
    
    if (!status || !status.active) {
      return {
        success: false,
        message: 'Voice control is not active'
      };
    }

    status.active = false;
    status.stoppedAt = new Date().toISOString();
    writeFileSync(statusPath, JSON.stringify(status, null, 2));

    console.log(chalk.bold('\n=== Voice Control Stopped ==='));
    console.log(chalk.green('✓ Voice control deactivated\n'));

    return {
      success: true,
      message: 'Voice control stopped'
    };
  }

  private showStatus(context: CommandContext, configPath: string, statusPath: string): CommandResult {
    const config = this.loadConfig(configPath);
    const status = this.loadStatus(statusPath);

    console.log(chalk.bold('\n=== Voice Control Status ===\n'));

    if (!status) {
      console.log(chalk.yellow('Status: Inactive'));
      console.log(chalk.gray('Use: /voice start to activate\n'));
      return {
        success: true,
        message: 'Voice control is inactive'
      };
    }

    console.log(chalk.cyan(`Status: ${status.active ? 'Active' : 'Inactive'}`));
    if (status.startedAt) {
      console.log(chalk.gray(`Started: ${new Date(status.startedAt).toLocaleString()}`));
    }
    if (status.stoppedAt) {
      console.log(chalk.gray(`Stopped: ${new Date(status.stoppedAt).toLocaleString()}`));
    }
    console.log(chalk.gray(`Wake Word: "${config.wakeWord || 'Hey Claude'}"`));
    console.log(chalk.gray(`Language: ${config.language || 'en-US'}`));
    console.log(chalk.gray(`TTS: ${config.ttsEnabled !== false ? 'Enabled' : 'Disabled'}`));
    console.log(chalk.gray(`Recognition: ${config.recognitionEngine || 'whisper'}`));

    return {
      success: true,
      message: 'Voice control status displayed'
    };
  }

  private showSettings(context: CommandContext, configPath: string): CommandResult {
    const config = this.loadConfig(configPath);

    console.log(chalk.bold('\n=== Voice Control Settings ===\n'));
    console.log(chalk.cyan(`Wake Word: ${config.wakeWord || 'Hey Claude'}`));
    console.log(chalk.cyan(`Language: ${config.language || 'en-US'}`));
    console.log(chalk.cyan(`TTS Enabled: ${config.ttsEnabled !== false ? 'Yes' : 'No'}`));
    console.log(chalk.cyan(`Recognition Engine: ${config.recognitionEngine || 'whisper'}`));
    console.log(chalk.gray('\nTo change settings, edit:'));
    console.log(chalk.gray(`${configPath}\n`));

    return {
      success: true,
      message: 'Voice control settings displayed'
    };
  }

  private loadConfig(configPath: string): any {
    if (existsSync(configPath)) {
      try {
        return JSON.parse(readFileSync(configPath, 'utf-8'));
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  private loadStatus(statusPath: string): any {
    if (existsSync(statusPath)) {
      try {
        return JSON.parse(readFileSync(statusPath, 'utf-8'));
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
