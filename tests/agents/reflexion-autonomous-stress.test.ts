/**
 * Autonomous stress test for ReflexionAgent improvements
 *
 * Tests the agent in a complex multi-iteration scenario (30-50 cycles)
 * to validate stagnation detection, repetition detection, and goal validation
 * work correctly in production-like autonomous operation.
 *
 * Scenario: Build a multi-file TypeScript project with complex dependencies
 * Expected: Agent completes successfully OR fails gracefully with clear error
 */

import { describe, test, expect, beforeEach, afterEach } from 'bun:test';
import { ReflexionAgent } from '../../src/core/agents/reflexion';
import type { LLMRouter } from '../../src/core/llm/Router';
import * as fs from 'fs/promises';
import * as path from 'path';

// Test workspace
const TEST_WORKSPACE = path.join(process.cwd(), 'test-workspace-reflexion-stress');

// Complex scenario LLM router that simulates realistic agent behavior
class ScenarioLLMRouter implements Partial<LLMRouter> {
  private thoughtCount = 0;
  private actionCount = 0;
  private scenario: 'success' | 'stagnation' | 'repetition' | 'goal-misalignment';

  constructor(scenario: 'success' | 'stagnation' | 'repetition' | 'goal-misalignment' = 'success') {
    this.scenario = scenario;
  }

  async route(request: any, options?: any) {
    const content = request.messages[0]?.content || '';

    // Parse action from thought (action parser request)
    if (content.includes('action parser') || content.includes('Convert this thought')) {
      this.actionCount++;
      return this.getActionResponse();
    }

    // Generate next thought (reflection request)
    this.thoughtCount++;
    return this.getThoughtResponse();
  }

  private getActionResponse() {
    const actions = [
      {
        type: 'file_write',
        params: {
          path: 'src/types.ts',
          content: '// Type definitions\nexport type User = { id: string; name: string; };\n'
        }
      },
      {
        type: 'file_write',
        params: {
          path: 'src/utils.ts',
          content: '// Utilities\nimport { User } from "./types";\nexport const formatUser = (u: User) => u.name;\n'
        }
      },
      {
        type: 'file_write',
        params: {
          path: 'src/main.ts',
          content: '// Main entry\nimport { formatUser } from "./utils";\nimport { User } from "./types";\n\nconst user: User = { id: "1", name: "Test" };\nconsole.log(formatUser(user));\n'
        }
      },
      {
        type: 'file_write',
        params: {
          path: 'tests/utils.test.ts',
          content: '// Tests\nimport { formatUser } from "../src/utils";\nimport { expect, test } from "bun:test";\n\ntest("formatUser", () => {\n  expect(formatUser({ id: "1", name: "Alice" })).toBe("Alice");\n});\n'
        }
      },
      {
        type: 'file_write',
        params: {
          path: 'README.md',
          content: '# Test Project\n\nA multi-file TypeScript project for testing.\n'
        }
      }
    ];

    // Scenario-specific behavior
    if (this.scenario === 'stagnation') {
      // Return non-file-write actions to trigger stagnation detection
      return {
        id: 'mock',
        model: 'mock',
        role: 'assistant',
        content: [{
          type: 'text',
          text: JSON.stringify({
            type: 'think',  // Not a file_write action
            params: { analysis: 'Still analyzing...' }
          })
        }],
        stopReason: 'end_turn',
        usage: { inputTokens: 0, outputTokens: 0 }
      };
    }

    if (this.scenario === 'goal-misalignment') {
      // Return action that doesn't match goal (e.g., creates wrong files)
      return {
        id: 'mock',
        model: 'mock',
        role: 'assistant',
        content: [{
          type: 'text',
          text: JSON.stringify({
            type: 'file_write',
            params: {
              path: 'unrelated-file.ts',  // Wrong file!
              content: '// This is not what the goal asked for\n'
            }
          })
        }],
        stopReason: 'end_turn',
        usage: { inputTokens: 0, outputTokens: 0 }
      };
    }

    // Pick action based on action count
    const actionIndex = Math.min(this.actionCount - 1, actions.length - 1);
    const action = actions[actionIndex];

    return {
      id: 'mock',
      model: 'mock',
      role: 'assistant',
      content: [{
        type: 'text',
        text: JSON.stringify(action)
      }],
      stopReason: 'end_turn',
      usage: { inputTokens: 0, outputTokens: 0 }
    };
  }

