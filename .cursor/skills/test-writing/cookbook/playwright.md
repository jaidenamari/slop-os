# Playwright E2E Testing Cookbook

Patterns and conventions for Playwright end-to-end tests.

## Detection

Project uses Playwright if:
- `@playwright/test` in package.json devDependencies
- `playwright.config.ts` exists
- Test files in `tests/` or `e2e/` with `.spec.ts` extension

## Configuration

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

## Commands

```bash
# Run all tests
npx playwright test

# Run specific file
npx playwright test login.spec.ts

# Run tests with UI
npx playwright test --ui

# Run in headed mode
npx playwright test --headed

# Run specific project/browser
npx playwright test --project=chromium

# Debug mode
npx playwright test --debug

# Generate tests (codegen)
npx playwright codegen http://localhost:3000

# Show report
npx playwright show-report
```

## Test File Structure

```typescript
import { test, expect } from '@playwright/test';

test.describe('Login Flow', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login');
  });

  test('should login with valid credentials', async ({ page }) => {
    // Fill form
    await page.fill('[data-testid="email"]', 'user@example.com');
    await page.fill('[data-testid="password"]', 'password123');
    
    // Submit
    await page.click('[data-testid="submit"]');
    
    // Assert redirect
    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('h1')).toContainText('Welcome');
  });

  test('should show error for invalid credentials', async ({ page }) => {
    await page.fill('[data-testid="email"]', 'user@example.com');
    await page.fill('[data-testid="password"]', 'wrong');
    await page.click('[data-testid="submit"]');
    
    await expect(page.locator('[data-testid="error"]')).toBeVisible();
    await expect(page.locator('[data-testid="error"]')).toContainText('Invalid');
  });
});
```

## Locator Strategies

```typescript
// By test ID (recommended)
page.locator('[data-testid="submit"]')
page.getByTestId('submit')

// By role (accessibility)
page.getByRole('button', { name: 'Submit' })
page.getByRole('textbox', { name: 'Email' })
page.getByRole('link', { name: 'Sign up' })

// By text
page.getByText('Welcome')
page.getByText(/welcome/i)

// By label
page.getByLabel('Email')
page.getByPlaceholder('Enter email')

// By CSS
page.locator('.submit-btn')
page.locator('#email-input')

// Chaining
page.locator('.form').locator('button')
page.locator('.card').filter({ hasText: 'Active' })
```

## Actions

```typescript
// Click
await page.click('button');
await page.locator('button').click();
await page.getByRole('button').click();

// Fill (clears first)
await page.fill('input', 'text');
await page.locator('input').fill('text');

// Type (keystroke by keystroke)
await page.type('input', 'text');

// Select dropdown
await page.selectOption('select', 'value');
await page.selectOption('select', { label: 'Option' });

// Check/uncheck
await page.check('input[type="checkbox"]');
await page.uncheck('input[type="checkbox"]');

// Hover
await page.hover('.menu');

// Upload file
await page.setInputFiles('input[type="file"]', 'path/to/file.pdf');

// Press key
await page.press('input', 'Enter');
await page.keyboard.press('Escape');
```

## Assertions

```typescript
// Page
await expect(page).toHaveURL('/dashboard');
await expect(page).toHaveTitle('Dashboard');

// Locator visibility
await expect(locator).toBeVisible();
await expect(locator).toBeHidden();
await expect(locator).toBeEnabled();
await expect(locator).toBeDisabled();

// Locator content
await expect(locator).toHaveText('Hello');
await expect(locator).toContainText('Hello');
await expect(locator).toHaveValue('input value');

// Locator attributes
await expect(locator).toHaveAttribute('href', '/link');
await expect(locator).toHaveClass(/active/);
await expect(locator).toHaveCSS('color', 'rgb(0, 0, 0)');

// Count
await expect(locator).toHaveCount(5);

// Attached/detached
await expect(locator).toBeAttached();
await expect(locator).not.toBeAttached();

// Soft assertions (continue on failure)
await expect.soft(locator).toHaveText('text');
```

## Waiting

```typescript
// Wait for element
await page.waitForSelector('.loading', { state: 'hidden' });
await page.waitForSelector('.content', { state: 'visible' });

// Wait for navigation
await page.waitForURL('/dashboard');
await page.waitForLoadState('networkidle');

// Wait for response
await page.waitForResponse('/api/users');
await page.waitForResponse(resp => resp.url().includes('/api'));

// Wait for function
await page.waitForFunction(() => document.querySelector('.loaded'));

// Explicit timeout
await page.locator('button').click({ timeout: 5000 });
```

## Page Object Model

```typescript
// pages/LoginPage.ts
import { Page, Locator } from '@playwright/test';

export class LoginPage {
  readonly page: Page;
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;

  constructor(page: Page) {
    this.page = page;
    this.emailInput = page.getByTestId('email');
    this.passwordInput = page.getByTestId('password');
    this.submitButton = page.getByRole('button', { name: 'Login' });
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }
}

// tests/login.spec.ts
import { LoginPage } from '../pages/LoginPage';

test('login flow', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.goto();
  await loginPage.login('user@example.com', 'password');
  await expect(page).toHaveURL('/dashboard');
});
```

## Fixtures

```typescript
// fixtures.ts
import { test as base } from '@playwright/test';
import { LoginPage } from './pages/LoginPage';

type Fixtures = {
  loginPage: LoginPage;
  authenticatedPage: Page;
};

export const test = base.extend<Fixtures>({
  loginPage: async ({ page }, use) => {
    const loginPage = new LoginPage(page);
    await use(loginPage);
  },
  
  authenticatedPage: async ({ page }, use) => {
    await page.goto('/login');
    await page.fill('[data-testid="email"]', 'user@example.com');
    await page.fill('[data-testid="password"]', 'password');
    await page.click('button[type="submit"]');
    await page.waitForURL('/dashboard');
    await use(page);
  },
});

// Use in tests
test('dashboard', async ({ authenticatedPage }) => {
  await expect(authenticatedPage.locator('h1')).toContainText('Dashboard');
});
```

## API Testing

```typescript
import { test, expect } from '@playwright/test';

test('API test', async ({ request }) => {
  // GET
  const response = await request.get('/api/users');
  expect(response.ok()).toBeTruthy();
  
  const users = await response.json();
  expect(users).toHaveLength(10);
  
  // POST
  const createResponse = await request.post('/api/users', {
    data: { name: 'John', email: 'john@example.com' },
  });
  expect(createResponse.status()).toBe(201);
});
```

## Visual Testing

```typescript
test('visual comparison', async ({ page }) => {
  await page.goto('/dashboard');
  
  // Full page
  await expect(page).toHaveScreenshot('dashboard.png');
  
  // Element
  await expect(page.locator('.header')).toHaveScreenshot('header.png');
  
  // With options
  await expect(page).toHaveScreenshot({
    maxDiffPixels: 100,
    threshold: 0.2,
  });
});

// Update screenshots: npx playwright test --update-snapshots
```

## Troubleshooting

### Element not found
- Use `--debug` to step through
- Check selector is correct
- Add explicit waits if dynamic content

### Flaky tests
- Avoid fixed timeouts (`page.waitForTimeout`)
- Use proper waits (`waitForSelector`, `waitForLoadState`)
- Check for race conditions

### Tests pass locally, fail in CI
- Check `webServer` configuration
- Verify base URL
- Check for environment differences
- Use `retries` in CI

### Generate tests automatically
```bash
npx playwright codegen http://localhost:3000
```
