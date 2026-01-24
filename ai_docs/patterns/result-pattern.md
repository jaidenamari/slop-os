# Result Pattern

Error handling using the Result<T, E> pattern instead of throwing exceptions.

## When to Apply

- File patterns: `*Service.ts`, `*Repository.ts`, `*.service.ts`
- Functions that can fail in expected ways
- Operations involving external systems (DB, API, file system)

## Required Elements

1. **Result Type** - Function returns `Result<SuccessType, ErrorType>`
2. **Explicit Errors** - Error cases are typed and documented
3. **No Thrown Exceptions** - For expected failures (validation, not found, etc.)
4. **Caller Handles Both Cases** - Must check success before accessing data

## Anti-Patterns (Flag These)

- Throwing exceptions for expected failures (validation, not found)
- Using try/catch for control flow
- Returning `null` or `undefined` for errors
- Untyped error returns
- Swallowing errors silently

## Result Type Definition

```typescript
// Basic Result type
type Result<T, E> = 
  | { success: true; data: T }
  | { success: false; error: E };

// Or with a library like neverthrow
import { Result, ok, err } from 'neverthrow';
```

## Example

```typescript
// Define error types
type UserError = 
  | { code: 'NOT_FOUND'; message: string }
  | { code: 'DUPLICATE_EMAIL'; message: string }
  | { code: 'VALIDATION_FAILED'; message: string; fields: string[] };

// Service method returns Result
async function createUser(
  input: CreateUserInput
): Promise<Result<User, UserError>> {
  // Check for duplicate
  const existing = await this.userRepo.findByEmail(input.email);
  if (existing) {
    return {
      success: false,
      error: { code: 'DUPLICATE_EMAIL', message: 'Email already registered' }
    };
  }
  
  // Create user
  const user = await this.userRepo.create(input);
  return { success: true, data: user };
}

// Caller handles both cases
const result = await userService.createUser(input);

if (!result.success) {
  // Handle specific error
  switch (result.error.code) {
    case 'DUPLICATE_EMAIL':
      return res.status(409).json({ error: result.error.message });
    case 'VALIDATION_FAILED':
      return res.status(400).json({ error: result.error });
    default:
      return res.status(500).json({ error: 'Internal error' });
  }
}

// Success path - data is typed
const user = result.data;
```

## When to Throw vs Return Result

**Return Result for:**
- Validation failures
- Resource not found
- Business rule violations
- Expected edge cases

**Throw for:**
- Programmer errors (bugs)
- Truly exceptional situations
- Unrecoverable states

## Validation Checklist

- [ ] Function returns Result type (not throwing for expected failures)
- [ ] Error type is explicit and documented
- [ ] Caller checks success before accessing data
- [ ] Error cases are handled appropriately
- [ ] No `try/catch` used for expected failures

## Severity

- Throwing for expected failures: **HIGH**
- Untyped error returns: **MEDIUM**
- Missing error case handling in caller: **HIGH**
