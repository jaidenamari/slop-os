# Vitest Testing Cookbook

Patterns and conventions for Vitest test suites.

## Detection

Project uses Vitest if:
- `vitest` in package.json devDependencies
- `vitest.config.ts` or `vitest.config.js` exists
- `vite.config.ts` with test configuration
- Test files with `.test.ts` or `.spec.ts` extensions

## Configuration

Common config locations:
- `vitest.config.ts` (standalone)
- `vite.config.ts` with `test` section

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    include: ['src/**/*.test.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html'],
    },
  },
});
```

## Commands

```bash
# Run all tests
npm test
# or
npx vitest

# Run specific file
npx vitest UserService.test.ts

# Run tests matching pattern
npx vitest --testNamePattern="should create"

# Run with coverage
npx vitest --coverage

# Watch mode (default)
npx vitest

# Run once
npx vitest run

# UI mode
npx vitest --ui
```

## Test File Structure

```typescript
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { UserService } from '../UserService';
import { UserRepository } from '../repositories/UserRepository';

// Mock dependencies
vi.mock('../repositories/UserRepository');

describe('UserService', () => {
  let service: UserService;
  let mockRepo: UserRepository;

  beforeEach(() => {
    mockRepo = new UserRepository();
    service = new UserService(mockRepo);
    vi.clearAllMocks();
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  describe('createUser', () => {
    it('should create user with valid data', async () => {
      // Arrange
      const userData = { email: 'test@example.com', name: 'Test' };
      vi.mocked(mockRepo.create).mockResolvedValue({ id: 1, ...userData });

      // Act
      const result = await service.createUser(userData);

      // Assert
      expect(result).toEqual({ id: 1, ...userData });
      expect(mockRepo.create).toHaveBeenCalledWith(userData);
    });

    it('should throw if email already exists', async () => {
      // Arrange
      vi.mocked(mockRepo.findByEmail).mockResolvedValue({ id: 1, email: 'test@example.com' });

      // Act & Assert
      await expect(service.createUser({ email: 'test@example.com' }))
        .rejects.toThrow('Email already exists');
    });
  });
});
```

## Mocking Patterns

### Mock Module

```typescript
vi.mock('../services/EmailService');
import { EmailService } from '../services/EmailService';

// Type-safe mock
const mockEmailService = vi.mocked(EmailService);
```

### Mock Function

```typescript
const mockFn = vi.fn();
mockFn.mockReturnValue('value');
mockFn.mockResolvedValue('async value');
mockFn.mockRejectedValue(new Error('failed'));
```

### Mock Implementation

```typescript
vi.mock('../utils/logger', () => ({
  info: vi.fn(),
  error: vi.fn(),
}));
```

### Spy on Method

```typescript
const spy = vi.spyOn(service, 'privateMethod');
spy.mockReturnValue('mocked');

// Verify
expect(spy).toHaveBeenCalled();
```

### Mock Timer

```typescript
vi.useFakeTimers();

// In test
vi.advanceTimersByTime(1000);
vi.runAllTimers();

// Cleanup
vi.useRealTimers();
```

### Mock Date

```typescript
vi.setSystemTime(new Date('2024-01-15'));

// Cleanup
vi.useRealTimers();
```

## Assertion Patterns

Vitest uses Chai-style assertions (compatible with Jest):

```typescript
// Equality
expect(value).toBe(expected);           // strict equality
expect(value).toEqual(expected);        // deep equality
expect(value).toStrictEqual(expected);  // deep + type equality

// Truthiness
expect(value).toBeTruthy();
expect(value).toBeFalsy();
expect(value).toBeNull();
expect(value).toBeUndefined();

// Numbers
expect(value).toBeGreaterThan(5);
expect(value).toBeLessThanOrEqual(10);
expect(value).toBeCloseTo(0.3, 5);

// Strings
expect(value).toMatch(/pattern/);
expect(value).toContain('substring');

// Arrays
expect(array).toContain(item);
expect(array).toHaveLength(3);

// Objects
expect(obj).toHaveProperty('key');
expect(obj).toMatchObject({ key: 'value' });

// Errors
expect(() => fn()).toThrow();
expect(() => fn()).toThrowError('message');

// Async
await expect(promise).resolves.toBe(value);
await expect(promise).rejects.toThrow();

// Mock calls
expect(mock).toHaveBeenCalled();
expect(mock).toHaveBeenCalledTimes(2);
expect(mock).toHaveBeenCalledWith(arg1, arg2);
```

## Testing Async Code

```typescript
// Async/await
it('should fetch data', async () => {
  const result = await service.fetchData();
  expect(result).toBeDefined();
});

// Promises
it('should resolve', () => {
  return expect(service.fetchData()).resolves.toBeDefined();
});
```

## Snapshot Testing

```typescript
it('should match snapshot', () => {
  const result = service.generateReport();
  expect(result).toMatchSnapshot();
});

// Inline snapshot
it('should match inline', () => {
  expect(result).toMatchInlineSnapshot(`
    {
      "status": "success",
    }
  `);
});

// Update snapshots: npx vitest -u
```

## Setup & Teardown

```typescript
import { beforeEach, afterEach, beforeAll, afterAll } from 'vitest';

// Per test
beforeEach(() => { /* setup */ });
afterEach(() => { /* cleanup */ });

// Per describe block
beforeAll(() => { /* one-time setup */ });
afterAll(() => { /* one-time cleanup */ });
```

## Global Setup

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    globalSetup: './tests/globalSetup.ts',
    setupFiles: ['./tests/setup.ts'],
  },
});

// tests/setup.ts
import { beforeEach } from 'vitest';
beforeEach(() => {
  // runs before every test in every file
});
```

## Testing Components (Vue/React)

### With Testing Library

```typescript
import { render, screen, fireEvent } from '@testing-library/vue';
// or '@testing-library/react'
import UserCard from './UserCard.vue';

describe('UserCard', () => {
  it('should render user name', () => {
    render(UserCard, {
      props: { user: { name: 'John' } },
    });
    
    expect(screen.getByText('John')).toBeInTheDocument();
  });

  it('should call onClick', async () => {
    const onClick = vi.fn();
    render(UserCard, {
      props: { user: { name: 'John' }, onClick },
    });
    
    await fireEvent.click(screen.getByRole('button'));
    expect(onClick).toHaveBeenCalled();
  });
});
```

## Environment Configuration

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    // 'node' | 'jsdom' | 'happy-dom'
    environment: 'jsdom',
    
    // Per-file environment
    environmentMatchGlobs: [
      ['src/**/*.test.ts', 'node'],
      ['src/**/*.component.test.ts', 'jsdom'],
    ],
  },
});
```

## Type-Safe Mocks

```typescript
import { vi, type MockedFunction } from 'vitest';

// Type the mock
const mockFetch: MockedFunction<typeof fetch> = vi.fn();

// Or use vi.mocked for existing functions
vi.mocked(someFunction).mockReturnValue('value');
```

## Concurrent Tests

```typescript
// Run tests in parallel
describe.concurrent('parallel tests', () => {
  it('test 1', async () => { /* ... */ });
  it('test 2', async () => { /* ... */ });
});

// Or per-test
it.concurrent('parallel test', async () => { /* ... */ });
```

## Troubleshooting

### Tests interfering with each other
- Use `beforeEach` to reset state
- Call `vi.clearAllMocks()` between tests
- Use `vi.restoreAllMocks()` in afterEach

### Module not being mocked
- Ensure `vi.mock()` is hoisted (at top of file)
- Check path matches exactly
- Use `vi.doMock()` for dynamic mocking

### TypeScript mock errors
- Use `vi.mocked()` for type inference
- Import `MockedFunction` type from vitest

### DOM not available
- Set `environment: 'jsdom'` in config
- Or use `// @vitest-environment jsdom` comment in file