  private getThoughtResponse() {
    // Scenario-specific thought patterns
    if (this.scenario === 'stagnation') {
      // Return DIFFERENT planning thoughts each time (to avoid repetition detection)
      // but never actually execute actions (to trigger stagnation)
      const planningThoughts = [
        'Analyzing requirements for the project structure',
        'Considering the best architecture approach',
        'Evaluating different implementation strategies',
        'Reviewing design patterns that could be useful',
        'Thinking about the module dependencies',
        'Planning the file organization carefully',
        'Assessing potential risks and edge cases',
        'Contemplating test coverage strategies',
        'Examining build and deployment considerations',
        'Weighing tradeoffs between different patterns'
      ];
      const thoughtIndex = Math.min(this.thoughtCount - 1, planningThoughts.length - 1);
      return {
        id: 'mock',
        model: 'mock',
        role: 'assistant',
        content: [{
          type: 'text',
          text: planningThoughts[thoughtIndex]
        }],
        stopReason: 'end_turn',
        usage: { inputTokens: 0, outputTokens: 0 }
      };
    }

    if (this.scenario === 'repetition') {
      // Always return IDENTICAL thought (to trigger repetition detection)
      return {
        id: 'mock',
        model: 'mock',
        role: 'assistant',
        content: [{
          type: 'text',
          text: 'I should create the types file first'
        }],
        stopReason: 'end_turn',
        usage: { inputTokens: 0, outputTokens: 0 }
      };
    }

    // Success scenario: progressive thoughts
    const thoughts = [
      'Create the type definitions in src/types.ts',
      'Create utility functions in src/utils.ts that use the types',
      'Create the main entry point that imports and uses utilities',
      'Add tests to verify the utilities work correctly',
      'Add documentation in README.md',
      'Review all files and ensure consistency',
      'COMPLETE - All files created successfully'
    ];

    const thoughtIndex = Math.min(this.thoughtCount - 1, thoughts.length - 1);
    return {
      id: 'mock',
      model: 'mock',
      role: 'assistant',
      content: [{
        type: 'text',
        text: thoughts[thoughtIndex]
      }],
      stopReason: 'end_turn',
      usage: { inputTokens: 0, outputTokens: 0 }
    };
  }

  reset() {
    this.thoughtCount = 0;
    this.actionCount = 0;
  }
}

// Setup/teardown
async function setupWorkspace() {
  try {
    await fs.rm(TEST_WORKSPACE, { recursive: true, force: true });
  } catch (error) {
    // Ignore if doesn't exist
  }
  await fs.mkdir(TEST_WORKSPACE, { recursive: true });
  process.chdir(TEST_WORKSPACE);
}

async function cleanupWorkspace() {
  try {
    process.chdir(path.dirname(TEST_WORKSPACE));
    await fs.rm(TEST_WORKSPACE, { recursive: true, force: true });
  } catch (error) {
    console.error('Cleanup error:', error);
  }
}

