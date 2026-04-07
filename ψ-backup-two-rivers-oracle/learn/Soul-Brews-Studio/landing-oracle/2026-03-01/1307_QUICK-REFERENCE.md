# Landing Oracle — Quick Reference

## Add a New Oracle to Gallery (5 Steps)

### 1. Create Oracle Profile
**File:** `src/data/oracles/{oracle-name}.md`

```yaml
---
name: "Your Oracle Name"
screenshot: "/screenshots/your-oracle-name.png"
status: "live"
primary: "#0F4C75"
secondary: "#3282B8"
background: "#E8F4F8"
---

Brief description of this Oracle...
```

**Required Fields:**
- `name` — Display name
- `status` — "live" (published) or "known" (hidden from main gallery)
- `primary` — Primary color (hex)
- `secondary` — Secondary color (hex)
- `background` — Background color (hex)

**Optional:**
- `screenshot` — Path to screenshot image (can add later)

### 2. Capture Screenshot

**Method: Playwright CLI (one-off)**
```bash
npx playwright screenshot \
  --viewport-size="1280,800" \
  --wait-for-timeout=3000 \
  "https://your-oracle-landing.com" \
  screenshot.png
```

**Manual Method:**
1. Open browser to Oracle's landing page
2. Take full-page screenshot (1280×800px or wider)
3. Crop to hero/header area only
4. Save as PNG

### 3. Screenshot Specifications

| Property | Requirement |
|----------|-------------|
| Aspect Ratio | 16:10 (1280×800, 1024×640, etc.) |
| Format | PNG (required) |
| File Size | <400KB recommended |
| Crop | Hero/header section only |
| Filename | `{oracle-name}.png` (lowercase, hyphens OK) |

### 4. Add Screenshot to Project

**Location:** `public/screenshots/{oracle-name}.png`

```bash
cp screenshot.png \
  public/screenshots/your-oracle-name.png
```

Update frontmatter in step 1 to match filename:
```yaml
screenshot: "/screenshots/your-oracle-name.png"
```

### 5. Build & Deploy

```bash
# Install dependencies (if needed)
npm install

# Build static site
npm run build

# Deploy to Cloudflare Workers
wrangler deploy
```

Site updates live at `gallery.buildwithoracle.com`

---

## How Screenshots Display

### Gallery Card View
- Full screenshot visible in card
- 16:10 aspect ratio maintained
- Lazy-loaded (only on viewport entry)
- Async image decode (non-blocking)
- Hover effect: blur + slight scale-up

### Dot Grid Preview
- 180×120px thumbnail on hover
- Shows on `.dot` elements
- Auto-generated from screenshot path
- Smooth fade-in on hover

---

## File Structure Reference

```
landing-oracle/
├── src/
│   ├── data/oracles/
│   │   ├── two-rivers.md
│   │   ├── arthur.md
│   │   └── ...
│   ├── components/
│   │   ├── GalleryCard.astro
│   │   └── ...
│   ├── pages/
│   │   └── index.astro
│   ├── stores/
│   │   └── theme.ts
│   └── styles/
├── public/
│   └── screenshots/
│       ├── two-rivers.png
│       ├── arthur.png
│       └── ...
├── dist/           (generated after build)
├── astro.config.ts
├── tsconfig.json
└── wrangler.toml
```

---

## Markdown Frontmatter Validation

Schema enforced at build time. Errors fail the build with clear messages.

**Valid Example:**
```yaml
---
name: "Echo"
screenshot: "/screenshots/echo.png"
status: "live"
primary: "#FF6B6B"
secondary: "#FFB3B3"
background: "#FFE5E5"
---
```

**Invalid Examples (will fail build):**
```yaml
status: "draft"  # ❌ Must be "live" or "known"
primary: "#invalid"  # ❌ Invalid hex color format
name: 123  # ❌ name must be string
```

---

## Important Notes

### No Automated Screenshots
- Landing-oracle has **no CI/CD screenshot automation**
- No Playwright config in project
- No GitHub Actions workflow for capture
- Screenshots are **manually captured and committed**
- Current approach: Use Playwright CLI as ad-hoc tool when needed

### Static Site Only
- No backend API
- No database
- All data in markdown files
- All processing at build time
- Fully pre-rendered HTML/CSS/JS

### Theme System
- Three themes: "clarity", "royal", "nature"
- Auto-rotates every 6 seconds (user can disable)
- Persists to localStorage
- Drives color palette across gallery

### Deployment
- Cloudflare Workers (static hosting)
- `dist/` directory served as-is
- CF edge caching enabled
- Domain: `gallery.buildwithoracle.com`

---

## Troubleshooting

**Build fails with schema error:**
- Check YAML frontmatter for typos
- Ensure all required fields present
- Verify hex colors are valid format (#RRGGBB)
- Status must be exactly "live" or "known"

**Screenshot not showing:**
- Verify path in frontmatter matches actual file in `public/screenshots/`
- Check file is PNG format
- Ensure no typos in filename
- Clear browser cache and rebuild

**Theme switching not working:**
- Check nanostores installation: `npm list nanostores`
- Verify localStorage not disabled in browser
- Check browser console for errors

**Deployment fails:**
- Ensure `wrangler.json` credentials configured
- Run `wrangler login` to re-authenticate
- Check CF account has active subscription
