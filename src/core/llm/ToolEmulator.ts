/**
 * Tool Emulator - XML-based Tool Calling for Abliterated Models
 *
 * Provides tool calling capabilities for models without native support
 * Based on clauded project's tool emulation patterns
 */

import type { Tool, ContentBlock, ToolUseContent } from './types';

export interface ToolCallMatch {
  fullMatch: string;
  toolName: string;
  parameters: Record<string, any>;
  startIndex: number;
  endIndex: number;
}

/**
 * Tool Emulator for models without native tool support
 */
export class ToolEmulator {
  /**
   * Check if a model likely supports native tool calling
   * Based on model name patterns
   */
  static supportsNativeTools(modelName: string): boolean {
    const nativeSupport = [
      'claude',      // All Claude models
      'gpt-4',       // GPT-4 models
      'gpt-3.5',     // GPT-3.5 models
      'gemini'       // Gemini models
    ];

    return nativeSupport.some(pattern => modelName.toLowerCase().includes(pattern));
  }

  /**
   * Convert tools to XML format for system prompt injection
   */
  static injectToolsToPrompt(systemPrompt: string, tools: Tool[]): string {
    if (tools.length === 0) {
      return systemPrompt;
    }

    const toolsXML = this.generateToolsXML(tools);

    return `${systemPrompt}

# Available Tools

You have access to the following tools. To use a tool, output XML in this format:

<tool_call>
<name>tool_name</name>
<parameters>
  <param_name>value</param_name>
  <!-- Add more parameters as needed -->
</parameters>
</tool_call>

${toolsXML}

IMPORTANT: When you want to use a tool, output the XML exactly as shown above. Do not use any other format.
`;
  }

  /**
   * Generate XML documentation for tools
   */
  private static generateToolsXML(tools: Tool[]): string {
    return tools.map(tool => {
      const params = tool.input_schema.properties;
      const required = tool.input_schema.required || [];

      const paramDocs = Object.entries(params).map(([name, schema]: [string, any]) => {
        const isRequired = required.includes(name);
        const type = schema.type || 'string';
        const description = schema.description || '';
        return `  - ${name} (${type}${isRequired ? ', required' : ', optional'}): ${description}`;
      }).join('\n');

      return `
## ${tool.name}

${tool.description}

Parameters:
${paramDocs}

Example usage:
<tool_call>
<name>${tool.name}</name>
<parameters>
${Object.keys(params).slice(0, 2).map(name => `  <${name}>example_value</${name}>`).join('\n')}
</parameters>
</tool_call>
`.trim();
    }).join('\n\n');
  }

  /**
   * Extract tool calls from model output (XML format)
   */
  static extractToolCalls(text: string): ToolCallMatch[] {
    const matches: ToolCallMatch[] = [];

    // Match <tool_call>...</tool_call> blocks
    const toolCallRegex = /<tool_call>([\s\S]*?)<\/tool_call>/g;
    let match;

    while ((match = toolCallRegex.exec(text)) !== null) {
      const fullMatch = match[0];
      const content = match[1];
      const startIndex = match.index;
      const endIndex = match.index + fullMatch.length;

      // Extract tool name
      const nameMatch = content.match(/<name>(.*?)<\/name>/);
      const toolName = nameMatch ? nameMatch[1].trim() : '';

      if (!toolName) {
        continue;  // Skip if no tool name found
      }

      // Extract parameters
      const parametersMatch = content.match(/<parameters>([\s\S]*?)<\/parameters>/);
      const parametersXML = parametersMatch ? parametersMatch[1] : '';

      const parameters = this.parseParameters(parametersXML);

      matches.push({
        fullMatch,
        toolName,
        parameters,
        startIndex,
        endIndex
      });
    }

    return matches;
  }

  /**
   * Parse XML parameters into object
   */
  private static parseParameters(xml: string): Record<string, any> {
    const params: Record<string, any> = {};

    // Match <param_name>value</param_name> patterns
    const paramRegex = /<(\w+)>([\s\S]*?)<\/\1>/g;
    let match;

    while ((match = paramRegex.exec(xml)) !== null) {
      const paramName = match[1];
      const paramValue = match[2].trim();

      // Try to parse as JSON if it looks like a complex value
      if (paramValue.startsWith('{') || paramValue.startsWith('[')) {
        try {
          params[paramName] = JSON.parse(paramValue);
        } catch {
          params[paramName] = paramValue;
        }
      } else if (paramValue === 'true') {
        params[paramName] = true;
      } else if (paramValue === 'false') {
        params[paramName] = false;
      } else if (!isNaN(Number(paramValue)) && paramValue !== '') {
        params[paramName] = Number(paramValue);
      } else {
        params[paramName] = paramValue;
      }
    }

    return params;
  }

  /**
   * Convert XML tool calls to standard ContentBlock format
   */
  static convertToContentBlocks(
    text: string,
    toolCalls: ToolCallMatch[]
  ): ContentBlock[] {
    if (toolCalls.length === 0) {
      // No tool calls - just return text
      return [{ type: 'text', text }];
    }

    const blocks: ContentBlock[] = [];
    let lastIndex = 0;

    for (const toolCall of toolCalls) {
      // Add text before tool call
      if (toolCall.startIndex > lastIndex) {
        const textBefore = text.substring(lastIndex, toolCall.startIndex).trim();
        if (textBefore) {
          blocks.push({ type: 'text', text: textBefore });
        }
      }

      // Add tool use block
      const toolUse: ToolUseContent = {
        type: 'tool_use',
        id: `toolu_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        name: toolCall.toolName,
        input: toolCall.parameters
      };
      blocks.push(toolUse);

      lastIndex = toolCall.endIndex;
    }

    // Add remaining text after last tool call
    if (lastIndex < text.length) {
      const textAfter = text.substring(lastIndex).trim();
      if (textAfter) {
        blocks.push({ type: 'text', text: textAfter });
      }
    }

    return blocks;
  }

  /**
   * Process model output: detect tool calls and convert to standard format
   */
  static processOutput(text: string): {
    hasToolCalls: boolean;
    toolCalls: ToolCallMatch[];
    contentBlocks: ContentBlock[];
  } {
    const toolCalls = this.extractToolCalls(text);
    const hasToolCalls = toolCalls.length > 0;
    const contentBlocks = this.convertToContentBlocks(text, toolCalls);

    return {
      hasToolCalls,
      toolCalls,
      contentBlocks
    };
  }

  /**
   * Create system prompt modification for better tool usage
   */
  static enhanceSystemPrompt(systemPrompt: string): string {
    return `${systemPrompt}

When you need to use tools:
1. Think about which tool is most appropriate
2. Output the tool call in XML format exactly as specified
3. Wait for the tool result before proceeding
4. Use the tool result to continue your task

You can use multiple tools in sequence if needed.
`;
  }
}
