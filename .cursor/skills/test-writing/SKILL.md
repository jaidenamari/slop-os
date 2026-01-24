---
name: Test Writing
description: Generate comprehensive test suites for code modules. Supports multiple test frameworks through cookbooks (Jest, Vitest, Playwright, etc.).
---

# Test Writing

Generate comprehensive, well-structured test suites that follow testing best practices.

## Purpose

This skill provides a standardized workflow for writing tests that adapts to whatever test framework the project uses. It handles:

- Unit tests for functions and classes
- Integration tests for module interactions
- Component tests for UI elements
- E2E tests for user flows
- Test organization and structure

## Instructions

### Step 1: Detect Test Framework

First, identify which test framework the project uses:

```
SCAN for indicators:
- package.json dependencies (jest, vitest, @playwright/test, mocha, etc.)
- Config files (jest.config.*, vitest.config.*, playwright.config.*)
- Test directories (__tests__/, tests/, test/, *.test.ts, *.spec.ts)
- Scripts in package.json (test, test:unit, test:e2e)
```

### Step 2: Load Cookbook

Based on detection, load the appropriate cookbook:

| Framework | Cookbook |
|-----------|----------|
| Jest | `cookbook/jest.md` |
| Vitest | `cookbook/vitest.md` |
| Playwright | `cookbook/playwright.md` |
| Mocha | `cookbook/mocha.md` |

```
READ cookbook/{detected-framework}.md
FOLLOW framework-specific patterns and conventions
```

### Step 3: Analyze Target Code

Before writing tests:

1. **Read the target module** - Understand the API surface
2. **Identify dependencies** - What needs mocking?
3. **Map test scenarios** - Happy paths, edge cases, errors
4. **Check existing tests** - Don't duplicate coverage

```
FOR each function/class in target:
  IDENTIFY:
  - Input parameters and types
  - Expected outputs
  - Side effects
  - Error conditions
  - Edge cases
```

### Step 4: Generate Tests

Follow this structure for each test file:

```
1. Imports (testing utilities, target module, mocks)
2. Mock setup (if needed)
3. Describe blocks (group by function/feature)
4. Individual test cases (arrange-act-assert)
5. Cleanup/teardown
```

### Step 5: Verify Tests

After writing:

1. **Run the tests** - Ensure they pass
2. **Check coverage** - Identify gaps
3. **Review quality** - Are assertions meaningful?

## Test Categories

### Unit Tests
- Test individual functions in isolation
- Mock all external dependencies
- Fast execution, no I/O

### Integration Tests
- Test module interactions
- May use real dependencies (DB, services)
- Test data flow between components

### Component Tests (UI)
- Test UI components in isolation
- Mock API calls and context
- Test user interactions

### E2E Tests
- Test complete user flows
- Real browser/app environment
- Slower but high confidence

## Test Quality Guidelines

### Good Test Characteristics
- **Descriptive names**: "should return empty array when no items match filter"
- **Single responsibility**: One assertion concept per test
- **Isolated**: No shared state between tests
- **Deterministic**: Same result every run
- **Fast**: Quick feedback loop

### What to Test
- Happy paths (normal operation)
- Edge cases (empty inputs, boundaries)
- Error handling (invalid inputs, failures)
- State transitions (before/after effects)

### What NOT to Test
- Implementation details (private methods)
- Framework code (React, Express internals)
- Third-party libraries (trust their tests)
- Trivial code (simple getters/setters)

## Mocking Strategy

```
MOCK when:
- External services (APIs, databases)
- Time-dependent code
- Random values
- File system operations
- Environment variables

DON'T MOCK when:
- Testing integration between modules
- Pure functions with no side effects
- Testing the mock would be pointless
```

## Examples

### Example 1: Unit Test for Service

```
User: "Write tests for UserService.createUser"

1. Detect: Jest (found jest.config.ts)
2. Load: cookbook/jest.md
3. Analyze: createUser takes userData, calls repo, sends email
4. Generate tests:
   - Should create user with valid data
   - Should hash password before saving
   - Should send welcome email
   - Should throw if email exists
   - Should validate required fields
5. Run: npm test UserService.test.ts
```

### Example 2: Component Test

```
User: "Test the UserCard component"

1. Detect: Vitest + Testing Library
2. Load: cookbook/vitest.md
3. Analyze: UserCard receives user prop, renders name/avatar
4. Generate tests:
   - Should render user name
   - Should display avatar image
   - Should show loading state
   - Should handle missing avatar
   - Should call onClick when clicked
5. Run: npm test UserCard.test.tsx
```

### Example 3: E2E Test

```
User: "E2E test for login flow"

1. Detect: Playwright
2. Load: cookbook/playwright.md
3. Analyze: Login page → credentials → dashboard
4. Generate tests:
   - Should login with valid credentials
   - Should show error for invalid password
   - Should redirect to dashboard on success
   - Should persist session
5. Run: npx playwright test login.spec.ts
```

## Test File Location

Follow project conventions or use defaults:

| Pattern | Location |
|---------|----------|
| Co-located | `src/services/UserService.test.ts` |
| Separate | `tests/unit/services/UserService.test.ts` |
| __tests__ | `src/services/__tests__/UserService.test.ts` |

## Output

After generating tests:

```markdown
## Tests Generated

**File**: `tests/unit/UserService.test.ts`
**Framework**: Jest
**Coverage**: 
- Functions: 5/5
- Branches: 12/15
- Lines: 45/52

### Test Cases
- ✓ createUser - should create user with valid data
- ✓ createUser - should hash password
- ✓ createUser - should throw if email exists
- ✓ updateUser - should update allowed fields
- ✓ deleteUser - should soft delete by default

### Run Command
```bash
npm test -- UserService.test.ts
```
```
