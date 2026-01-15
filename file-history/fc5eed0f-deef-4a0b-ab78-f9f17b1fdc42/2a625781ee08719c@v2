/**
 * SPARC Methodology Implementation
 * Source: Roo Code's structured workflow
 *
 * SPARC: Specification → Pseudocode → Architecture → Refinement → Completion
 */

import type { LLMRouter } from '../../llm/Router';

export interface SPARCContext {
  task: string;
  requirements: string[];
  constraints: string[];
}

export interface SPARCResult {
  phase: SPARCPhase;
  output: any;
  nextPhase?: SPARCPhase;
}

export enum SPARCPhase {
  Specification = 'specification',
  Pseudocode = 'pseudocode',
  Architecture = 'architecture',
  Refinement = 'refinement',
  Completion = 'completion'
}

export class SPARCWorkflow {
  private currentPhase: SPARCPhase = SPARCPhase.Specification;
  private context: SPARCContext;
  private router: LLMRouter;

  constructor(context: SPARCContext, router: LLMRouter) {
    this.context = context;
    this.router = router;
  }

  /**
   * Extract text from LLM response
   */
  private extractText(content: any[]): string {
    const textBlock = content.find((block: any) => block.type === 'text');
    return textBlock?.text || '';
  }

  /**
   * Execute the complete SPARC workflow
   */
  async execute(): Promise<SPARCResult> {
    console.log(`Starting SPARC workflow for: ${this.context.task}`);

    // Phase 1: Specification
    const spec = await this.generateSpecification();

    // Phase 2: Pseudocode
    const pseudocode = await this.generatePseudocode(spec);

    // Phase 3: Architecture
    const architecture = await this.designArchitecture(pseudocode);

    // Phase 4: Refinement
    const refined = await this.refine(architecture);

    // Phase 5: Completion
    const completed = await this.complete(refined);

    return {
      phase: SPARCPhase.Completion,
      output: completed
    };
  }

  private async generateSpecification(): Promise<any> {
    const prompt = `Generate a detailed specification for the following task:

**Task**: ${this.context.task}

**Requirements**:
${this.context.requirements.map((r, i) => `${i + 1}. ${r}`).join('\n')}

**Constraints**:
${this.context.constraints.map((c, i) => `${i + 1}. ${c}`).join('\n')}

Provide a comprehensive specification that includes:
1. Clear problem statement
2. Functional requirements (what the system must do)
3. Non-functional requirements (performance, security, etc.)
4. Edge cases and error handling considerations
5. Success criteria

Format your response as JSON with the structure:
{
  "problemStatement": "...",
  "functionalRequirements": ["..."],
  "nonFunctionalRequirements": ["..."],
  "edgeCases": ["..."],
  "successCriteria": ["..."]
}`;

    const response = await this.router.route(
      {
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.7,
        max_tokens: 2000
      },
      {
        taskType: 'coding',
        priority: 'balanced'
      }
    );

    const text = this.extractText(response.content);

    try {
      // Try to parse JSON response
      const jsonMatch = text.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        return JSON.parse(jsonMatch[0]);
      }
    } catch (error) {
      // Fallback if JSON parsing fails
    }

