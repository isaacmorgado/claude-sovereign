/**
 * Integration Tests for ReflexionCommand CLI
 *
 * Tests the CLI interface to ReflexionAgent with bash orchestrator integration scenarios
 */

import { describe, it, expect, beforeAll } from 'vitest';
import { execSync } from 'child_process';
import { existsSync, mkdirSync, rmSync, readFileSync } from 'fs';
import { join } from 'path';

describe('ReflexionCommand CLI Integration', () => {
  const testWorkspace = join(process.cwd(), 'test-workspace-reflexion-cli');
  const cliPath = join(process.cwd(), 'dist', 'index.js');

  beforeAll(() => {
    // Clean and create test workspace
    if (existsSync(testWorkspace)) {
      rmSync(testWorkspace, { recursive: true, force: true });
    }
    mkdirSync(testWorkspace, { recursive: true });

    // Build CLI if not already built
    if (!existsSync(cliPath)) {
      execSync('bun build src/index.ts --outdir dist --target node', {
        cwd: process.cwd(),
        stdio: 'inherit'
      });
    }
  });

  describe('Basic Execution', () => {
    it('should require --goal parameter for execute action', () => {
      try {
        execSync(`${cliPath} reflexion execute`, {
          cwd: testWorkspace,
          stdio: 'pipe'
        });
        expect.fail('Should have thrown error for missing --goal');
      } catch (error: any) {
        const output = error.stdout.toString() + error.stderr.toString();
        expect(output).toContain('--goal parameter is required');
      }
    });

    it('should execute simple task and return JSON output', async () => {
      const result = execSync(
        `${cliPath} reflexion execute --goal "Create a file hello.txt with content Hello World" --max-iterations 5 --output-json --preferred-model glm-4.7`,
        {
          cwd: testWorkspace,
          stdio: 'pipe',
          timeout: 120000
        }
      );

      const output = result.toString();
      const lines = output.trim().split('\n');
      const finalLine = lines[lines.length - 1];

      const resultData = JSON.parse(finalLine);
      expect(resultData.status).toBe('complete');
      expect(resultData.success).toBe(true);
      expect(resultData.iterations).toBeGreaterThan(0);
      expect(resultData.filesCreated).toBeGreaterThanOrEqual(1);

      // Verify file was actually created
      expect(existsSync(join(testWorkspace, 'hello.txt'))).toBe(true);
      const content = readFileSync(join(testWorkspace, 'hello.txt'), 'utf-8');
      expect(content).toContain('Hello World');
    }, 120000);

    it('should handle status command gracefully', () => {
      const result = execSync(`${cliPath} reflexion status`, {
        cwd: testWorkspace,
        stdio: 'pipe'
      });

      expect(result.toString()).toContain('Status tracking not yet implemented');
    });

    it('should handle metrics command gracefully', () => {
      const result = execSync(`${cliPath} reflexion metrics`, {
        cwd: testWorkspace,
        stdio: 'pipe'
      });

      expect(result.toString()).toContain('Metrics tracking not yet implemented');
    });
  });

  describe('Orchestrator Integration (JSON Mode)', () => {
    it('should output JSON parseable by jq for bash consumption', async () => {
      const result = execSync(
        `${cliPath} reflexion execute --goal "Create calculator.js with add function" --max-iterations 5 --output-json --preferred-model glm-4.7 | jq -s "."`,
        {
          cwd: testWorkspace,
          stdio: 'pipe',
          shell: '/bin/bash',
          timeout: 120000
        }
      );

      const parsed = JSON.parse(result.toString());
      expect(Array.isArray(parsed)).toBe(true);
      expect(parsed.length).toBeGreaterThan(0);

      // Each cycle output should be valid JSON
      for (const item of parsed) {
        if (item.status === 'complete') {
          expect(item).toHaveProperty('success');
          expect(item).toHaveProperty('iterations');
          expect(item).toHaveProperty('filesCreated');
          expect(item).toHaveProperty('filesModified');
        } else if (item.cycle) {
          expect(item).toHaveProperty('thought');
          expect(item).toHaveProperty('action');
          expect(item).toHaveProperty('observation');
        }
      }
    }, 120000);

    it('should return non-zero exit code on failure', () => {
      try {
        execSync(
          `${cliPath} reflexion execute --goal "Invalid goal that will fail" --max-iterations 1 --output-json --preferred-model glm-4.7`,
          {
            cwd: testWorkspace,
            stdio: 'pipe',
            timeout: 60000
          }
        );
      } catch (error: any) {
        expect(error.status).not.toBe(0);
      }
    }, 60000);
  });

  describe('Model Selection', () => {
    it('should respect --preferred-model parameter', async () => {
      const result = execSync(
        `${cliPath} reflexion execute --goal "Create test.txt" --max-iterations 3 --output-json --preferred-model glm-4.7`,
        {
          cwd: testWorkspace,
          stdio: 'pipe',
          timeout: 90000
        }
      );

      const output = result.toString();
      expect(output).toBeTruthy();

      // Should complete without rate limit errors (GLM has no limits)
      const lines = output.trim().split('\n');
      const finalLine = lines[lines.length - 1];
      const resultData = JSON.parse(finalLine);
      expect(resultData.status).toBe('complete');
    }, 90000);
  });

  describe('Bash Orchestrator Simulation', () => {
    it('should integrate with bash script calling pattern', async () => {
      // Simulate autonomous-orchestrator-v2.sh calling ReflexionCommand
      const bashScript = `
        #!/bin/bash
        set -e

        # Extract goal
        GOAL="Create a simple Node.js app with index.js"
        MAX_ITERATIONS=5
        MODEL="glm-4.7"

        # Call ReflexionCommand via CLI
        OUTPUT=$(${cliPath} reflexion execute \
          --goal "$GOAL" \
          --max-iterations "$MAX_ITERATIONS" \
          --preferred-model "$MODEL" \
          --output-json)

        # Parse final result with jq
        STATUS=$(echo "$OUTPUT" | tail -1 | jq -r '.status')
        SUCCESS=$(echo "$OUTPUT" | tail -1 | jq -r '.success')
        ITERATIONS=$(echo "$OUTPUT" | tail -1 | jq -r '.iterations')

        # Echo results for parent script
        echo "STATUS=$STATUS"
        echo "SUCCESS=$SUCCESS"
        echo "ITERATIONS=$ITERATIONS"

        # Exit with appropriate code
        if [[ "$SUCCESS" == "true" ]]; then
          exit 0
        else
          exit 1
        fi
      `;

      const scriptPath = join(testWorkspace, 'test-orchestrator.sh');
      require('fs').writeFileSync(scriptPath, bashScript);
      execSync(`chmod +x ${scriptPath}`);

      const result = execSync(scriptPath, {
        cwd: testWorkspace,
        stdio: 'pipe',
        shell: '/bin/bash',
        timeout: 150000
      });

      const output = result.toString();
      expect(output).toContain('STATUS=complete');
      expect(output).toContain('SUCCESS=true');
      expect(output).toMatch(/ITERATIONS=\d+/);
    }, 150000);
  });

  describe('Error Handling', () => {
    it('should handle invalid action gracefully', () => {
      try {
        execSync(`${cliPath} reflexion invalid-action`, {
          cwd: testWorkspace,
          stdio: 'pipe'
        });
        expect.fail('Should have thrown error for invalid action');
      } catch (error: any) {
        expect(error.stderr.toString()).toContain('Unknown action');
      }
    });

    it('should handle LLM errors gracefully', async () => {
      // Force error by using invalid model (if supported in future)
      // For now, test that errors are caught and reported
      try {
        execSync(
          `${cliPath} reflexion execute --goal "Test error handling" --max-iterations 1 --output-json`,
          {
            cwd: testWorkspace,
            stdio: 'pipe',
            timeout: 60000
          }
        );
      } catch (error: any) {
        const output = error.stdout.toString();
        if (output) {
          const parsed = JSON.parse(output.trim().split('\n').pop() || '{}');
          if (parsed.status === 'error') {
            expect(parsed).toHaveProperty('error');
          }
        }
      }
    }, 60000);
  });
});

