# Sentry Error Analysis Cookbook

Patterns for analyzing errors from Sentry and similar error tracking services.

## Accessing Sentry Data

### Via Web URL

If user provides a Sentry URL:
```
https://sentry.io/organizations/{org}/issues/{issue-id}/
```

Use web fetch to get issue details (if public or authenticated).

### Via API (if configured)

```bash
# Get issue details
curl -H "Authorization: Bearer $SENTRY_AUTH_TOKEN" \
  "https://sentry.io/api/0/issues/{issue_id}/"

# Get events for an issue
curl -H "Authorization: Bearer $SENTRY_AUTH_TOKEN" \
  "https://sentry.io/api/0/issues/{issue_id}/events/"
```

### Via MCP (if available)

Some projects may have Sentry MCP configured:
```
mcp_sentry__get_issue({issue_id})
mcp_sentry__get_events({issue_id})
```

## Key Information to Extract

### From Issue Summary

- **Title**: Error message and type
- **Culprit**: File and function where error originated
- **First seen / Last seen**: Timeline of the error
- **Event count**: Frequency and trend
- **Users affected**: Impact scope
- **Tags**: Environment, browser, OS, release version

### From Event Details

- **Stack trace**: Full trace with source context
- **Breadcrumbs**: Actions leading up to error
- **Request data**: URL, method, headers (sanitized)
- **User context**: User ID, email (if available)
- **Device/browser info**: Platform details
- **Release**: Version/commit where error occurs

### From Trends

- **Regression**: Did error spike after a deploy?
- **Pattern**: Time-based (peak hours? specific actions?)
- **Correlation**: Related issues or similar errors

## Analysis Workflow

### Step 1: Understand the Error

```
READ Sentry issue:
- Error type (TypeError, ReferenceError, custom error)
- Error message (exact text)
- Culprit file and function
```

### Step 2: Analyze Stack Trace

```
FOR each frame in stack trace:
  IF frame is in user code (not node_modules):
    NOTE file path and line number
    READ corresponding source file
    EXAMINE surrounding code
```

### Step 3: Review Breadcrumbs

Breadcrumbs show what happened before the error:
```
- User navigated to /dashboard
- XHR request to /api/users
- Click on "Load More" button
- ERROR: Cannot read property 'items' of undefined
```

Use this to understand the user journey and reproduce.

### Step 4: Check Release Context

```
IDENTIFY release version from Sentry
CHECK git commits in that release:
  git log {previous-release}..{error-release} -- {affected-file}

LOOK FOR:
- Recent changes to affected code
- Related dependency updates
- Configuration changes
```

### Step 5: Analyze Frequency

```
IF error is new (< 24 hours):
  LIKELY regression from recent deploy
  CHECK: What changed?

IF error is recurring:
  CHECK: Pattern in timing or user actions
  CHECK: Specific user segments affected

IF error is intermittent:
  CHECK: Race conditions, external service issues
  CHECK: Load-related problems
```

## Common Sentry Error Patterns

### Unhandled Promise Rejection

```
Error: Unhandled Promise Rejection
```

Look for:
- Missing `.catch()` handlers
- Missing `try/catch` in async functions
- Fire-and-forget promises

### ChunkLoadError

```
ChunkLoadError: Loading chunk X failed
```

Causes:
- Deployment during user session (old chunks deleted)
- Network issues
- CDN cache problems

Fix: Implement chunk retry logic or full page refresh

### Network Errors

```
TypeError: Failed to fetch
NetworkError: A network error occurred
```

Check:
- CORS configuration
- API endpoint availability
- SSL certificate issues
- Request timeout settings

### Hydration Mismatch (React/Vue)

```
Hydration failed because the initial UI does not match
```

Causes:
- Server/client rendering differences
- Browser extensions modifying DOM
- Date/time formatting differences

## Sentry-Specific Features

### Source Maps

If source maps are configured:
- Stack traces show original TypeScript/ES6+ code
- Line numbers match source files

If not configured:
- Stack traces show minified code
- Need to manually map to source

### Issue Grouping

Sentry groups similar errors. Check:
- Are multiple root causes grouped together?
- Is one error marked as regression of another?

### Suggested Fix (AI)

Sentry may suggest fixes. Evaluate:
- Is the suggestion relevant to your codebase?
- Does it address root cause or just symptoms?

## Output Template

```markdown
## Sentry Issue Analysis

**Issue**: {PROJ-1234}
**Error**: {error message}
**Type**: {error type}
**Culprit**: {file:function}

### Timeline
- First seen: {date}
- Last seen: {date}
- Events: {count} ({trend})
- Users affected: {count}

### Stack Trace (Key Frames)
```
{simplified stack trace with user code highlighted}
```

### Breadcrumbs Summary
{User journey leading to error}

### Root Cause
{Explanation}

### Release Context
- Error introduced in: {release}
- Relevant commits: {commit hashes}

### Recommended Fix
{Code changes}

### Verification
1. Deploy fix
2. Monitor Sentry for resolution
3. Mark issue as resolved
```

## Integration with Codebase

After extracting error details:

1. **Locate affected code**
   ```
   READ {culprit-file}
   EXAMINE line {error-line} with context
   ```

2. **Check test coverage**
   ```
   GREP for tests covering the affected function
   ```

3. **Review git blame**
   ```
   git blame {file} -L {start},{end}
   ```

4. **Check related code**
   - Callers of the affected function
   - Similar patterns elsewhere
