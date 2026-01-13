#!/bin/bash
# Reverse Engineering Prompt Generator - Generate RE prompts
# Creates optimized prompts for reverse engineering tasks

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${HOME}/.claude/logs/re-prompt.log"
OUTPUT_DIR="${HOME}/.claude/reverse-engineering"

mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$OUTPUT_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# ============================================================================
# Prompt Templates
# ============================================================================

generate_code_understanding_prompt() {
    local file_path="$1"
    local context="${2:-}"

    cat <<EOF
# Code Understanding Task

## Objective
Analyze and understand the code in: \`$file_path\`

## Context
$context

## Instructions
1. Read the file completely
2. Identify the main purpose and functionality
3. List all functions, classes, and their responsibilities
4. Identify dependencies and external modules used
5. Note any design patterns or architectural decisions
6. Highlight potential issues or areas for improvement

## Output Format
Provide your analysis in this structure:

### Purpose
[Brief description of what this code does]

### Structure
- **Functions**: [list with brief descriptions]
- **Classes**: [list with brief descriptions]
- **Dependencies**: [external modules/packages]

### Patterns & Architecture
[Design patterns used, architectural style]

### Observations
[Notable findings, potential issues, improvement opportunities]

### Key Insights
[3-5 bullet points of important takeaways]
EOF
}

generate_refactoring_prompt() {
    local file_path="$1"
    local focus="${2:-general}"

    cat <<EOF
# Refactoring Task

## Objective
Refactor the code in: \`$file_path\`

## Focus Area
$focus

## Refactoring Principles
1. **DRY** (Don't Repeat Yourself) - Eliminate duplication
2. **SOLID** - Single responsibility, Open/closed, Liskov substitution, Interface segregation, Dependency inversion
3. **KISS** (Keep It Simple, Stupid) - Simplify complex logic
4. **YAGNI** (You Aren't Gonna Need It) - Remove unnecessary code

## Instructions
1. Analyze the current code structure
2. Identify code smells and anti-patterns
3. Propose specific refactoring changes
4. Ensure backward compatibility where possible
5. Add tests for refactored code

## Output Format

### Current Issues
[Identified problems with line numbers]

### Proposed Changes
[Specific refactoring steps]

### Refactored Code
\`\`\`[language]
[Refactored implementation]
\`\`\`

### Benefits
- [Improvement 1]
- [Improvement 2]
- [Improvement 3]

### Testing Strategy
[How to verify the refactoring]
EOF
}

generate_debugging_prompt() {
    local file_path="$1"
    local error_description="$2"
    local context="${3:-}"

    cat <<EOF
# Debugging Task

## Objective
Debug and fix an issue in: \`$file_path\`

## Error Description
$error_description

## Context
$context

## Debugging Process
1. **Reproduce** - Understand how to trigger the issue
2. **Analyze** - Examine the code path causing the error
3. **Hypothesize** - Form potential root causes
4. **Test** - Verify each hypothesis
5. **Fix** - Apply the solution
6. **Verify** - Ensure the fix resolves the issue without side effects

## Questions to Answer
- What is the exact error message or behavior?
- Under what conditions does it occur?
- What code path is executed when it happens?
- What are the recent changes to this area?
- Are there similar working implementations to reference?

## Output Format

### Root Cause Analysis
[Explanation of why the issue occurs]

### Proposed Fix
\`\`\`[language]
[Fixed code with changes highlighted]
\`\`\`

### Verification Steps
[How to test the fix]

### Prevention
[How to prevent similar issues]
EOF
}

generate_documentation_prompt() {
    local file_path="$1"
    local doc_type="${2:-api}"

    case "$doc_type" in
        api)
            cat <<EOF
# API Documentation Task

## Objective
Generate API documentation for: \`$file_path\`

## Instructions
1. Identify all public functions and methods
2. Document parameters, return types, and behavior
3. Include usage examples
4. Note any edge cases or error conditions
5. Add authentication/authorization requirements if applicable

## Output Format

### API Overview
[Brief description of the API endpoints/functions]

### Endpoints/Functions

#### [Name]
- **Purpose**: [What it does]
- **Parameters**:
  - \`param1\` (type): [description]
  - \`param2\` (type): [description]
- **Returns**: [Type and description]
- **Throws**: [Error conditions]
- **Example**:
  \`\`\`[language]
  [Code example]
  \`\`\`

### Authentication
[If applicable]

### Error Handling
[Common errors and their meanings]
EOF
            ;;

        architecture)
            cat <<EOF
# Architecture Documentation Task

## Objective
Generate architecture documentation for: \`$file_path\`

## Instructions
1. Identify the architectural pattern used
2. Document the layers/components
3. Show data flow between components
4. Identify key design decisions
5. Note scalability and performance considerations

## Output Format

### Architecture Overview
[High-level description]

### Components
- **[Component Name]**: [Purpose and responsibilities]

### Data Flow
[How data moves through the system]

### Design Decisions
[Why certain patterns/technologies were chosen]

### Scalability & Performance
[Considerations and limitations]
EOF
            ;;

        code)
            cat <<EOF
# Code Documentation Task

## Objective
Generate inline documentation for: \`$file_path\`

## Instructions
1. Add JSDoc/Docstring comments to all functions
2. Document parameters and return values
3. Include usage examples in comments
4. Explain complex logic sections
5. Note any assumptions or invariants

## Output Format
Provide the fully documented code with:

### Function Documentation Template
\`\`\`[language]
/**
 * [Brief description]
 *
 * @param {[type]} [paramName] - [Description]
 * @returns {[type]} [Description of return value]
 * @throws {[type]} [Error conditions]
 * @example
 * // [Usage example]
 * [functionName](args);
 */
\`\`\`

### Inline Comments
- Explain "why" not just "what"
- Note non-obvious algorithms
- Document invariants and assumptions
- Reference related code or issues
EOF
            ;;

        *)
            echo "Unknown documentation type: $doc_type"
            return 1
            ;;
    esac
}

generate_migration_prompt() {
    local from_version="$1"
    local to_version="$2"
    local scope="${3:-full}"

    cat <<EOF
# Migration Task

## Objective
Migrate from \`$from_version\` to \`$to_version\`

## Scope
$scope

## Migration Checklist

### Pre-Migration
- [ ] Create backup of current state
- [ ] Review breaking changes in $to_version
- [ ] Identify deprecated features in use
- [ ] Update dependencies
- [ ] Run automated migration tools (if available)

### Migration Steps
1. [Update configuration files]
2. [Update import statements]
3. [Replace deprecated APIs]
4. [Update type definitions]
5. [Refactor affected code]
6. [Run tests]

### Post-Migration
- [ ] Run full test suite
- [ ] Verify all features work
- [ ] Check for performance regressions
- [ ] Update documentation
- [ ] Clean up old code

## Breaking Changes to Address
[List from changelog/release notes]

## Testing Strategy
[How to verify the migration]
EOF
}

generate_security_audit_prompt() {
    local file_path="$1"
    local scope="${2:-full}"

    cat <<EOF
# Security Audit Task

## Objective
Perform security audit of: \`$file_path\`

## Scope
$scope

## Security Categories

### Input Validation
- [ ] Validate all user inputs
- [ ] Sanitize data before processing
- [ ] Check for injection vulnerabilities

### Authentication & Authorization
- [ ] Verify authentication mechanisms
- [ ] Check authorization checks
- [ ] Review session management

### Data Protection
- [ ] Identify sensitive data handling
- [ ] Check encryption usage
- [ ] Verify secure storage

### Output Encoding
- [ ] Escape user-generated content
- [ ] Prevent XSS vulnerabilities
- [ ] Implement CSP headers

### Dependencies
- [ ] Check for vulnerable dependencies
- [ ] Review third-party libraries
- [ ] Update to secure versions

## Output Format

### Findings
| Severity | Issue | Location | Recommendation |
|----------|--------|----------|----------------|
| [Critical/High/Medium/Low] | [Description] | [File:line] | [Fix suggestion] |

### Summary
- **Critical**: [count]
- **High**: [count]
- **Medium**: [count]
- **Low**: [count]

### Remediation Plan
[Prioritized list of fixes]
EOF
}

# ============================================================================
# Main Generator
# ============================================================================

generate() {
    local prompt_type="$1"
    shift
    local args=("$@")

    log "Generating $prompt_type prompt with args: ${args[*]}"

    local prompt=""
    local output_file="${OUTPUT_DIR}/prompt-${prompt_type}-$(date +%s).md"

    case "$prompt_type" in
        understand|code-understanding)
            prompt=$(generate_code_understanding_prompt "${args[0]:-}" "${args[1]:-}")
            ;;

        refactor)
            prompt=$(generate_refactoring_prompt "${args[0]:-}" "${args[1]:-general}")
            ;;

        debug)
            prompt=$(generate_debugging_prompt "${args[0]:-}" "${args[1]:-}" "${args[2]:-}")
            ;;

        docs|documentation)
            prompt=$(generate_documentation_prompt "${args[0]:-}" "${args[1]:-api}")
            ;;

        migrate|migration)
            prompt=$(generate_migration_prompt "${args[0]:-}" "${args[1]:-}" "${args[2]:-full}")
            ;;

        security|security-audit)
            prompt=$(generate_security_audit_prompt "${args[0]:-}" "${args[1]:-full}")
            ;;

        *)
            echo "Unknown prompt type: $prompt_type"
            echo "Available: understand, refactor, debug, docs, migrate, security"
            return 1
            ;;
    esac

    # Save prompt to file
    echo "$prompt" > "$output_file"
    log "Prompt saved to: $output_file"

    # Output to stdout
    echo "$prompt"
    echo ""
    echo "---"
    echo "Prompt saved to: $output_file"
}

# ============================================================================
# CLI Interface
# ============================================================================

case "${1:-help}" in
    understand)
        generate "understand" "${2:-}" "${3:-}"
        ;;

    refactor)
        generate "refactor" "$2" "$3"
        ;;

    debug)
        generate "debug" "$2" "$3" "$4"
        ;;

    docs)
        generate "docs" "$2" "$3"
        ;;

    migrate)
        generate "migrate" "$2" "$3" "$4"
        ;;

    security)
        generate "security" "$2" "$3"
        ;;

    help|*)
        cat <<EOF
Reverse Engineering Prompt Generator - Generate RE prompts

Usage: $0 <type> [args...]

Prompt Types:
  understand <file> [context]      - Code understanding prompt
  refactor <file> [focus]         - Refactoring prompt
  debug <file> <error> [context]  - Debugging prompt
  docs <file> <type>             - Documentation prompt
  migrate <from> <to> [scope]     - Migration prompt
  security <file> [scope]          - Security audit prompt

Documentation Types:
  api          - API documentation
  architecture  - Architecture documentation
  code         - Inline code documentation

Examples:
  $0 understand ./src/auth.ts
  $0 refactor ./src/utils.ts performance
  $0 debug ./src/api.ts "Cannot read property 'id'" "After login"
  $0 docs ./src/api.ts api
  $0 migrate v1 v2 full
  $0 security ./src/auth.ts full

Output:
  - Prompt printed to stdout
  - Saved to: ~/.claude/reverse-engineering/prompt-*.md
EOF
        ;;
esac
