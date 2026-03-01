# Landing Oracle — Testing & Quality Assurance

## Critical Finding: NO Automated Screenshot Pipeline

**Status:** ⚠️ No screenshot automation infrastructure exists in project

### Current State Inventory

| Tool | Present | Notes |
|------|---------|-------|
| Playwright config | ❌ No | No `.e2e.ts` or `playwright.config.ts` in repo |
| Playwright dependency | ❌ No | Not in `package.json` |
| Puppeteer | ❌ No | No alternative browser automation |
| GitHub Actions workflow | ❌ No | No `.github/workflows/*.yml` for screenshots |
| Batch screenshot script | ❌ No | No shell/Node scripts to automate capture |
| Screenshot CI/CD | ❌ No | Screenshots not automated in pipeline |

### Manual Workflow (Current)

1. Developer navigates to Oracle's landing page (browser)
2. Captures full screenshot (via Print-to-PDF, screenshot tool, etc.)
3. Manually crops to hero/header area
4. Resizes to 1280×800 (or compatible 16:10 ratio)
5. Saves as PNG to `public/screenshots/`
6. Commits file to git
7. Deploys via `npm run build && wrangler deploy`

### Ad-Hoc Tool: Playwright CLI

During this session, we used one-off Playwright commands:
```bash
npx playwright screenshot \
  --viewport-size="1280,720" \
  --wait-for-timeout=3000 \
  "https://oracle-landing-url.com" \
  output.png
```

**Status:** Ad-hoc workaround only — not integrated into project build
**Usage:** One oracle at a time
**Not configured:** No project-level config file

---

## Code Quality & Type Safety

### TypeScript Configuration
**Status:** ✅ Strict mode enabled
- `strict: true` in `tsconfig.json`
- Full type checking at compile time
- No implicit `any` types allowed

### Data Validation
**Status:** ✅ Zod schema validation at build time
- All oracle `.md` files validated against schema
- Build fails if data invalid (prevents stale screenshots, bad colors, etc.)
- Required fields enforced: name, status, primary, secondary, background

### Testing Coverage
**Status:** ❌ No unit tests
- No Jest, Vitest, or other test runner configured
- No test files in repository
- No test scripts in `package.json`

### Integration Testing
**Status:** ❌ No e2e tests
- No Playwright e2e suite
- No Cypress configuration
- No manual test plan documented

### Linting & Formatting
**Status:** ❌ No linting configured
- No ESLint setup
- No Prettier configuration
- No pre-commit hooks (no Husky)

---

## Build-Time Validation

### Content Collections Validation
```typescript
// Happens at npm run build
const allOracles = await getCollection("oracles");
// Each oracle.md checked against OracleSchema
// Build fails if any file violates schema
```

**What's Checked:**
- All required fields present
- Field types correct (string, enum)
- Status is "live" or "known"
- Hex colors valid format

**What's NOT Checked:**
- Screenshot file actually exists (no file system validation)
- Colors are readable/accessible
- Screenshot dimensions
- Image file size
- Duplicate oracle names

---

## Quality Gaps & Risks

### Screenshot Validation
- ❌ No automated check that screenshot exists
- ❌ No validation of image dimensions (should be 16:10)
- ❌ No file size checking (<400KB recommended)
- ❌ No freshness verification (screenshot might be outdated)

### Accessibility
- ❌ No color contrast checking (WCAG compliance)
- ❌ No alt-text validation on images
- ❌ No accessibility testing

### Performance
- ❌ No image optimization/compression pipeline
- ❌ No lighthouse CI checks
- ❌ No bundle size monitoring
- ❌ No Core Web Vitals measurement

### Data Consistency
- ❌ No check for orphaned screenshot files (unused images in public/)
- ❌ No check for broken screenshot paths in frontmatter
- ❌ No monitoring for stale oracle data

---

## Recommended Testing Additions

### 1. Screenshot File Validation (Quick Win)

Add Node script to `scripts/validate-screenshots.js`:
```javascript
import { glob } from "glob";
import fs from "fs";

const oracles = await glob("src/data/oracles/**/*.md");
const screenshotRefs = new Set();

for (const file of oracles) {
  const content = fs.readFileSync(file, "utf8");
  const match = content.match(/screenshot:\s*"([^"]+)"/);
  if (match) {
    screenshotRefs.add(match[1].replace(/^\//, "public/"));
  }
}

// Check files exist
for (const ref of screenshotRefs) {
  if (!fs.existsSync(ref)) {
    throw new Error(`Missing: ${ref}`);
  }
}

console.log(`✓ All ${screenshotRefs.size} screenshots present`);
```

