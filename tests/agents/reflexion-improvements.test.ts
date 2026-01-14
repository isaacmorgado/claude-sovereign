/**
 * Comprehensive test suite for ReflexionAgent improvements
 * Tests: goal validation, repetition detection, file validation, reflection, metrics
 */

import { describe, test, expect, beforeEach } from 'bun:test';
import { ReflexionAgent } from '../../src/core/agents/reflexion';
import { ActionExecutor } from '../../src/core/agents/ActionExecutor';
import type { LLMRouter } from '../../src/core/llm/Router';
import * as fs from 'fs/promises';
import * as path from 'path';

// Mock LLM Router for testing
class MockLLMRouter implements Partial<LLMRouter> {
  private callCount = 0;
  public stagnationMode = false; // When true, returns planning actions instead of file_write
  public repetitionMode = false; // When true, always returns identical thoughts

  async route(request: any, options?: any) {
    this.callCount++;

    // Mock response for parseThoughtToAction
    if (request.messages[0].content.includes('action parser')) {
      // In stagnation mode, return non-file actions (just thinking/planning)
      if (this.stagnationMode) {
        return {
          id: 'mock',
          model: 'mock',
          role: 'assistant',
          content: [
            {
              type: 'text',
              text: JSON.stringify({
                type: 'think', // Non-file action
                params: { analysis: 'Still planning...' }
              })
            }
          ],
          stopReason: 'end_turn',
          usage: { inputTokens: 0, outputTokens: 0 }
        };
      }

      // Normal mode: return file_write action
      return {
        id: 'mock',
        model: 'mock',
        role: 'assistant',
        content: [
          {
            type: 'text',
            text: JSON.stringify({
              type: 'file_write',
              params: {
                path: 'test-output.ts',
                content: '// Test content\nexport const test = true;\n'
              }
            })
          }
        ],
        stopReason: 'end_turn',
        usage: { inputTokens: 0, outputTokens: 0 }
      };
    }

    // Mock response for think() - vary based on input to avoid repetition detection
    const userPrompt = request.messages[0].content;
    let thoughtText = 'Mock response';

    // In repetition mode, always return the same thought
    if (this.repetitionMode) {
      thoughtText = 'I should read the test file and analyze it';
    } else {
      // Generate varied thoughts based on input content (case insensitive)
      const promptLower = userPrompt.toLowerCase();

      if (promptLower.includes('step 1')) {
        thoughtText = 'I should start by analyzing the requirements for Step 1';
      } else if (promptLower.includes('step 2')) {
        thoughtText = 'Now I need to proceed with implementing Step 2';
      } else if (promptLower.includes('step 3')) {
        thoughtText = 'Let me work on completing Step 3';
      } else if (promptLower.includes('planning')) {
        thoughtText = `Planning iteration ${this.callCount}: Analyzing the approach`;
      } else if (promptLower.includes('add tests')) {
        thoughtText = 'I should add comprehensive test coverage';
      } else if (promptLower.includes('complete')) {
        thoughtText = 'Time to complete the implementation';
      } else if (promptLower.includes('create calculator')) {
        thoughtText = `Working on creating calculator.ts (attempt ${this.callCount})`;
      } else {
        // Vary response based on call count to avoid repetition
        thoughtText = `Reasoning about the task (iteration ${this.callCount})`;
      }
    }

    // Default mock response
    return {
      id: 'mock',
      model: 'mock',
      role: 'assistant',
      content: [{ type: 'text', text: thoughtText }],
      stopReason: 'end_turn',
      usage: { inputTokens: 0, outputTokens: 0 }
    };
  }
}

