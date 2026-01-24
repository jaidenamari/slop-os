# Repository Pattern

Data access is abstracted through repository classes that handle persistence operations.

## When to Apply

- File patterns: `*Repository.ts`, `*.repository.ts`, `*Repo.ts`
- Any code performing database operations
- Service classes that need data access

## Required Elements

1. **Repository Class** - Dedicated class for each entity/aggregate
2. **Interface Abstraction** - Repository implements an interface
3. **Single Responsibility** - Only data access, no business logic
4. **Injected into Services** - Services depend on repository interface

## Anti-Patterns (Flag These)

- Database queries directly in controllers
- Business logic in repository methods
- Services directly using ORM/query builder
- Repository depending on services (circular)
- Raw SQL in application code (outside repository)

## Layer Boundaries

```
Controller → Service → Repository → Database
     ↓           ↓           ↓
  HTTP      Business     Data Access
  concerns   logic        only
```

## Example

```typescript
// Repository interface
interface IUserRepository {
  findById(id: string): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
  create(data: CreateUserData): Promise<User>;
  update(id: string, data: UpdateUserData): Promise<User>;
  delete(id: string): Promise<void>;
}

// Repository implementation
@Injectable()
class UserRepository implements IUserRepository {
  constructor(
    @InjectRepository(UserEntity)
    private readonly repo: Repository<UserEntity>
  ) {}

  async findById(id: string): Promise<User | null> {
    const entity = await this.repo.findOne({ where: { id } });
    return entity ? this.toDomain(entity) : null;
  }

  async findByEmail(email: string): Promise<User | null> {
    const entity = await this.repo.findOne({ where: { email } });
    return entity ? this.toDomain(entity) : null;
  }

  async create(data: CreateUserData): Promise<User> {
    const entity = this.repo.create(data);
    await this.repo.save(entity);
    return this.toDomain(entity);
  }

  private toDomain(entity: UserEntity): User {
    // Map entity to domain model
    return new User(entity.id, entity.email, entity.name);
  }
}

// Service uses repository (not ORM directly)
@Injectable()
class UserService {
  constructor(
    private readonly userRepo: IUserRepository
  ) {}

  async createUser(input: CreateUserInput): Promise<Result<User, UserError>> {
    // Business logic here
    const existing = await this.userRepo.findByEmail(input.email);
    if (existing) {
      return { success: false, error: { code: 'DUPLICATE_EMAIL' } };
    }
    
    const user = await this.userRepo.create(input);
    return { success: true, data: user };
  }
}

// Controller uses service (not repository directly)
@Controller('/users')
class UserController {
  constructor(private readonly userService: UserService) {}

  @Post('/')
  async createUser(@BodyParams() body: unknown) {
    const validated = CreateUserSchema.parse(body);
    const result = await this.userService.createUser(validated);
    // Handle result...
  }
}
```

## What Belongs Where

| Layer | Belongs | Does NOT Belong |
|-------|---------|-----------------|
| Controller | Request/response handling, validation, routing | Business logic, direct DB access |
| Service | Business logic, orchestration, transactions | HTTP concerns, raw queries |
| Repository | CRUD operations, query building, data mapping | Business rules, HTTP handling |

## Validation Checklist

- [ ] Database operations only in repository classes
- [ ] Controllers do not access repositories directly
- [ ] Services use repository interface (dependency injection)
- [ ] No business logic in repository methods
- [ ] Repository methods return domain models (not entities)

## Severity

- Controller accessing database directly: **CRITICAL**
- Service using ORM directly (bypassing repository): **HIGH**
- Business logic in repository: **MEDIUM**
- Missing interface abstraction: **LOW**
