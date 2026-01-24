# Spec Compliance Strategy

Validates that implementation matches the design specification.

## Purpose

Ensures the code agent's output aligns with what was designed in `specs/`. This is the primary validation - did we build what was asked for?

## Inputs Required

- `SPEC_FILE`: Path to the spec in `specs/` directory
- `CHANGED_FILES`: List of files modified by the code agent
- `USER_PROMPT`: Original user request (for context)

## Workflow

### Step 1: Load the Spec

```
READ specs/{feature-name}.md

Extract:
- Problem statement / objectives
- Technical approach
- Implementation steps
- Success criteria
- Testing strategy
```

### Step 2: Map Spec to Implementation

For each implementation step in the spec:

```
SPEC_STEP: "Create UserController with GET /users endpoint"
EXPECTED_FILES: ["src/controllers/UserController.ts"]
EXPECTED_PATTERNS: ["@Controller", "@Get", "async", "return"]

CHECK:
- Does the file exist?
- Does it contain expected patterns?
- Does the implementation match the described approach?
```

### Step 3: Validate Success Criteria

For each success criterion in the spec:

```
CRITERION: "Endpoint returns paginated results"
VALIDATION:
- Look for pagination parameters (page, limit, offset)
- Check response structure includes pagination metadata
- Verify tests cover pagination
```

### Step 4: Check Completeness

```
SPEC_COMPONENTS = [list from spec]
IMPLEMENTED_COMPONENTS = [extracted from changed files]

MISSING = SPEC_COMPONENTS - IMPLEMENTED_COMPONENTS
EXTRA = IMPLEMENTED_COMPONENTS - SPEC_COMPONENTS (may be ok, flag for review)
```

## Output Format

```markdown
## Spec Compliance Report

### Spec: {spec filename}
### Implementation Status: {COMPLETE | PARTIAL | INCOMPLETE}

### Matched Requirements
✓ {requirement} → {file:line}
✓ {requirement} → {file:line}

### Missing Requirements
✗ {requirement} - Not implemented
✗ {requirement} - Partially implemented, missing {detail}

### Unspecified Additions
? {file} - Not in spec, review if intentional

### Success Criteria
| Criterion | Status | Evidence |
|-----------|--------|----------|
| {criterion} | ✓/✗ | {location or gap} |
```

## Enforcement

- **BLOCKING** if success criteria not met
- **BLOCKING** if required components missing
- **ADVISORY** for unspecified additions (may be valid)

## Example

```
Spec: specs/user-dashboard-chart.md
- Objective: Add revenue chart to dashboard
- Components: ChartComponent, useChartData hook, chart API endpoint

Changed Files:
- src/components/RevenueChart.tsx
- src/hooks/useRevenueData.ts
- src/api/charts.ts

Validation:
✓ ChartComponent → RevenueChart.tsx exists
✓ useChartData hook → useRevenueData.ts exists  
✓ API endpoint → charts.ts exists
✓ Uses recharts library as specified
✗ Missing: Loading state not implemented (spec section 3.2)

Status: PARTIAL - 1 blocking issue
```