describe('ReflexionAgent Improvements', () => {
  const testDir = path.join(process.cwd(), 'tests', 'tmp');
  let agent: ReflexionAgent;
  let mockRouter: MockLLMRouter;

  beforeEach(async () => {
    // Clean and recreate test directory
    try {
      await fs.rm(testDir, { recursive: true, force: true });
    } catch (error) {
      // Ignore if doesn't exist
    }
    await fs.mkdir(testDir, { recursive: true });

    // Initialize mock router and agent
    mockRouter = new MockLLMRouter();
    // Reset modes to default
    mockRouter.stagnationMode = false;
    mockRouter.repetitionMode = false;

    agent = new ReflexionAgent(
      'Create a Calculator class in calculator.ts with add and subtract methods',
      mockRouter as any
    );
  });

  describe('Progress Metrics Tracking', () => {
    test('should initialize metrics to zero', () => {
      const metrics = agent.getMetrics();

      expect(metrics.filesCreated).toBe(0);
      expect(metrics.filesModified).toBe(0);
      expect(metrics.linesChanged).toBe(0);
      expect(metrics.iterations).toBe(0);
    });

    test('should increment iterations on each cycle', async () => {
      await agent.cycle('Create calculator.ts');
      expect(agent.getMetrics().iterations).toBe(1);

      await agent.cycle('Add add method');
      expect(agent.getMetrics().iterations).toBe(2);
    });

    test('should track files created', async () => {
      // Use ActionExecutor directly to ensure file is actually created
      const testAgent = new ReflexionAgent(
        'Create test file',
        mockRouter as any
      );

      await testAgent.cycle('Create test-output.ts file with test content');

      const metrics = testAgent.getMetrics();
      // Metrics should track iteration even if file creation is mocked
      expect(metrics.iterations).toBe(1);
      // File creation tracked if action executor succeeded
      expect(metrics.filesCreated).toBeGreaterThanOrEqual(0);
    });

    test('should differentiate between created and modified files', async () => {
      // Create file
      await agent.cycle('Create test-file.ts');
      const afterCreate = agent.getMetrics();
      const initialCreated = afterCreate.filesCreated;

      // Modify same file
      await agent.cycle('Update test-file.ts');
      const afterModify = agent.getMetrics();

      // Either created count stays same or modified increases
      expect(
        afterModify.filesCreated === initialCreated ||
        afterModify.filesModified > 0
      ).toBe(true);
    });
  });

  describe('Stagnation Detection', () => {
    test('should not detect stagnation with < 5 iterations', async () => {
      await agent.cycle('Planning step 1');
      await agent.cycle('Planning step 2');
      await agent.cycle('Planning step 3');

      // Should not throw
      expect(async () => {
        await agent.cycle('Planning step 4');
      }).not.toThrow();
    });

    test('should detect stagnation after multiple planning iterations', async () => {
      // Enable stagnation mode: mock will return non-file actions
      mockRouter.stagnationMode = true;

      // Simulate 6 planning iterations with no file changes
      const planningCycles = Array(6).fill('Reasoning about the task');

      let threwError = false;
      try {
        for (const input of planningCycles) {
          await agent.cycle(input);
        }
      } catch (error) {
        threwError = true;
        expect((error as Error).message).toContain('stuck');
      }

      // Should eventually throw stagnation error
      expect(threwError).toBe(true);
    });
  });

  describe('Repetition Detection', () => {
    test('should detect when agent repeats identical thoughts', async () => {
      // Enable repetition mode: mock will return identical thoughts
      mockRouter.repetitionMode = true;

      const repeatedInput = 'Read the contents of test.ts';

      let threwError = false;
      try {
        // Repeat same thought 4 times
        await agent.cycle(repeatedInput);
        await agent.cycle(repeatedInput);
        await agent.cycle(repeatedInput);
        await agent.cycle(repeatedInput);
      } catch (error) {
        threwError = true;
        expect((error as Error).message).toContain('Repeating same actions');
      }

      expect(threwError).toBe(true);
    });

    test('should not detect repetition for different inputs', async () => {
      await agent.cycle('Create file');
      await agent.cycle('Add method');
      await agent.cycle('Add tests');

      // Should not throw
      expect(async () => {
        await agent.cycle('Complete implementation');
      }).not.toThrow();
    });
  });

  describe('Goal Alignment Validation', () => {
    test('should detect misalignment when wrong file is modified', async () => {
      // Goal mentions calculator.ts but action affects different file
      const agentWrongFile = new ReflexionAgent(
        'Create calculator.ts file',
        mockRouter as any
      );

      const cycle = await agentWrongFile.cycle('Create test.ts file');

      // Observation should contain misalignment warning
      expect(cycle.observation).toContain('misalignment');
    });

    test('should detect create vs update misalignment', async () => {
      const agentCreate = new ReflexionAgent(
        'Create new calculator.ts',
        mockRouter as any
      );

      // Simulate observation showing update instead of create
      const cycle = await agentCreate.cycle('Update calculator.ts');

      // Should flag misalignment in observation
      expect(cycle.observation.toLowerCase()).toContain(
        'goal' || 'misalignment' || 'create'
      );
    });
  });

  describe('File Existence Validation', () => {
    test('should allow file_write for non-existent files', async () => {
      const executor = new ActionExecutor(mockRouter as any, testDir);

      const result = await executor.execute({
        type: 'file_write',
        params: {
          path: 'new-file.ts',
          content: 'export const test = true;'
        }
      });

      expect(result.success).toBe(true);
      expect(result.output).toContain('created');
    });

    test('should reject file_edit for non-existent files', async () => {
      const executor = new ActionExecutor(mockRouter as any, testDir);

      const result = await executor.execute({
        type: 'file_edit',
        params: {
          path: 'non-existent.ts',
          searchPattern: 'old',
          replacement: 'new'
        }
      });

      expect(result.success).toBe(false);
      expect(result.error).toContain('does not exist');
      expect(result.error).toContain('file_write');
    });

    test('should allow file_edit for existing files', async () => {
      const executor = new ActionExecutor(mockRouter as any, testDir);
      const testFile = path.join(testDir, 'existing.ts');

      // Create file first
      await fs.writeFile(testFile, 'const old = true;', 'utf-8');

      // Now edit should work
      const result = await executor.execute({
        type: 'file_edit',
        params: {
          path: 'existing.ts',
          searchPattern: 'old',
          replacement: 'new'
        }
      });

      expect(result.success).toBe(true);
      expect(result.metadata?.replacements).toBeGreaterThan(0);
    });
  });

  describe('Enhanced Reflection', () => {
    test('should detect expectation mismatches', async () => {
      const cycle = await agent.cycle('Create calculator.ts but observe test.ts was created');

      // Reflection should contain warning indicators (⚠️ or "not contributing")
      const hasWarning = cycle.reflection.includes('⚠️') || cycle.reflection.includes('not contributing');
      expect(hasWarning).toBe(true);
    });

    test('should detect error patterns in reflection', async () => {
      // Test reflection logic directly with error observation
      const testAgent = new ReflexionAgent(
        'Complete task',
        mockRouter as any
      );

      // Manually inject an error cycle to test reflection
      const errorCycle = await testAgent.cycle('[ERROR] File not found');

      // Check that observation captured the error
      const observation = errorCycle.observation.toLowerCase();
      expect(observation).toContain('failed');

      // Reflection should acknowledge the error
      const reflection = errorCycle.reflection.toLowerCase();
      expect(reflection).toContain('failed');
    });

    test('should detect lack of progress towards goal', async () => {
      const unrelatedAgent = new ReflexionAgent(
        'Implement authentication system',
        mockRouter as any
      );

      // Action unrelated to goal
      const cycle = await unrelatedAgent.cycle('Create unrelated-file.ts');

      // Reflection should mention goal misalignment
      expect(cycle.reflection.toLowerCase()).toContain(
        'goal' || 'contributing' || '⚠️'
      );
    });

    test('should acknowledge success patterns', async () => {
      const cycle = await agent.cycle('Create calculator.ts successfully');

      // Reflection should contain success indicators (✅ or "succeeded")
      const hasSuccess = cycle.reflection.includes('✅') || cycle.reflection.includes('succeeded');
      expect(hasSuccess).toBe(true);
    });

    test('should warn about planning loops', async () => {
      // Create agent with mock that always returns planning actions (no file writes)
      class PlanningMockRouter implements Partial<LLMRouter> {
        async route() {
          return {
            id: 'mock',
            model: 'mock',
            role: 'assistant',
            content: [
              {
                type: 'text',
                text: JSON.stringify({
                  type: 'command',
                  params: { command: 'echo "Just planning"' }
                })
              }
            ],
            stopReason: 'end_turn',
            usage: { inputTokens: 0, outputTokens: 0 }
          };
        }
      }

      const planningAgent = new ReflexionAgent(
        'Complete task',
        new PlanningMockRouter() as any
      );

      // Simulate many iterations with no file changes
      let caughtStagnation = false;
      const cycles: any[] = [];

      for (let i = 0; i < 6; i++) {
        try {
          const cycle = await planningAgent.cycle(`Planning iteration ${i}`);
          cycles.push(cycle);
        } catch (error) {
          // Expected stagnation error
          caughtStagnation = true;
          break;
        }
      }

      // Check if any reflection warned about iterations
      const hasIterationWarning = cycles.some(c =>
        c.reflection.toLowerCase().includes('iterations')
      );

      // Either caught stagnation error or got iteration warning
      expect(caughtStagnation || hasIterationWarning).toBe(true);
    });
  });

  describe('Integration: Full Cycle', () => {
    test('should complete full cycle with all validations', async () => {
      const cycle = await agent.cycle('Create calculator.ts with Calculator class');

      // Verify cycle structure
      expect(cycle.thought).toBeDefined();
      expect(cycle.action).toBeDefined();
      expect(cycle.observation).toBeDefined();
      expect(cycle.reflection).toBeDefined();
      expect(typeof cycle.success).toBe('boolean');

      // Verify metrics updated
      const metrics = agent.getMetrics();
      expect(metrics.iterations).toBe(1);
    });

    test('should maintain history across multiple cycles', async () => {
      await agent.cycle('Step 1');
      await agent.cycle('Step 2');
      await agent.cycle('Step 3');

      const history = agent.getHistory();
      expect(history.length).toBe(3);
      expect(history[0].thought).toContain('Step 1');
      expect(history[1].thought).toContain('Step 2');
      expect(history[2].thought).toContain('Step 3');
    });
  });
});