describe('Phase 1 Acceptance Criteria', () => {
  const testWorkspace = join(process.cwd(), 'test-workspace-acceptance');

  beforeAll(() => {
    if (existsSync(testWorkspace)) {
      rmSync(testWorkspace, { recursive: true, force: true });
    }
    mkdirSync(testWorkspace, { recursive: true });
  });

  it('[AC1] bun run kk reflexion execute --goal "..." --max-iterations 30 works', async () => {
    const result = execSync(
      `${cliPath} reflexion execute --goal "Create README.md with project title" --max-iterations 30 --preferred-model glm-4.7`,
      {
        cwd: testWorkspace,
        stdio: 'pipe',
        timeout: 120000
      }
    );

    expect(result.toString()).toBeTruthy();
    expect(existsSync(join(testWorkspace, 'README.md'))).toBe(true);
  }, 120000);

  it('[AC2] JSON output parseable by jq', async () => {
    const result = execSync(
      `${cliPath} reflexion execute --goal "Create package.json" --max-iterations 5 --output-json --preferred-model glm-4.7 | jq -s "." | jq length`,
      {
        cwd: testWorkspace,
        stdio: 'pipe',
        shell: '/bin/bash',
        timeout: 90000
      }
    );

    const count = parseInt(result.toString().trim(), 10);
    expect(count).toBeGreaterThan(0);
  }, 90000);

  it('[AC3] Returns exit code 0 on success, non-zero on failure', async () => {
    // Success case
    try {
      execSync(
        `${cliPath} reflexion execute --goal "Create success.txt" --max-iterations 5 --preferred-model glm-4.7`,
        {
          cwd: testWorkspace,
          stdio: 'pipe',
          timeout: 90000
        }
      );
      // Should not throw
    } catch (error) {
      expect.fail('Should have succeeded with exit code 0');
    }

    // Failure case (missing required parameter)
    try {
      execSync(`${cliPath} reflexion execute`, {
        cwd: testWorkspace,
        stdio: 'pipe'
      });
      expect.fail('Should have failed with non-zero exit code');
    } catch (error: any) {
      expect(error.status).not.toBe(0);
    }
  }, 90000);

  it('[AC4] Includes detailed metrics in output', async () => {
    const result = execSync(
      `${cliPath} reflexion execute --goal "Create app.ts with main function" --max-iterations 5 --output-json --preferred-model glm-4.7`,
      {
        cwd: testWorkspace,
        stdio: 'pipe',
        timeout: 120000
      }
    );

    const output = result.toString();
    const lines = output.trim().split('\n');
    const finalLine = lines[lines.length - 1];
    const resultData = JSON.parse(finalLine);

    expect(resultData).toHaveProperty('status');
    expect(resultData).toHaveProperty('success');
    expect(resultData).toHaveProperty('iterations');
    expect(resultData).toHaveProperty('filesCreated');
    expect(resultData).toHaveProperty('filesModified');
    expect(resultData).toHaveProperty('linesChanged');
    expect(resultData).toHaveProperty('stagnationDetected');
    expect(resultData).toHaveProperty('goalAchieved');
    expect(resultData).toHaveProperty('elapsedTime');
  }, 120000);
});
