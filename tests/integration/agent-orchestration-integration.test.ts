/**
 * Agent Orchestration Integration Tests
 *
 * Tests Phase 3 feature integration with multi-agent orchestration:
 * - AgentOrchestrationBridge functionality
 * - AutoCommand multi-agent routing
 * - SwarmOrchestrator Phase 3 capabilities
 * - TypeScript-Bash hook integration
 */

import { describe, test, expect } from 'bun:test';
import { AgentOrchestrationBridge } from '../../src/core/agents/AgentOrchestrationBridge';
import { SwarmOrchestrator, type Phase3Capabilities } from '../../src/core/agents/swarm';

describe('AgentOrchestrationBridge', () => {
  test('should initialize with default configuration', () => {
    const bridge = new AgentOrchestrationBridge();
    expect(bridge).toBeDefined();

    const orchestrators = bridge.getOrchestrators();
    expect(orchestrators.swarm).toBeDefined();
    expect(orchestrators.debug).toBeDefined();
    expect(orchestrators.quality).toBeDefined();
    expect(orchestrators.constitutional).toBeDefined();
    expect(orchestrators.boundedAutonomy).toBeDefined();
  });

  test('should initialize with vision enabled', () => {
    const bridge = new AgentOrchestrationBridge(10, { enableVision: true });
    const orchestrators = bridge.getOrchestrators();
    expect(orchestrators.vision).toBeDefined();
  });

  test('should analyze task complexity correctly', async () => {
    const bridge = new AgentOrchestrationBridge();

    // Simple task (use "quick" or "basic" for low complexity, avoid "fix" which triggers debugging)
    const simpleAnalysis = await bridge.analyzeTask('quick typo correction');
    expect(simpleAnalysis.complexity).toBe('low');
    expect(simpleAnalysis.taskType).toBe('general');

    // Complex task
    const complexAnalysis = await bridge.analyzeTask(
      'comprehensive security audit of entire authentication system'
    );
    expect(complexAnalysis.complexity).toBe('high');
    expect(complexAnalysis.taskType).toBe('security');
    expect(complexAnalysis.requiresSecurity).toBe(true);
  });

  test('should detect parallelizable tasks', async () => {
    const bridge = new AgentOrchestrationBridge();

    const analysis = await bridge.analyzeTask(
      'implement comprehensive testing suite for all modules'
    );

    expect(analysis.parallelizable).toBe(true);
    expect(analysis.complexity).toBe('high');
  });

  test('should suggest appropriate specialist agents', async () => {
    const bridge = new AgentOrchestrationBridge();

    // Testing task
    const testingAnalysis = await bridge.analyzeTask('validate all API endpoints');
    expect(testingAnalysis.suggestedAgents).toContain('test_engineer');

    // Security task
    const securityAnalysis = await bridge.analyzeTask('audit for SQL injection vulnerabilities');
    expect(securityAnalysis.suggestedAgents).toContain('security_auditor');

    // Documentation task
    const docsAnalysis = await bridge.analyzeTask('document the API endpoints');
    expect(docsAnalysis.suggestedAgents).toContain('documentation_writer');
  });

  test('should detect Phase 3 capability requirements', async () => {
    const bridge = new AgentOrchestrationBridge();

    // UI task requires vision
    const uiAnalysis = await bridge.analyzeTask('fix the UI layout on the homepage');
    expect(uiAnalysis.requiresVision).toBe(true);

    // Debug task requires debug orchestrator
    const debugAnalysis = await bridge.analyzeTask('fix bug in authentication');
    expect(debugAnalysis.requiresDebug).toBe(true);

    // Security task requires security validation
    const securityAnalysis = await bridge.analyzeTask('security audit');
    expect(securityAnalysis.requiresSecurity).toBe(true);

    // Quality task requires quality checks
    const qualityAnalysis = await bridge.analyzeTask('validate code quality');
    expect(qualityAnalysis.requiresQuality).toBe(true);
  });

  test('should route tasks to bash hook fallback gracefully', async () => {
    const bridge = new AgentOrchestrationBridge();

    // This will fail to call bash hook but should fallback to local routing
    const routing = await bridge.routeTask('implement new feature');

    expect(routing).toBeDefined();
    expect(routing.selectedAgent).toBeDefined();
    expect(routing.routingConfidence).toBeGreaterThan(0);
  });

  test('should provide Phase 3 enhancements for specialist agents', async () => {
    const bridge = new AgentOrchestrationBridge();

    // Debugger agent should get debug support
    const debugEnhancements = await bridge.enhanceAgentWithPhase3(
      'debugger',
      'fix authentication bug',
      'context'
    );
    expect(debugEnhancements.debugSupport).toBeDefined();

    // Test engineer should get quality checks
    const testEnhancements = await bridge.enhanceAgentWithPhase3(
      'test_engineer',
      'validate endpoints',
      'context'
    );
    expect(testEnhancements.qualityChecks).toBeDefined();

    // Security auditor should get safety validation
    const securityEnhancements = await bridge.enhanceAgentWithPhase3(
      'security_auditor',
      'audit code',
      'context'
    );
    expect(securityEnhancements.safetyValidation).toBeDefined();
  });
});

