# Landing Oracle — Architecture Overview

## Project Type
Astro 5 + Cloudflare Workers static gallery site
Deployed to: `gallery.buildwithoracle.com`

## Core Data Model

### Oracle Profiles
- Location: `src/data/oracles/*.md`
- Format: Markdown with YAML frontmatter
- Validation: Zod schema at build time via Content Collections

**Frontmatter Fields:**
```yaml
name: String (required)
screenshot: String (optional, path to /public/screenshots/{name}.png)
status: Enum (required) — "live" | "known"
primary: String (required) — hex color
secondary: String (required) — hex color
background: String (required) — hex color
```

Example:
```yaml
---
name: "Two Rivers"
screenshot: "/screenshots/two-rivers.png"
status: "live"
primary: "#0F4C75"
secondary: "#3282B8"
background: "#E8F4F8"
---
```

## Component Architecture

### Gallery Card Component
**File:** `src/components/GalleryCard.astro`

Renders individual oracle profile card:
- Screenshot image with 16:10 aspect ratio
- Lazy loading enabled (`loading="lazy"`)
- Async decoding (`decoding="async"`)
- Image positioning: `object-cover object-top`
- Hover effect: backdrop blur + scale-105 transform
- Fallback: Shows color palette if no screenshot

### Main Page Layout
**File:** `src/pages/index.astro`

Structure:
1. Hero section
2. Gallery grid (responsive, column-based layout)
3. Dot visualization — Preview grid with hover screenshot display
4. How-it-works section
5. Footer

**Dot Grid Behavior:**
- CSS custom property: `--preview-img` set per oracle
- Hover triggers 180x120px screenshot preview
- Connected to theme switching system

### Theme System
**File:** `src/stores/theme.ts`

Technology: Nanostores (lightweight state management)

**Atoms:**
- `$palette` — current theme state
- `$rotating` — auto-rotate flag

**Behavior:**
- Three themes: "clarity", "royal", "nature"
- Auto-rotation enabled: cycles every 6 seconds
- Persistence: localStorage saves user preference
- Palette colors drive gallery card styling

## Content Loading Pipeline

```
src/data/oracles/*.md files
    ↓
Content Collections glob loader
    ↓
Zod schema validation
    ↓
getCollection("oracles") API
    ↓
Filter by status ("live" | "known")
    ↓
Pass to GalleryCard component
    ↓
Static HTML generation (Astro build)
    ↓
dist/ directory (ready for CF Workers)
```

**Key Point:** All data gathering happens at build time. No runtime data fetching.

## Static Assets

### Screenshots
- Location: `public/screenshots/`
- Format: PNG (required)
- Aspect ratio: 16:10
- Recommended size: <400KB
- Count: 17+ images currently
- Sourced: Manual capture (no automated pipeline)

### Build Output
- Location: `dist/`
- Type: Pre-rendered static HTML + CSS + JS
- Served by: Cloudflare Workers
- Cache: CF edge caching enabled

## Deployment

**Build:**
```bash
npm run build  # generates dist/ with all static files
```

**Deployment:**
```bash
wrangler deploy  # publishes to CF Workers
```

**Configuration:** `wrangler.toml`
- Entry point: `dist/` directory (static asset hosting)
- Routing: `*.buildwithoracle.com/*` → static files
- No backend API routes (purely static)

## Key Architectural Decisions

1. **No Runtime API:** All data is markdown files, validated at build time
2. **Static-First:** Full site can be cached indefinitely at CF edge
3. **Type Safety:** Zod schema enforces oracle data structure
4. **Lazy Loading:** Screenshot images load only when visible
5. **Theme System:** Global state for consistent palette switching
6. **Manual Screenshots:** No CI/CD automation for capture — current workflow is manual

## Extension Points

To add a new Oracle to gallery:
1. Create `.md` file in `src/data/oracles/`
2. Include required frontmatter (name, colors, status)
3. Add screenshot to `public/screenshots/`
4. Set `screenshot` path in frontmatter
5. Rebuild and deploy

No code changes required — data-driven system.
