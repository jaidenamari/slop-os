# Zod Validation Pattern

All user inputs must be validated using Zod schemas before processing.

## When to Apply

- File patterns: `*Controller.ts`, `*Route.ts`, `*.api.ts`, `api/*.ts`
- Code signatures: `@Post`, `@Put`, `@Patch`, `@BodyParams`, `req.body`

## Required Elements

1. **Schema Definition** - Zod schema defined for request body/params
2. **Parse Call** - `schema.parse()` or `schema.safeParse()` before use
3. **Type Inference** - Use `z.infer<typeof Schema>` for TypeScript types
4. **Error Handling** - Catch ZodError and return appropriate response

## Anti-Patterns (Flag These)

- Using request body directly without validation
- Type assertions (`as SomeType`) instead of Zod parsing
- Validation only on frontend (must be on server)
- Partial validation (validating some fields, not all)
- Using `any` type for request data

## Example

```typescript
import { z } from 'zod';
import { Controller, Post, BodyParams } from '@tsed/common';

// Define schema
const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
  age: z.number().int().positive().optional(),
});

// Infer type from schema
type CreateUserInput = z.infer<typeof CreateUserSchema>;

@Controller('/users')
export class UserController {
  @Post('/')
  async createUser(@BodyParams() body: unknown) {
    // Validate input
    const validated = CreateUserSchema.parse(body);
    
    // Now `validated` is typed and safe to use
    return this.userService.create(validated);
  }
}
```

## With SafeParse (Recommended for Custom Error Handling)

```typescript
@Post('/')
async createUser(@BodyParams() body: unknown) {
  const result = CreateUserSchema.safeParse(body);
  
  if (!result.success) {
    // Custom error response
    return {
      success: false,
      errors: result.error.flatten().fieldErrors,
    };
  }
  
  return this.userService.create(result.data);
}
```

## Validation Checklist

- [ ] Zod schema exists for this endpoint's input
- [ ] Schema covers all expected fields
- [ ] `parse()` or `safeParse()` called before using data
- [ ] TypeScript type is inferred from schema (not manually defined)
- [ ] ZodError is handled appropriately
- [ ] Validation happens on server side

## Severity

- Missing validation entirely: **CRITICAL**
- Partial validation: **HIGH**
- Type not inferred from schema: **MEDIUM**
