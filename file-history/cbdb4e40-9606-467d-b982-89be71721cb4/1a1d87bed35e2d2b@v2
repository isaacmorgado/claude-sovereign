/**
 * Test ActionExecutor file existence check
 */

import { ActionExecutor } from '../src/core/agents/ActionExecutor';
import { LLMRouter } from '../src/core/llm/Router';
import { AnthropicProvider } from '../src/core/llm/providers/AnthropicProvider';
import * as fs from 'fs/promises';
import * as path from 'path';

async function testFileExistenceCheck() {
  console.log('🧪 Testing ActionExecutor file existence check...\n');

  // Setup
  const apiKey = process.env.ANTHROPIC_API_KEY || 'test-key';
  const provider = new AnthropicProvider(apiKey);
  const router = new LLMRouter([provider]);
  const testDir = path.join(process.cwd(), 'test-output');
  const executor = new ActionExecutor(router, testDir);

  // Create test directory
  await fs.mkdir(testDir, { recursive: true });

  try {
    // Test 1: Create new file
    console.log('Test 1: Creating new file...');
    const result1 = await executor.execute({
      type: 'file_write',
      params: {
        path: 'new-file.ts',
        content: '// New file\nconsole.log("Hello");'
      }
    });

    console.log('✓ Result:', result1.output);
    console.log('  Metadata:', JSON.stringify(result1.metadata, null, 2));

    if (!result1.metadata?.existed) {
      console.log('✅ Test 1 PASSED: File marked as new\n');
    } else {
      console.log('❌ Test 1 FAILED: File should be marked as new\n');
    }

    // Test 2: Update existing file
    console.log('Test 2: Updating existing file...');
    const result2 = await executor.execute({
      type: 'file_write',
      params: {
        path: 'new-file.ts',
        content: '// Updated file\nconsole.log("Hello, World!");'
      }
    });

    console.log('✓ Result:', result2.output);
    console.log('  Metadata:', JSON.stringify(result2.metadata, null, 2));

    if (result2.metadata?.existed) {
      console.log('✅ Test 2 PASSED: File marked as existing\n');
    } else {
      console.log('❌ Test 2 FAILED: File should be marked as existing\n');
    }

    // Test 3: Verify previous file size tracked
    if (result2.metadata?.previousBytes === 33) {
      console.log('✅ Test 3 PASSED: Previous file size tracked correctly\n');
    } else {
      console.log('❌ Test 3 FAILED: Previous file size incorrect:', result2.metadata?.previousBytes, '\n');
    }

    console.log('🎉 All tests completed!');

  } catch (error) {
    console.error('❌ Test failed with error:', error);
  } finally {
    // Cleanup
    await fs.rm(testDir, { recursive: true, force: true });
  }
}

// Run test
testFileExistenceCheck().catch(console.error);
