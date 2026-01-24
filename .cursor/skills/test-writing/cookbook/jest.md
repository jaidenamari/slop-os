# Jest Testing Cookbook

Patterns and conventions for Jest test suites.

## Detection

Project uses Jest if:
- `jest` in package.json devDependencies
- `jest.config.js`, `jest.config.ts`, or `jest.config.json` exists
- `"jest"` section in package.json
- Test files with `.test.ts` or `.spec.ts` extensions

## Configuration

Common config locations:
- `jest.config.ts` / `jest.config.js`
- `package.json` under `"jest"` key

```typescript
// jest.config.ts
export default {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src'],
  testMatch: ['**/*.test.ts'],
  collectCoverageFrom: ['src/**/*.ts'],
};
```

## Commands

```bash
# Run all tests
npm test

# Run specific test file
npm test -- UserService.test.ts

# Run tests matching pattern
npm test -- --testNamePattern="should create"

# Run with coverage
npm test -- --coverage

# Watch mode
npm test -- --watch
```

## Test File Structure

```typescript
import { UserService } from '../UserService';
import { UserRepository } from '../repositories/UserRepository';

// Mock dependencies
jest.mock('../repositories/UserRepository');

describe('UserService', () => {
  let service: UserService;
  let mockRepo: jest.Mocked<UserRepository>;

  beforeEach(() => {
    mockRepo = new UserRepository() as jest.Mocked<UserRepository>;
    service = new UserService(mockRepo);
    jest.clearAllMocks();
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe('createUser', () => {
    it('should create user with valid data', async () => {
      // Arrange
      const userData = { email: 'test@example.com', name: 'Test' };
      mockRepo.create.mockResolvedValue({ id: 1, ...userData });

      // Act
      const result = await service.createUser(userData);

      // Assert
      expect(result).toEqual({ id: 1, ...userData });
      expect(mockRepo.create).toHaveBeenCalledWith(userData);
    });

    it('should throw if email already exists', async () => {
      // Arrange
      mockRepo.findByEmail.mockResolvedValue({ id: 1, email: 'test@example.com' });

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
jest.mock('../services/EmailService');
import { EmailService } from '../services/EmailService';

const mockEmailService = EmailService as jest.Mocked<typeof EmailService>;
```

### Mock Function

```typescript
const mockFn = jest.fn();
mockFn.mockReturnValue('value');
mockFn.mockResolvedValue('async value');
mockFn.mockRejectedValue(new Error('failed'));
```

### Mock Implementation

```typescript
jest.mock('../utils/logger', () => ({
  info: jest.fn(),
  error: jest.fn(),
}));
```

### Spy on Method

```typescript
const spy = jest.spyOn(service, 'privateMethod');
spy.mockReturnValue('mocked');

// Verify
expect(spy).toHaveBeenCalled();
```

### Mock Timer

```typescript
jest.useFakeTimers();

// In test
jest.advanceTimersByTime(1000);
jest.runAllTimers();

// Cleanup
jest.useRealTimers();
```

## Assertion Patterns

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
expect(array).toEqual(expect.arrayContaining([1, 2]));

// Objects
expect(obj).toHaveProperty('key');
expect(obj).toMatchObject({ key: 'value' });

// Errors
expect(() => fn()).toThrow();
expect(() => fn()).toThrow('message');
expect(() => fn()).toThrow(ErrorClass);

// Async
await expect(promise).resolves.toBe(value);
await expect(promise).rejects.toThrow();

// Mock calls
expect(mock).toHaveBeenCalled();
expect(mock).toHaveBeenCalledTimes(2);
expect(mock).toHaveBeenCalledWith(arg1, arg2);
expect(mock).toHaveBeenLastCalledWith(arg);
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

// Callbacks (use done)
it('should callback', (done) => {
  service.fetchData((err, data) => {
    expect(data).toBeDefined();
    done();
  });
});
```

## Testing Errors

```typescript
// Sync errors
it('should throw on invalid input', () => {
  expect(() => service.validate(null)).toThrow('Invalid input');
});

// Async errors
it('should reject on failure', async () => {
  await expect(service.fetch('bad')).rejects.toThrow('Not found');
});

// Error type
it('should throw ValidationError', () => {
  expect(() => service.validate(null)).toThrow(ValidationError);
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
    Object {
      "status": "success",
    }
  `);
});

// Update snapshots: npm test -- -u
```

## Setup & Teardown

```typescript
// Per test
beforeEach(() => { /* setup */ });
afterEach(() => { /* cleanup */ });

// Per describe block
beforeAll(() => { /* one-time setup */ });
afterAll(() => { /* one-time cleanup */ });

// Global (in setupTests.ts)
beforeAll(() => { /* global setup */ });
```

## Common Patterns

### Testing API Endpoints

```typescript
import request from 'supertest';
import app from '../app';

describe('GET /users', () => {
  it('should return users', async () => {
    const res = await request(app)
      .get('/users')
      .expect(200);
    
    expect(res.body).toHaveLength(2);
  });
});
```

### Testing with Database

```typescript
beforeAll(async () => {
  await db.connect();
});

afterAll(async () => {
  await db.disconnect();
});

beforeEach(async () => {
  await db.clear();
  await db.seed();
});
```

### Testing Environment Variables

```typescript
const originalEnv = process.env;

beforeEach(() => {
  process.env = { ...originalEnv, API_KEY: 'test-key' };
});

afterEach(() => {
  process.env = originalEnv;
});
```

## Troubleshooting

### Tests interfering with each other
- Use `beforeEach` to reset state
- Call `jest.clearAllMocks()` between tests
- Avoid shared mutable state

### Async tests timing out
- Increase timeout: `jest.setTimeout(10000)`
- Or per-test: `it('slow test', async () => {...}, 10000)`

### Mock not working
- Ensure mock is before import
- Use `jest.mock()` at top of file
- Check mock path matches import path exactly
