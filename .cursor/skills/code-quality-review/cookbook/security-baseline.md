# Security Baseline Strategy

Performs essential security checks on code changes.

## Purpose

Catches common security issues before they reach production. This is not a full security audit - use the `@adversary` agent for rigorous security review. This strategy covers the baseline that should always pass.

## Inputs Required

- `CHANGED_FILES`: Files to scan
- `FILE_TYPES`: Categorized by type (API, frontend, config, etc.)

## Workflow

### Step 1: Categorize Files by Risk

```
HIGH_RISK (always scan thoroughly):
- API endpoints / controllers
- Authentication / authorization code
- Database queries
- File system operations
- Configuration files

MEDIUM_RISK:
- Business logic services
- Data transformation
- External API clients

LOW_RISK:
- UI components (unless handling sensitive data)
- Utility functions
- Tests
```

### Step 2: Secret Detection

Scan for accidentally committed secrets:

```
PATTERNS:
- API keys: /[a-zA-Z0-9_-]{20,40}/
- AWS keys: /AKIA[0-9A-Z]{16}/
- Private keys: /-----BEGIN.*PRIVATE KEY-----/
- Passwords: /password\s*[:=]\s*['"][^'"]+['"]/i
- Connection strings with credentials
- JWT secrets
- OAuth tokens

EXCEPTIONS:
- Test fixtures with fake values
- Environment variable references (process.env.*)
- Placeholder patterns (YOUR_API_KEY_HERE)
```

### Step 3: Input Validation

For API handlers and data processing:

```
CHECK:
1. All user inputs validated before use
2. Validation on server side (not just client)
3. Using Zod/Pydantic for schema validation
4. File uploads validated (type, size)
5. Query parameters sanitized
```

### Step 4: Injection Prevention

```
SQL_INJECTION:
- No string concatenation in queries
- Using parameterized queries or ORM
- No raw SQL with user input

COMMAND_INJECTION:
- No exec/spawn with user input
- Whitelisted commands only
- No shell interpolation

XSS:
- No innerHTML with user content
- No dangerouslySetInnerHTML without sanitization
- Proper output encoding

PATH_TRAVERSAL:
- User input not used directly in file paths
- Path normalization applied
- Directory restricted access
```

### Step 5: Authentication & Authorization

```
CHECK:
- Sensitive endpoints require authentication
- Authorization checks before data access
- No predictable identifiers for access control
- Session management secure
- Password handling uses proper hashing
```

### Step 6: Dependency Check

```
# Check for known vulnerabilities
bun audit (or npm audit)
uv pip audit (for Python)

FLAG:
- Critical CVEs: BLOCKING
- High CVEs: BLOCKING
- Moderate CVEs: ADVISORY
```

## Output Format

```markdown
## Security Baseline Report

### Risk Summary
- High-risk files scanned: {count}
- Issues found: {critical} critical, {high} high

### Secret Detection
| Status | Details |
|--------|---------|
| {✓/✗} | No hardcoded secrets detected / {count} potential secrets |

### Input Validation
| Endpoint/Handler | Status | Issue |
|------------------|--------|-------|
| POST /users | ✗ | Missing Zod validation |
| GET /orders/:id | ✓ | ID validated |

### Injection Prevention
| Type | Status | Location |
|------|--------|----------|
| SQL | ✓ | Using ORM |
| XSS | ✗ | {file}:{line} - innerHTML usage |
| Command | ✓ | No shell commands |

### Auth/Authz
| Check | Status |
|-------|--------|
| Endpoints protected | ✓/✗ |
| Access control | ✓/✗ |

### Dependencies
| Package | Severity | CVE |
|---------|----------|-----|
| {package} | {severity} | {CVE-ID} |
```

## Enforcement

- **BLOCKING** if secrets detected
- **BLOCKING** if injection vulnerability found
- **BLOCKING** if auth missing on sensitive endpoint
- **BLOCKING** if critical/high CVE in dependencies
- **ADVISORY** for medium-severity issues

## When to Escalate to Adversary

Invoke `@adversary` for deep security review when:

1. Auth/authz code is modified
2. New API endpoints handling sensitive data
3. Cryptographic operations added
4. Payment or PII processing
5. File upload/download functionality
6. Any code flagged as suspicious but unclear

```
ESCALATION_TRIGGER:
If (auth_code_changed OR sensitive_data_handling OR crypto_operations):
    RECOMMEND: "Run deep review with @adversary for security validation"
```

## Example

```
Files: 
- src/controllers/PaymentController.ts (HIGH_RISK)
- src/services/PaymentService.ts (HIGH_RISK)
- src/components/PaymentForm.tsx (MEDIUM_RISK)

Secret Detection: ✓ PASS
- No hardcoded secrets

Input Validation: ✗ FAIL
- PaymentController.ts:34 - Missing card number validation
- PaymentController.ts:56 - Amount not validated as positive number

Injection: ✓ PASS
- Using ORM for all queries
- No shell commands

Auth: ✓ PASS  
- All endpoints require authentication
- User can only access own payment methods

Dependencies: ✓ PASS
- No known vulnerabilities

ESCALATION RECOMMENDED:
Payment processing code modified - recommend @adversary deep review

Status: 1 BLOCKING (missing validation), 1 ESCALATION
```