Add to `package.json`:
```json
"scripts": {
  "validate": "node scripts/validate-screenshots.js",
  "build": "npm run validate && astro build"
}
```

### 2. Screenshot Automation (Future)

Create `scripts/capture-screenshots.mjs`:
```javascript
import playwright from "playwright";

const oracles = [
  { name: "two-rivers", url: "https://two-rivers-landing.com" },
  { name: "arthur", url: "https://arthur-landing.com" },
];

for (const oracle of oracles) {
  const browser = await playwright.chromium.launch();
  const page = await browser.newPage();
  await page.goto(oracle.url, { waitUntil: "networkidle" });
  await page.screenshot({
    path: `public/screenshots/${oracle.name}.png`,
    fullPage: true,
  });
  await browser.close();
}
```

Usage:
```bash
npm install playwright
node scripts/capture-screenshots.mjs
git add public/screenshots/
git commit -m "chore: update oracle screenshots"
```

### 3. GitHub Actions CI (Future)

Create `.github/workflows/validate.yml`:
```yaml
name: Validate
on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
      - run: npm ci
      - run: npm run validate
      - run: npm run build
```

---

## Current Testing Approach

### Manual Pre-Deploy Checklist
Before running `wrangler deploy`:

- [ ] All new `.md` files added to `src/data/oracles/`
- [ ] Required YAML frontmatter fields present
- [ ] Status field is "live" or "known" (exact match)
- [ ] Hex colors formatted correctly (#RRGGBB)
- [ ] Screenshot files exist in `public/screenshots/`
- [ ] Screenshot filenames match frontmatter paths
- [ ] Screenshot dimensions are 16:10 aspect ratio
- [ ] `npm run build` completes without errors
- [ ] Local `npm run dev` displays gallery correctly
- [ ] Theme switching works (3 themes rotate)
- [ ] Hover effects on cards function properly
- [ ] Dot grid preview appears on hover
- [ ] No console errors in browser DevTools

### Pre-Production Validation

**Desktop:**
- Chrome/Chromium (latest)
- Safari (latest)
- Firefox (latest)
- Mobile viewport (375px width)

**Checks:**
- Gallery cards display with correct colors
- Screenshots lazy-load without layout shift
- Theme switcher cycles through 3 themes
- Dot grid hovers show 180×120px preview

---

## Build Robustness

### Astro Build Process
- ✅ Type checking (TypeScript strict mode)
- ✅ Schema validation (Zod)
- ✅ Static HTML pre-rendering
- ✅ CSS bundling and minification
- ✅ Asset fingerprinting

### Edge Cases Currently Handled
- Missing `screenshot` field (marked optional, component handles gracefully)
- Invalid Zod schema (build fails with clear error)
- Type mismatches (TypeScript prevents at compile time)

### Edge Cases NOT Handled
- Missing screenshot file on disk
- Hex color invalid (not validated by Zod, only required to be string)
- Orphaned screenshots (images in `public/` not referenced anywhere)
- Duplicate oracle names (no uniqueness constraint)

---

## Deployment Safety

### Cloudflare Workers Serving
- ✅ All files pre-rendered as static HTML
- ✅ No runtime code execution
- ✅ No database queries
- ✅ CF edge caching enabled
- ✅ Instant rollback possible (previous `dist/` deployment)

### Risk Mitigation
- No code execution = no runtime bugs
- No database = no data corruption
- Pre-rendered = no build failures after deploy
- Static assets = highly cacheable, zero latency

---

## Monitoring Recommendations

### Cloudflare Analytics
- Monitor request count (should stay stable)
- Check cache hit ratio (should be >95%)
- Review error rates (should be ~0%)

### Manual Spot Checks (Weekly)
1. Load main gallery page
2. Verify all oracle cards load
3. Test theme switching
4. Check dot grid hover previews
5. Inspect browser console (no errors)

---

## Summary

| Aspect | Status | Risk |
|--------|--------|------|
| Type Safety | ✅ Strict TS | Low |
| Data Validation | ✅ Zod schema | Low |
| Screenshot Automation | ❌ None | Medium |
| Unit Tests | ❌ None | Low (static site) |
| E2E Tests | ❌ None | Low (simple layout) |
| Linting | ❌ None | Low |
| Pre-deploy Checklist | ✅ Manual | Medium |
| Accessibility Testing | ❌ None | Medium |

**Overall:** Build-time safety is strong (TypeScript + Zod). Runtime risk is low (static site). Main gap: no screenshot automation or accessibility validation.
