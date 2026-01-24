# Local Logs Analysis Cookbook

Patterns for analyzing local application and server logs.

## Common Log Locations

### Application Logs

```
./logs/
./log/
./app.log
./storage/logs/  (Laravel)
./var/log/       (Symfony)
```

### Server Logs

```
/var/log/nginx/error.log
/var/log/apache2/error.log
/var/log/syslog
/var/log/messages
```

### Framework-Specific

```
# Node.js (PM2)
~/.pm2/logs/

# Rails
log/development.log
log/production.log

# Django
Configured in settings.py (often ./logs/)
```

## Log Format Detection

### JSON Logs (Structured)

```json
{"level":"error","message":"Connection failed","timestamp":"2024-01-15T10:30:00Z","error":{"name":"ECONNREFUSED","stack":"..."}}
```

Parse with: `jq`, JSON parsing

### Standard Log Format

```
2024-01-15 10:30:00 [ERROR] Connection failed: ECONNREFUSED
```

Parse with: regex, `grep`, `awk`

### Apache/Nginx Combined

```
192.168.1.1 - - [15/Jan/2024:10:30:00 +0000] "GET /api/users HTTP/1.1" 500 1234
```

### Multiline (Stack Traces)

```
2024-01-15 10:30:00 [ERROR] Unhandled exception
TypeError: Cannot read property 'id' of undefined
    at UserService.getUser (/app/src/services/user.ts:45:10)
    at async Router.handle (/app/node_modules/express/router.js:123:5)
```

## Analysis Workflow

### Step 1: Identify Log Files

```bash
# List recent log files
ls -la logs/ | head -20

# Find log files modified today
find . -name "*.log" -mtime 0

# Check file sizes (large = active)
du -h logs/*
```

### Step 2: Extract Errors

```bash
# Find ERROR level entries
grep -i "error\|exception\|fatal" logs/app.log

# Last 100 errors
grep -i error logs/app.log | tail -100

# Errors with context (2 lines before/after)
grep -B2 -A2 -i error logs/app.log

# Count error types
grep -oP 'Error: \K[^:]+' logs/app.log | sort | uniq -c | sort -rn
```

### Step 3: Filter by Time

```bash
# Errors in last hour (adjust pattern for your format)
grep "2024-01-15 10:" logs/app.log | grep -i error

# Errors since specific time
awk '/2024-01-15 10:00/,0' logs/app.log | grep -i error
```

### Step 4: Parse Stack Traces

For multiline stack traces:
```bash
# Extract stack traces (assuming blank line separator)
awk '/Error|Exception/{p=1} p; /^$/{p=0}' logs/app.log
```

### Step 5: Correlate with Code

```
FOR each error found:
  EXTRACT file path and line number from stack trace
  READ source file at that location
  IDENTIFY the error-causing code
```

## Common Error Patterns

### Database Errors

```
Error: ECONNREFUSED 127.0.0.1:5432
Error: Connection pool exhausted
Error: Query timeout after 30000ms
```

Check:
- Database is running: `docker ps` or `systemctl status postgresql`
- Connection string in environment
- Pool size vs concurrent requests

### Memory Errors

```
FATAL ERROR: CALL_AND_RETRY_LAST Allocation failed
JavaScript heap out of memory
```

Check:
- Memory limits: `--max-old-space-size`
- Memory leaks (unbounded arrays, unclosed connections)
- Large data processing without streaming

### File System Errors

```
Error: ENOENT: no such file or directory
Error: EACCES: permission denied
Error: EMFILE: too many open files
```

Check:
- File paths and existence
- User permissions
- `ulimit -n` for file descriptor limit

### Network/Request Errors

```
Error: ETIMEDOUT
Error: ECONNRESET
Error: socket hang up
```

Check:
- External service availability
- Firewall rules
- Request timeouts
- Keep-alive settings

## JSON Log Analysis

For structured JSON logs:

```bash
# Pretty print
cat logs/app.log | jq '.'

# Filter by level
cat logs/app.log | jq 'select(.level == "error")'

# Extract specific fields
cat logs/app.log | jq 'select(.level == "error") | {timestamp, message, error}'

# Count by error message
cat logs/app.log | jq -r 'select(.level == "error") | .message' | sort | uniq -c | sort -rn
```

## Log Rotation Considerations

If logs are rotated:
```bash
# Check rotated files
ls -la logs/app.log*
ls -la /var/log/app/*.gz

# Search in rotated logs
zgrep -i error logs/app.log.*.gz
```

## Real-time Monitoring

```bash
# Follow log file
tail -f logs/app.log

# Follow with filtering
tail -f logs/app.log | grep --line-buffered -i error

# Multiple files
tail -f logs/*.log
```

## Output Template

```markdown
## Local Log Analysis

**Log file**: {path}
**Time range**: {start} to {end}
**Total entries**: {count}
**Error count**: {error_count}

### Error Summary

| Error Type | Count | First Seen | Last Seen |
|------------|-------|------------|-----------|
| {type} | {count} | {time} | {time} |

### Top Errors

#### 1. {Error message}
- **Frequency**: {count} occurrences
- **Pattern**: {when it happens}
- **Stack trace**:
```
{sanitized stack trace}
```
- **Affected code**: `{file}:{line}`
- **Potential cause**: {analysis}

### Recommendations

1. {Action item}
2. {Action item}

### Log Excerpts

```
{Relevant log entries}
```
```

## Integration with Monitoring

After log analysis:

1. **Set up alerts** for critical errors
2. **Add structured logging** if using plain text
3. **Configure log aggregation** (ELK, Loki, etc.)
4. **Add context** to log messages (request ID, user ID)
