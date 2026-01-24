# Quality Review Prompts

Structured prompts for code quality analysis.

---

## Prompt 1: Complexity Analysis

```
Analyze this code for complexity issues.

CODE:
{file_content}

METRICS TO CALCULATE:
1. Lines of Code (LOC) per function
   - Warning: >30 lines
   - Error: >50 lines

2. Cyclomatic Complexity
   - Count: if, else, for, while, case, catch, &&, ||, ?:
   - Warning: >7
   - Error: >10

3. Nesting Depth
   - Count max nesting level
   - Warning: >3 levels
   - Error: >4 levels

4. Parameter Count
   - Warning: >4 parameters
   - Error: >6 parameters

OUTPUT FORMAT:
FUNCTION: {name}
LOC: {count} [{OK|WARNING|ERROR}]
COMPLEXITY: {count} [{OK|WARNING|ERROR}]
NESTING: {count} [{OK|WARNING|ERROR}]
PARAMS: {count} [{OK|WARNING|ERROR}]
SUGGESTION: {refactoring advice if needed}
```

---

## Prompt 2: Code Smell Detection

```
Identify code smells in this code.

CODE:
{file_content}

SMELL CATEGORIES:

1. **Bloaters**
   - Long Method: >50 lines
   - Large Class: >300 lines or >10 public methods
   - Long Parameter List: >4 params
   - Data Clumps: Same group of variables passed together

2. **Object-Orientation Abusers**
   - Switch Statements: Multiple switches on same condition
   - Refused Bequest: Subclass doesn't use parent methods
   - Alternative Classes: Different classes, same interface

3. **Change Preventers**
   - Divergent Change: One class changed for multiple reasons
   - Shotgun Surgery: One change requires many class modifications
   - Parallel Inheritance: Create subclass A, must create subclass B

4. **Dispensables**
   - Dead Code: Unreachable or unused code
   - Speculative Generality: Unused abstractions
   - Duplicate Code: Same structure in multiple places
   - Comments: Excessive comments hiding bad code

5. **Couplers**
   - Feature Envy: Method uses other class more than its own
   - Inappropriate Intimacy: Classes too intertwined
   - Message Chains: a.getB().getC().getD()
   - Middle Man: Class only delegates

For each smell:
SMELL: {name}
LOCATION: {file:line}
SEVERITY: {High|Medium|Low}
REFACTORING: {suggested technique}
```

---

## Prompt 3: Naming & Readability

```
Review naming conventions and readability.

CODE:
{file_content}

PROJECT CONVENTIONS:
- Variables: camelCase
- Constants: UPPER_SNAKE_CASE
- Classes: PascalCase
- Files: kebab-case or PascalCase (components)
- Boolean: is/has/can/should prefix

READABILITY CHECKS:
1. Are names descriptive? (no single letters except loops)
2. Are names consistent with domain language?
3. Are abbreviations avoided or well-known?
4. Do functions describe their action? (verb + noun)
5. Are magic numbers replaced with named constants?

FLAG:
- Names <3 characters (except i, j, k in loops)
- Inconsistent naming patterns
- Misleading names
- Generic names (data, info, temp, stuff)
```

---

## Prompt 4: Error Handling

```
Analyze error handling patterns.

CODE:
{file_content}

CHECKLIST:
1. Are errors caught at appropriate boundaries?
2. Are errors logged with context?
3. Are errors transformed appropriately for API responses?
4. Is the Result<T,E> pattern used where applicable?
5. Are async errors handled (Promise rejections, try/catch)?

ANTI-PATTERNS:
- Empty catch blocks
- Catching and ignoring errors
- Generic error messages to users
- Logging sensitive data in errors
- Not re-throwing when appropriate
- Swallowing Promise rejections

For each issue:
LOCATION: {file:line}
ISSUE: {description}
CURRENT: {code snippet}
SUGGESTED: {better approach}
```

---

## Prompt 5: Test Quality

```
Evaluate test quality for this code.

TEST CODE:
{test_content}

SOURCE CODE:
{source_content}

QUALITY METRICS:
1. Coverage: Are all public methods tested?
2. Edge Cases: Are boundary conditions tested?
3. Error Cases: Are error paths tested?
4. Assertions: Are assertions specific and meaningful?
5. Isolation: Are tests independent?
6. Naming: Do test names describe behavior?

ANTI-PATTERNS:
- Tests without assertions
- Multiple unrelated assertions
- Testing implementation details
- Flaky tests (random failures)
- Slow tests without reason
- Commented out tests

COVERAGE GAPS:
{List untested functions/branches}

QUALITY ISSUES:
{List specific problems}
```

---

## Prompt 6: Architecture Compliance

```
Check code against architectural guidelines.

CODE:
{file_content}

PROJECT PATTERNS:
1. Repository Pattern for data access
2. Result<T,E> for error handling
3. Zod schemas for input validation
4. Standardized API response format
5. Dependency injection where appropriate

FILE LOCATION RULES:
- components/ → React components only
- hooks/ → Custom React hooks
- utils/ → Pure utility functions
- services/ → Business logic
- repositories/ → Data access
- types/ → TypeScript types/interfaces

IMPORT RULES:
- Use path aliases (@/...)
- No circular dependencies
- No reaching into internal modules

VIOLATIONS:
{List of architectural violations with suggestions}
```

---

## Prompt 7: Performance Considerations

```
Review code for performance issues.

CODE:
{file_content}

CHECK FOR:
1. N+1 query patterns
2. Missing pagination
3. Large data in memory
4. Expensive operations in loops
5. Missing caching opportunities
6. Unnecessary re-renders (React)
7. Blocking operations on main thread

REACT-SPECIFIC:
- Missing useMemo/useCallback
- Inline object/function in JSX
- Missing key prop in lists
- State updates causing cascades

DATABASE-SPECIFIC:
- Missing indexes on queried fields
- SELECT * when subset needed
- Unoptimized JOINs

FLAG FORMAT:
ISSUE: {description}
IMPACT: {High|Medium|Low}
LOCATION: {file:line}
SUGGESTION: {optimization}
```

---

## Composite Quality Report Template

```markdown
# Code Quality Analysis Report

## Quality Score: {score}/100

### Breakdown
- Complexity: {score}/25
- Readability: {score}/25
- Error Handling: {score}/25
- Test Quality: {score}/25

## Summary
- **Functions Analyzed**: {count}
- **Issues Found**: {count}
- **Refactoring Opportunities**: {count}

## High Priority Issues
{issues requiring immediate attention}

## Code Smells
{categorized list of smells}

## Refactoring Suggestions
{prioritized refactoring recommendations}

## Test Coverage Gaps
{untested code paths}

## Positive Observations
{well-written code to highlight}
```
