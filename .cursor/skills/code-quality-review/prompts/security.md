# Security Review Prompts

Structured prompts for security-focused code analysis.

---

## Prompt 1: Input Validation Audit

```
Analyze the following code for input validation vulnerabilities.

CODE:
{file_content}

CHECKLIST:
1. Are all user inputs validated before use?
2. Is validation done on the server side (not just client)?
3. Are there length limits on string inputs?
4. Are numeric inputs bounded?
5. Are file uploads validated for type and size?

For each violation found, output:
- Line number
- Vulnerability type
- Risk level (Critical/High/Medium)
- Remediation suggestion
```

---

## Prompt 2: Authentication & Authorization

```
Review this code for authentication and authorization issues.

CODE:
{file_content}

CHECK FOR:
1. Missing authentication on sensitive endpoints
2. Broken access control (can users access other users' data?)
3. Session management issues
4. JWT validation problems
5. Password handling (hashing, storage, comparison)

Flag any endpoint or function that:
- Handles user data without auth check
- Uses predictable identifiers for access control
- Stores or logs sensitive credentials
```

---

## Prompt 3: Injection Vulnerability Scan

```
Scan this code for injection vulnerabilities.

CODE:
{file_content}

INJECTION TYPES:
1. SQL Injection
   - Look for: string concatenation in queries
   - Safe: parameterized queries, ORM methods

2. Command Injection
   - Look for: exec(), spawn(), system() with user input
   - Safe: whitelisted commands, no shell interpolation

3. XSS (Cross-Site Scripting)
   - Look for: innerHTML, dangerouslySetInnerHTML, unescaped output
   - Safe: textContent, proper escaping, CSP headers

4. Path Traversal
   - Look for: user input in file paths
   - Safe: path.resolve() + validation, whitelist directories

5. LDAP/XML/NoSQL Injection
   - Look for: dynamic query construction
   - Safe: parameterized queries, schema validation

For each finding:
SEVERITY: {Critical|High|Medium}
LINE: {number}
TYPE: {injection type}
VULNERABLE CODE: {snippet}
SAFE ALTERNATIVE: {remediation}
```

---

## Prompt 4: Secrets & Sensitive Data

```
Scan for exposed secrets and sensitive data handling issues.

CODE:
{file_content}

SECRETS PATTERNS:
- API keys: /[a-zA-Z0-9_-]{20,}/
- AWS keys: /AKIA[0-9A-Z]{16}/
- Private keys: /-----BEGIN.*PRIVATE KEY-----/
- Passwords: /password\s*[:=]\s*['"][^'"]+['"]/i
- Connection strings: /mongodb\+srv:\/\/|postgres:\/\/|mysql:\/\//

DATA HANDLING:
1. Is sensitive data encrypted at rest?
2. Is PII logged or exposed in errors?
3. Are secrets loaded from environment, not hardcoded?
4. Is sensitive data properly masked in logs?

OUTPUT FORMAT:
SECRET_FOUND: {yes/no}
LINE: {number if found}
TYPE: {secret type}
RISK: {exposure impact}
REMEDIATION: {how to fix}
```

---

## Prompt 5: Cryptography Review

```
Review cryptographic implementations.

CODE:
{file_content}

ANTI-PATTERNS TO FLAG:
- MD5 or SHA1 for passwords (use bcrypt/argon2)
- ECB mode encryption (use GCM or CBC with proper IV)
- Hardcoded encryption keys
- Weak random number generation (Math.random for security)
- Missing salt in password hashing
- Short key lengths (<256 bits for symmetric, <2048 for RSA)

VERIFY:
1. TLS/SSL configured correctly
2. Certificate validation enabled
3. Secure cipher suites only
4. No downgrade attack vectors
```

---

## Prompt 6: Dependency Security

```
Analyze dependencies for security concerns.

DEPENDENCY LIST:
{dependencies}

CHECK:
1. Are there known CVEs for these versions?
2. Are dependencies pinned to exact versions?
3. Are there unmaintained packages (>2 years no update)?
4. Are there packages with concerning permission requests?

FLAG:
- Critical CVEs: Must upgrade before deploy
- High CVEs: Upgrade within sprint
- Unmaintained: Plan migration
```

---

## Composite Security Report Template

```markdown
# Security Analysis Report

## Scan Summary
- **Files Scanned**: {count}
- **Critical Findings**: {count}
- **High Findings**: {count}
- **Medium Findings**: {count}

## Critical Issues (Block Deployment)
{findings}

## High Priority (Fix Before Release)
{findings}

## Medium Priority (Fix Soon)
{findings}

## Passing Checks
- [ ] No hardcoded secrets
- [ ] Input validation present
- [ ] Parameterized queries used
- [ ] Authentication on sensitive routes
- [ ] Dependencies up to date

## Recommendations
{prioritized action items}
```