describe('SwarmOrchestrator Phase 3 Integration', () => {
  test('should initialize with Phase 3 capabilities', () => {
    const capabilities: Phase3Capabilities = {
      enableDebug: true,
      enableQuality: true,
      enableSafety: true,
      enableVision: true
    };

    const swarm = new SwarmOrchestrator(10, capabilities);
    expect(swarm).toBeDefined();
  });

  test('should initialize with default Phase 3 capabilities', () => {
    const swarm = new SwarmOrchestrator();
    expect(swarm).toBeDefined();
  });

  test('should spawn swarm with task decomposition', async () => {
    const swarm = new SwarmOrchestrator(5, {
      enableDebug: true,
      enableQuality: true
    });

    const result = await swarm.spawnSwarm(
      'implement authentication system',
      3,
      '/tmp/test-workspace',
      { github: true, chrome: false }
    );

    expect(result.swarmId).toMatch(/^swarm_\d+$/);
    expect(result.instructions).toBeDefined();
    expect(result.instructions.agentCount).toBe(3);
    expect(result.state).toBeDefined();
    expect(result.state.agentCount).toBe(3);
  });

  test('should track agent status', async () => {
    const swarm = new SwarmOrchestrator();

    const { swarmId } = await swarm.spawnSwarm(
      'test task',
      2,
      '/tmp/test',
      { github: false, chrome: false }
    );

    swarm.updateAgentStatus(swarmId, 1, 'running', 'task-1');
    swarm.updateAgentStatus(swarmId, 2, 'success', 'task-2');

    const status = swarm.getCompletionStatus(swarmId);
    expect(status.success).toBe(1);
    expect(status.pending).toBe(1);
  });

  test('should detect swarm completion', async () => {
    const swarm = new SwarmOrchestrator();

    const { swarmId } = await swarm.spawnSwarm(
      'test task',
      2,
      '/tmp/test',
      { github: false, chrome: false }
    );

    expect(swarm.isComplete(swarmId)).toBe(false);

    swarm.updateAgentStatus(swarmId, 1, 'success');
    swarm.updateAgentStatus(swarmId, 2, 'success');

    expect(swarm.isComplete(swarmId)).toBe(true);
  });
});

describe('Multi-Agent Task Analysis', () => {
  test('should identify tasks requiring multi-agent orchestration', async () => {
    const bridge = new AgentOrchestrationBridge();

    // Comprehensive tasks
    const comprehensive = await bridge.analyzeTask(
      'comprehensive security audit of all authentication endpoints'
    );
    expect(comprehensive.complexity).toBe('high');

    // Multiple components (testing is parallelizable only if complexity is high)
    const multiple = await bridge.analyzeTask(
      'comprehensive implementation of testing for all API endpoints across multiple services'
    );
    expect(multiple.parallelizable).toBe(true);
    expect(multiple.complexity).toBe('high');
  });

  test('should identify specialist task requirements', async () => {
    const bridge = new AgentOrchestrationBridge();

    // Security + Performance
    const secPerf = await bridge.analyzeTask(
      'security audit and performance optimization'
    );
    expect(secPerf.requiresSecurity).toBe(true);
    expect(secPerf.taskType).toBe('security');

    // Testing + Documentation
    const testDocs = await bridge.analyzeTask(
      'implement comprehensive testing and documentation'
    );
    expect(testDocs.requiresQuality).toBe(true);
  });
});

describe('Integration Health Checks', () => {
  test('should have all Phase 3 orchestrators accessible', () => {
    const bridge = new AgentOrchestrationBridge();
    const orchestrators = bridge.getOrchestrators();

    expect(orchestrators.swarm).toBeDefined();
    expect(orchestrators.debug).toBeDefined();
    expect(orchestrators.quality).toBeDefined();
    expect(orchestrators.constitutional).toBeDefined();
    expect(orchestrators.boundedAutonomy).toBeDefined();
  });

  test('should handle orchestration errors gracefully', async () => {
    const bridge = new AgentOrchestrationBridge();

    // Test with invalid workspace
    const result = await bridge.executeWithOrchestration(
      'test task',
      '/invalid/path',
      { useSwarm: false }
    );

    // Should handle gracefully, not throw
    expect(result).toBeDefined();
    expect(result.success !== undefined).toBe(true);
  });
});
