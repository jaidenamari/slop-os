# Mocha Testing Cookbook

Patterns and conventions for Mocha test suites.

## Detection

Project uses Mocha if:
- `mocha` in package.json devDependencies
- `.mocharc.js`, `.mocharc.json`, or `mocha.opts` exists
- `"mocha"` section in package.json
- Test files in `test/` directory

## Configuration

```javascript
// .mocharc.js
module.exports = {
  extension: ['ts'],
  spec: 'test/**/*.test.ts',
  require: ['ts-node/register'],
  timeout: 5000,
  recursive: true,
};
```

Or in `package.json`:
```json
{
  "mocha": {
    "extension": ["ts"],
    "spec": "test/**/*.test.ts",
    "require": ["ts-node/register"]
  }
}
```

## Commands

```bash
# Run all tests
npm test
# or
npx mocha

# Run specific file
npx mocha test/UserService.test.ts

# Run tests matching pattern
npx mocha --grep "should create"

# Watch mode
npx mocha --watch

# With coverage (nyc)
npx nyc mocha
```

## Test File Structure

Mocha uses BDD style by default (describe/it). Assertions require a separate library (Chai is common):

```typescript
import { describe, it, beforeEach, afterEach } from 'mocha';
import { expect } from 'chai';
import sinon from 'sinon';
import { UserService } from '../src/UserService';
import { UserRepository } from '../src/repositories/UserRepository';

describe('UserService', () => {
  let service: UserService;
  let mockRepo: sinon.SinonStubbedInstance<UserRepository>;

  beforeEach(() => {
    mockRepo = sinon.createStubInstance(UserRepository);
    service = new UserService(mockRepo);
  });

  afterEach(() => {
    sinon.restore();
  });

  describe('createUser', () => {
    it('should create user with valid data', async () => {
      // Arrange
      const userData = { email: 'test@example.com', name: 'Test' };
      mockRepo.create.resolves({ id: 1, ...userData });

      // Act
      const result = await service.createUser(userData);

      // Assert
      expect(result).to.deep.equal({ id: 1, ...userData });
      expect(mockRepo.create.calledWith(userData)).to.be.true;
    });

    it('should throw if email already exists', async () => {
      // Arrange
      mockRepo.findByEmail.resolves({ id: 1, email: 'test@example.com' });

      // Act & Assert
      await expect(service.createUser({ email: 'test@example.com' }))
        .to.be.rejectedWith('Email already exists');
    });
  });
});
```

## Assertion Libraries

### Chai (most common)

```typescript
import { expect, assert, should } from 'chai';

// Expect style
expect(value).to.equal(expected);
expect(value).to.deep.equal(expected);
expect(value).to.be.true;
expect(value).to.be.null;
expect(array).to.include(item);
expect(obj).to.have.property('key');
expect(() => fn()).to.throw('error');

// Assert style
assert.equal(value, expected);
assert.deepEqual(value, expected);
assert.isTrue(value);
assert.throws(() => fn(), 'error');

// Should style
value.should.equal(expected);
value.should.be.true;
```

### Chai plugins

```typescript
// chai-as-promised (async assertions)
import chaiAsPromised from 'chai-as-promised';
chai.use(chaiAsPromised);

await expect(promise).to.eventually.equal('value');
await expect(promise).to.be.rejectedWith('error');

// chai-http (HTTP testing)
import chaiHttp from 'chai-http';
chai.use(chaiHttp);

chai.request(app).get('/users').end((err, res) => {
  expect(res).to.have.status(200);
});
```

## Mocking with Sinon

```typescript
import sinon from 'sinon';

// Stub
const stub = sinon.stub(obj, 'method');
stub.returns('value');
stub.resolves('async value');
stub.rejects(new Error('failed'));
stub.callsFake((arg) => arg + 1);

// Spy
const spy = sinon.spy(obj, 'method');
expect(spy.called).to.be.true;
expect(spy.calledWith('arg')).to.be.true;
expect(spy.callCount).to.equal(2);

// Mock
const mock = sinon.mock(obj);
mock.expects('method').once().withArgs('arg').returns('value');
mock.verify();

// Fake timers
const clock = sinon.useFakeTimers();
clock.tick(1000);
clock.restore();

// Restore all
sinon.restore();
```

## Async Testing

```typescript
// Async/await
it('should fetch data', async () => {
  const result = await service.fetchData();
  expect(result).to.exist;
});

// Promises (return the promise)
it('should resolve', () => {
  return service.fetchData().then(result => {
    expect(result).to.exist;
  });
});

// Callbacks (use done)
it('should callback', (done) => {
  service.fetchData((err, data) => {
    expect(data).to.exist;
    done();
  });
});

// With chai-as-promised
it('should resolve', () => {
  return expect(service.fetchData()).to.eventually.exist;
});
```

## Hooks

```typescript
// Per test
beforeEach(() => { /* setup */ });
afterEach(() => { /* cleanup */ });

// Per describe block
before(() => { /* one-time setup */ });
after(() => { /* one-time cleanup */ });

// Async hooks
beforeEach(async () => {
  await db.connect();
});

// Named hooks (for debugging)
beforeEach('setup database', async () => {
  await db.seed();
});
```

## Test Organization

### Skip and Only

```typescript
// Skip test
it.skip('should be skipped', () => {});
describe.skip('skipped suite', () => {});

// Run only this
it.only('run only this', () => {});
describe.only('only this suite', () => {});
```

### Pending tests

```typescript
it('todo - implement later');
```

### Retries

```typescript
describe('flaky tests', () => {
  this.retries(3);
  
  it('might fail', () => {});
});
```

### Timeout

```typescript
describe('slow tests', function() {
  this.timeout(10000);
  
  it('takes time', async function() {
    this.timeout(5000); // per-test
    await slowOperation();
  });
});
```

## HTTP Testing with Supertest

```typescript
import request from 'supertest';
import app from '../src/app';

describe('GET /users', () => {
  it('should return users', async () => {
    const res = await request(app)
      .get('/users')
      .expect(200)
      .expect('Content-Type', /json/);
    
    expect(res.body).to.have.lengthOf(2);
  });

  it('should create user', async () => {
    const res = await request(app)
      .post('/users')
      .send({ name: 'John', email: 'john@example.com' })
      .expect(201);
    
    expect(res.body).to.have.property('id');
  });
});
```

## Database Testing

```typescript
describe('with database', () => {
  before(async () => {
    await db.connect();
  });

  after(async () => {
    await db.disconnect();
  });

  beforeEach(async () => {
    await db.clear();
    await db.seed();
  });

  it('should query users', async () => {
    const users = await userRepo.findAll();
    expect(users).to.have.lengthOf(3);
  });
});
```

## Coverage with NYC

```json
// package.json
{
  "scripts": {
    "test": "mocha",
    "test:coverage": "nyc mocha"
  },
  "nyc": {
    "extension": [".ts"],
    "include": ["src/**/*.ts"],
    "exclude": ["**/*.test.ts"],
    "reporter": ["text", "html"],
    "all": true
  }
}
```

## Troubleshooting

### Tests timing out
- Increase timeout: `this.timeout(10000)`
- Check async operations complete
- Ensure `done()` is called in callbacks

### Hooks not running
- Check hook placement (inside/outside describe)
- Use `before` vs `beforeEach` appropriately

### TypeScript issues
- Ensure `ts-node/register` in require
- Check tsconfig includes test files

### Sinon stubs not working
- Call `sinon.restore()` in afterEach
- Stub before creating instances
- Check method is not already stubbed
