---
name: Error Log Analysis
description: Analyze application errors and logs to identify root causes. Supports Sentry, local logs, and various log formats.
---

# Error Log Analysis

Analyze application errors and logs to identify root causes, patterns, and remediation steps.

## Purpose

This skill provides a standardized workflow for analyzing errors from various sources:

- Sentry and similar error tracking services
- Local log files (application logs, server logs)
- Console output and stack traces
- CI/CD pipeline failures

## Instructions

### Step 1: Identify Error Source

Determine where the error information is coming from:

```
SOURCES:
1. Sentry/error tracking service (URL or issue ID provided)
2. Local log files (path provided or standard locations)
3. Console output (user provides stack trace)
4. CI/CD logs (pipeline URL or output)
```

### Step 2: Load Cookbook

Based on the source, load the appropriate cookbook:

| Source | Cookbook |
|--------|----------|
| Sentry | `cookbook/sentry.md` |
| Local logs | `cookbook/local-logs.md` |
| Stack traces | `cookbook/stack-trace.md` |
| Docker/containers | `cookbook/docker-logs.md` |

```
READ cookbook/{source-type}.md
FOLLOW source-specific extraction patterns
```

### Step 3: Extract Error Information

Gather key details from the error:

```
EXTRACT:
- Error message (exact text)
- Error type/class
- Stack trace (full if available)
- Timestamp and frequency
- Environment (dev/staging/prod)
- Affected users/requests (if available)
- Related errors (similar or cascading)
```

### Step 4: Analyze Root Cause

Follow systematic analysis:

1. **Parse the stack trace** - Identify origin point in codebase
2. **Check the context** - What was happening when error occurred
3. **Review recent changes** - Git history around affected files
4. **Check for patterns** - Is this recurring? When did it start?
5. **Identify dependencies** - External services, database, APIs

### Step 5: Locate Relevant Code

```
FOR each stack frame in user code:
  READ file at specified line
  EXPAND context (10 lines before/after)
  IDENTIFY potential issues:
  - Null/undefined access
  - Type mismatches
  - Missing error handling
  - Race conditions
  - Resource limits
```

### Step 6: Generate Diagnosis

Produce actionable diagnosis:

```markdown
## Error Analysis

**Error**: {error message}
**Type**: {error class/type}
**First seen**: {timestamp}
**Frequency**: {count} in {timeframe}

### Root Cause

{Explanation of what's happening and why}

### Affected Code

{file:line} - {brief description}

### Contributing Factors

- {factor 1}
- {factor 2}

### Recommended Fix

{Specific code changes or configuration}

### Prevention

{How to prevent similar errors}
```

## Analysis Patterns

### Null/Undefined Errors

```
PATTERN: "Cannot read property 'x' of undefined"
ANALYSIS:
1. Find the variable access in stack trace
2. Trace back where the value comes from
3. Identify missing null checks or data flow issues
4. Check for race conditions in async code
```

### Type Errors

```
PATTERN: "x is not a function" or type mismatch
ANALYSIS:
1. Check expected vs actual type
2. Review type definitions/interfaces
3. Check for version mismatches in dependencies
4. Look for incorrect imports
```

### Network/API Errors

```
PATTERN: Timeout, connection refused, 4xx/5xx
ANALYSIS:
1. Check endpoint availability
2. Review request payload
3. Check authentication/authorization
4. Review rate limits
5. Check for DNS or network issues
```

### Memory/Performance Errors

```
PATTERN: Out of memory, heap overflow, timeouts
ANALYSIS:
1. Check for memory leaks (unclosed resources)
2. Review data sizes being processed
3. Look for infinite loops or recursion
4. Check pagination/batching
```

## Integration Points

### With Git History

```
RUN git log --since="1 week ago" -- {affected-file}
ANALYZE recent changes that may have introduced the bug
```

### With Test Suite

```
CHECK if affected code has test coverage
SUGGEST tests that would have caught this error
```

### With Monitoring

If available, correlate with:
- CPU/memory metrics at time of error
- Request volume/patterns
- Database query performance
- External service health

## Examples

### Example 1: Sentry Error Analysis

```
User: "Analyze this Sentry issue: PROJ-1234"

1. Load: cookbook/sentry.md
2. Fetch issue details via Sentry API or URL
3. Extract: TypeError in UserService.ts:45
4. Read: UserService.ts around line 45
5. Identify: Missing null check on user.preferences
6. Check git: Introduced in commit abc123 yesterday
7. Report: Root cause + fix suggestion
```

### Example 2: Local Log Analysis

```
User: "Getting errors in logs/app.log"

1. Load: cookbook/local-logs.md
2. Read last 100 lines of logs/app.log
3. Parse: Find ERROR level entries
4. Extract stack trace
5. Trace to code
6. Analyze pattern: Happening on every 5th request
7. Identify: Connection pool exhaustion
```

### Example 3: Stack Trace Analysis

```
User provides:
"Error: ECONNREFUSED 127.0.0.1:5432
    at TCPConnectWrap.afterConnect"

1. Load: cookbook/stack-trace.md
2. Identify: PostgreSQL connection refused
3. Check: Is database running? Environment variables?
4. Verify: DATABASE_URL configuration
5. Report: Database connection issue + steps to verify
```

## Output Format

```markdown
# Error Analysis Report

## Summary
- **Error**: {brief description}
- **Severity**: {Critical/High/Medium/Low}
- **Impact**: {who/what is affected}

## Stack Trace
{sanitized stack trace}

## Root Cause Analysis

### What Happened
{Technical explanation}

### Why It Happened
{Root cause}

### When It Started
{Timestamp or trigger event}

## Affected Code

{file:line references with context}

## Recommended Actions

1. **Immediate**: {quick fix or mitigation}
2. **Short-term**: {proper fix}
3. **Long-term**: {prevention measures}

## Verification Steps

1. {How to verify the fix works}
2. {How to monitor for recurrence}
```

## Safety Notes

- Never expose sensitive data (API keys, passwords, PII) in reports
- Sanitize stack traces before sharing
- Be careful with production database access
- Recommend backups before destructive fixes