    return {
      raw: text,
      requirements: this.context.requirements,
      constraints: this.context.constraints
    };
  }

  private async generatePseudocode(spec: any): Promise<any> {
    const specSummary = spec.problemStatement || JSON.stringify(spec);
    const prompt = `Based on the following specification, generate detailed pseudocode:

**Specification**:
${specSummary}

**Functional Requirements**:
${spec.functionalRequirements?.map((r: string, i: number) => `${i + 1}. ${r}`).join('\n') || 'See spec above'}

Generate step-by-step pseudocode that:
1. Breaks down the problem into clear, logical steps
2. Includes data structures and algorithms needed
3. Handles edge cases mentioned in the spec
4. Shows control flow (loops, conditionals, etc.)
5. Is language-agnostic but clear

Format your response as JSON:
{
  "steps": [
    { "step": 1, "action": "...", "details": "..." }
  ],
  "dataStructures": ["..."],
  "algorithms": ["..."]
}`;

    const response = await this.router.route(
      {
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.6,
        max_tokens: 2000
      },
      {
        taskType: 'coding',
        priority: 'balanced'
      }
    );

    const text = this.extractText(response.content);

    try {
      const jsonMatch = text.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        return JSON.parse(jsonMatch[0]);
      }
    } catch (error) {
      // Fallback
    }

    return {
      raw: text,
      steps: [],
      plan: 'step-by-step'
    };
  }

  private async designArchitecture(pseudocode: any): Promise<any> {
    const pseudocodeSummary = pseudocode.steps?.map((s: any) => `Step ${s.step}: ${s.action}`).join('\n') || JSON.stringify(pseudocode);
    const prompt = `Based on the following pseudocode, design a software architecture:

**Pseudocode**:
${pseudocodeSummary}

**Data Structures**:
${pseudocode.dataStructures?.join(', ') || 'See pseudocode'}

Design an architecture that:
1. Identifies key components/modules
2. Defines component responsibilities
3. Shows component interactions and data flow
4. Considers separation of concerns
5. Is maintainable and testable

Format your response as JSON:
{
  "components": [
    { "name": "...", "responsibility": "...", "interfaces": ["..."] }
  ],
  "dataFlow": ["..."],
  "patterns": ["..."]
}`;

    const response = await this.router.route(
      {
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.5,
        max_tokens: 2000
      },
      {
        taskType: 'coding',
        priority: 'balanced'
      }
    );

    const text = this.extractText(response.content);

    try {
      const jsonMatch = text.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        return JSON.parse(jsonMatch[0]);
      }
    } catch (error) {
      // Fallback
    }

    return {
      raw: text,
      components: [],
      interactions: [],
      design: 'modular'
    };
  }

  private async refine(architecture: any): Promise<any> {
    const architectureSummary = architecture.components?.map((c: any) => `${c.name}: ${c.responsibility}`).join('\n') || JSON.stringify(architecture);
    const prompt = `Review and refine the following architecture:

**Architecture**:
${architectureSummary}

**Patterns Used**:
${architecture.patterns?.join(', ') || 'None specified'}

Refine the architecture by:
1. Identifying potential bottlenecks or weaknesses
2. Suggesting optimizations for performance/scalability
3. Adding error handling strategies
4. Improving modularity where needed
5. Considering security implications

Format your response as JSON:
{
  "refinements": [
    { "area": "...", "issue": "...", "improvement": "..." }
  ],
  "optimizations": ["..."],
  "securityConsiderations": ["..."],
  "finalArchitecture": { ... }
}`;

    const response = await this.router.route(
      {
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.4,
        max_tokens: 2000
      },
      {
        taskType: 'coding',
        priority: 'balanced'
      }
    );

    const text = this.extractText(response.content);

    try {
      const jsonMatch = text.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        return JSON.parse(jsonMatch[0]);
      }
    } catch (error) {
      // Fallback
    }

    return {
      raw: text,
      ...architecture,
      refined: true
    };
  }

  private async complete(refined: any): Promise<any> {
    const refinementsSummary = refined.refinements?.map((r: any) => `${r.area}: ${r.improvement}`).join('\n') || 'No refinements';
    const prompt = `Generate a completion summary and implementation guide:

**Task**: ${this.context.task}

**Refinements Applied**:
${refinementsSummary}

**Optimizations**:
${refined.optimizations?.join(', ') || 'None'}

Create a completion summary that includes:
1. Overview of the complete solution
2. Implementation steps in priority order
3. Testing strategy
4. Deployment considerations
5. Success metrics

Format your response as JSON:
{
  "summary": "...",
  "implementationSteps": [
    { "priority": 1, "step": "...", "estimatedEffort": "..." }
  ],
  "testingStrategy": ["..."],
  "deploymentConsiderations": ["..."],
  "successMetrics": ["..."]
}`;

    const response = await this.router.route(
      {
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.3,
        max_tokens: 2000
      },
      {
        taskType: 'general',
        priority: 'balanced'
      }
    );

    const text = this.extractText(response.content);

    try {
      const jsonMatch = text.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        const completion = JSON.parse(jsonMatch[0]);
        return {
          ...refined,
          ...completion,
          completed: true
        };
      }
    } catch (error) {
      // Fallback
    }

    return {
      raw: text,
      ...refined,
      completed: true
    };
  }
}