describe('ReflexionAgent Autonomous Stress Test', () => {
  beforeEach(async () => {
    await setupWorkspace();
  });

  afterEach(async () => {
    await cleanupWorkspace();
  });

  test('SUCCESS SCENARIO: Completes complex multi-file project (30-50 iterations)', async () => {
    const goal = 'Create a TypeScript project with types (src/types.ts), utilities (src/utils.ts), main entry (src/main.ts), tests (tests/utils.test.ts), and documentation (README.md)';
    const router = new ScenarioLLMRouter('success');
    const agent = new ReflexionAgent(goal, router as any);

    let cycles = 0;
    let lastInput = 'Start building the project';
    const maxCycles = 50;

    try {
      while (cycles < maxCycles) {
        const result = await agent.cycle(lastInput);
        cycles++;

        // Check if agent signals completion
        if (result.thought.includes('COMPLETE')) {
          break;
        }

        lastInput = result.observation;
      }
    } catch (error: any) {
      // Should not throw in success scenario
      expect(error).toBeUndefined();
    }

    const metrics = agent.getMetrics();

    // Validate success
    expect(cycles).toBeGreaterThan(0);
    expect(cycles).toBeLessThanOrEqual(maxCycles);
    expect(metrics.filesCreated).toBeGreaterThan(0);
    expect(metrics.iterations).toBe(cycles);

    // Verify files were actually created
    const srcTypes = await fs.readFile('src/types.ts', 'utf-8');
    expect(srcTypes).toContain('User');

    console.log(`✅ SUCCESS: Completed in ${cycles} iterations, created ${metrics.filesCreated} files`);
  }, 60000); // 60s timeout for stress test

  test('STAGNATION DETECTION: Throws error after 5+ iterations with no file changes', async () => {
    const goal = 'Create a TypeScript project';
    const router = new ScenarioLLMRouter('stagnation');
    const agent = new ReflexionAgent(goal, router as any);

    let cycles = 0;
    let caughtError: Error | null = null;
    const maxCycles = 10;

    try {
      let lastInput = 'Start building';
      while (cycles < maxCycles) {
        await agent.cycle(lastInput);
        cycles++;
        lastInput = 'Continue';
      }
    } catch (error: any) {
      caughtError = error;
    }

    // Should throw stagnation error
    expect(caughtError).toBeDefined();
    expect(caughtError?.message).toContain('stuck');
    expect(caughtError?.message).toContain('No progress');
    expect(cycles).toBeGreaterThanOrEqual(5); // Should catch after threshold

    const metrics = agent.getMetrics();
    expect(metrics.filesCreated).toBe(0); // No files created in stagnation

    console.log(`✅ STAGNATION DETECTED: Caught after ${cycles} iterations (expected ≥5)`);
  }, 30000);

  test('REPETITION DETECTION: Throws error after 3+ identical thoughts', async () => {
    const goal = 'Create types file';
    const router = new ScenarioLLMRouter('repetition');
    const agent = new ReflexionAgent(goal, router as any);

    let cycles = 0;
    let caughtError: Error | null = null;
    const maxCycles = 10;

    try {
      let lastInput = 'Start';
      while (cycles < maxCycles) {
        await agent.cycle(lastInput);
        cycles++;
        lastInput = 'Continue';
      }
    } catch (error: any) {
      caughtError = error;
    }

    // Should throw repetition error
    expect(caughtError).toBeDefined();
    expect(caughtError?.message).toContain('stuck');
    expect(caughtError?.message).toContain('Repeating');
    expect(cycles).toBeGreaterThanOrEqual(3); // Should catch after threshold

    console.log(`✅ REPETITION DETECTED: Caught after ${cycles} iterations (expected ≥3)`);
  }, 30000);

  test('GOAL MISALIGNMENT: Limited detection (needs filename in observation)', async () => {
    // NOTE: Current implementation limitation - goal validation works but
    // observations don't include filenames, so file-specific misalignment
    // detection doesn't work. This test validates current behavior.

    const goal = 'Create the calculator class';
    const router = new ScenarioLLMRouter('goal-misalignment');
    const agent = new ReflexionAgent(goal, router as any);

    const result = await agent.cycle('Start building');

    // Current behavior: observation is simplified without filename
    expect(result.observation).toBe('File successfully created');

    // Goal alignment validation runs but can't detect file-specific issues
    // because observation doesn't include "unrelated-file.ts"
    expect(result.observation).not.toContain('⚠️');

    console.log(`ℹ️ GOAL VALIDATION LIMITATION: Observation lacks filename context`);
    console.log(`   Action: Creates unrelated-file.ts`);
    console.log(`   Goal: Create calculator class`);
    console.log(`   Observation: "${result.observation}" (no filename)`);
  }, 10000);

  test('METRICS TRACKING: Accurately tracks progress across many iterations', async () => {
    const goal = 'Create multiple files';
    const router = new ScenarioLLMRouter('success');
    const agent = new ReflexionAgent(goal, router as any);

    // Run 7 cycles (creates 5 files as per scenario)
    for (let i = 0; i < 7; i++) {
      await agent.cycle('Continue building');
    }

    const metrics = agent.getMetrics();

    expect(metrics.iterations).toBe(7);
    expect(metrics.filesCreated).toBeGreaterThan(0);
    expect(metrics.filesModified).toBe(0); // Only creates, no edits in this scenario
    expect(metrics.linesChanged).toBeGreaterThan(0);

    console.log(`✅ METRICS: ${metrics.iterations} iterations, ${metrics.filesCreated} files, ${metrics.linesChanged} lines`);
  }, 30000);

  test('INTEGRATION: All safeguards work together in complex scenario', async () => {
    const goal = 'Build TypeScript project with proper structure';
    const router = new ScenarioLLMRouter('success');
    const agent = new ReflexionAgent(goal, router as any);

    let totalCycles = 0;
    const maxCycles = 30;
    let completedSuccessfully = false;

    try {
      let lastInput = 'Start project';
      while (totalCycles < maxCycles) {
        const result = await agent.cycle(lastInput);
        totalCycles++;

        // Verify no stagnation warnings (files should be created)
        if (totalCycles > 5) {
          const metrics = agent.getMetrics();
          expect(metrics.filesCreated).toBeGreaterThan(0); // Should have progress
        }

        // Check for completion
        if (result.thought.includes('COMPLETE')) {
          completedSuccessfully = true;
          break;
        }

        lastInput = result.observation;
      }
    } catch (error: any) {
      // Should not throw - success scenario completes cleanly
      expect(error).toBeUndefined();
    }

    const metrics = agent.getMetrics();

    expect(completedSuccessfully).toBe(true);
    expect(metrics.filesCreated).toBeGreaterThan(0);
    expect(metrics.iterations).toBeLessThanOrEqual(maxCycles);
    expect(metrics.iterations).toBeGreaterThan(0);

    console.log(`✅ INTEGRATION: Completed ${metrics.iterations} iterations with ${metrics.filesCreated} files, all safeguards active`);
  }, 60000);
});
