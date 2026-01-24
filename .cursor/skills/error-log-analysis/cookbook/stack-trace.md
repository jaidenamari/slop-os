# Stack Trace Analysis Cookbook

Patterns for analyzing stack traces and error messages provided directly.

## Stack Trace Formats

### JavaScript/Node.js

```
TypeError: Cannot read property 'name' of undefined
    at UserService.getUser (/app/src/services/UserService.ts:45:23)
    at async /app/src/routes/users.ts:12:18
    at Layer.handle [as handle_request] (/app/node_modules/express/lib/router/layer.js:95:5)
```

### Python

```
Traceback (most recent call last):
  File "/app/main.py", line 45, in handle_request
    result = process_data(data)
  File "/app/utils.py", line 23, in process_data
    return data['key']['nested']
KeyError: 'nested'
```

### Java

```
java.lang.NullPointerException: Cannot invoke method on null object
    at com.example.UserService.getUser(UserService.java:45)
    at com.example.UserController.handleRequest(UserController.java:23)
    at org.springframework.web.servlet.FrameworkServlet.service(FrameworkServlet.java:897)
```

### Go

```
panic: runtime error: invalid memory address or nil pointer dereference
[signal SIGSEGV: segmentation violation code=0x1 addr=0x0 pc=0x1234567]

goroutine 1 [running]:
main.processUser(...)
    /app/main.go:45 +0x123
main.handleRequest(0xc000123456)
    /app/handler.go:23 +0x456
```

### Rust

```
thread 'main' panicked at 'called `Option::unwrap()` on a `None` value', src/main.rs:45:10
stack backtrace:
   0: std::panicking::begin_panic
   1: core::option::Option<T>::unwrap
   2: myapp::process_user
             at ./src/main.rs:45:10
```

## Analysis Workflow

### Step 1: Identify Error Type

```
COMMON ERROR TYPES:

JavaScript:
- TypeError: Type mismatch or null/undefined access
- ReferenceError: Undefined variable
- SyntaxError: Invalid code syntax
- RangeError: Value out of bounds

Python:
- KeyError: Missing dictionary key
- AttributeError: Missing object attribute
- TypeError: Wrong type for operation
- ValueError: Right type, wrong value

Java:
- NullPointerException: Null reference access
- IllegalArgumentException: Invalid argument
- IndexOutOfBoundsException: Array/list index error
- ClassCastException: Invalid type cast
```

### Step 2: Find Origin Point

The most important frame is usually the first one in YOUR code (not library code):

```
SCAN stack trace from top to bottom:
  FOR each frame:
    IF path is in project source (not node_modules, site-packages, etc.):
      THIS is likely the origin
      NOTE: file, line number, function name
      BREAK
```

### Step 3: Understand the Error Message

```
"Cannot read property 'name' of undefined"
                    ^^^^        ^^^^^^^^^
                    |           |
                    |           What was accessed (undefined/null)
                    Property being accessed

IMPLIES: Something.name was called, but Something was undefined
```

### Step 4: Trace Data Flow

```
Starting from error location:
  IDENTIFY the variable causing the error
  TRACE backwards: Where does this value come from?
  - Function parameter?
  - Database query result?
  - API response?
  - Object property?
  
  FIND where the value became null/undefined/incorrect
```

### Step 5: Check Surrounding Code

```
READ the source file at error location
EXPAND context: 10-20 lines before/after
LOOK FOR:
- Missing null checks
- Incorrect assumptions about data shape
- Race conditions
- Missing await on async calls
- Incorrect error handling
```

## Common Error Patterns

### Null/Undefined Access

```javascript
// Error: Cannot read property 'email' of undefined
const email = user.profile.email;

// Fix: Add null checks
const email = user?.profile?.email;
// Or
const email = user && user.profile && user.profile.email;
```

### Missing Await

```javascript
// Error: Cannot read property 'then' of undefined
// (function returned undefined instead of Promise)
async function getUser() {
  const result = fetchUser(id);  // Missing await!
  return result.data;
}
```

### Type Mismatch

```javascript
// Error: x.map is not a function
const items = await fetchItems();
return items.map(i => i.name);

// items might be null, undefined, or an object instead of array
// Fix:
return Array.isArray(items) ? items.map(i => i.name) : [];
```

### Array Index Out of Bounds

```javascript
// Error: Cannot read property '0' of undefined
const first = results[0].value;

// results is undefined or empty
// Fix:
const first = results?.[0]?.value;
```

### Unhandled Promise Rejection

```javascript
// Promise rejected but no .catch()
fetchData().then(process);

// Fix:
fetchData().then(process).catch(handleError);
// Or:
try {
  const data = await fetchData();
  process(data);
} catch (error) {
  handleError(error);
}
```

## Analysis Questions

When analyzing a stack trace, answer:

1. **What** is the error? (Type and message)
2. **Where** did it occur? (File, line, function)
3. **What value** caused the error? (Variable name)
4. **Where** did that value come from? (Data source)
5. **Why** was the value unexpected? (Logic error, data issue, timing)
6. **How** can it be fixed? (Code change)
7. **How** can it be prevented? (Validation, types, tests)

## Output Template

```markdown
## Stack Trace Analysis

### Error Summary
- **Type**: {error type}
- **Message**: {error message}
- **Location**: `{file}:{line}` in `{function}`

### Stack Trace
```
{full stack trace}
```

### Analysis

**What happened**:
{Plain English explanation}

**Root cause**:
{Technical explanation of why the error occurred}

**Affected variable**: `{variable name}`
**Expected value**: {what it should have been}
**Actual value**: {what it was - null, undefined, wrong type, etc.}

### Code Context

```{language}:{line-start}:{line-end}:{filepath}
{relevant code with error location marked}
```

### Data Flow
```
{variable} came from:
  └─ {source 1}
       └─ {source 2}
            └─ {origin - where it became incorrect}
```

### Recommended Fix

```{language}
{code fix}
```

### Prevention
- {How to prevent similar errors}
- {Suggested tests}
- {Type safety improvements}
```

## Special Cases

### Minified Stack Traces

If code is minified without source maps:
- Look for recognizable function names
- Check if source maps exist but aren't configured
- Try to find corresponding source location manually

### Async Stack Traces

Modern runtimes may show async stack traces:
```
Error: Failed
    at async fetchUser (/app/user.ts:10:5)
    at async processRequest (/app/handler.ts:25:3)
```

The `async` keyword helps trace through await points.

### Circular References

```
TypeError: Converting circular structure to JSON
```

Object contains reference to itself. Use:
- Custom serializer
- Libraries like `flatted`
- Break the circular reference
