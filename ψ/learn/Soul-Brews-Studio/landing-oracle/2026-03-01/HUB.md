# Landing Oracle — Discovery Hub

**Project:** Landing Oracle (Gallery site for Oracles)
**Organization:** Soul Brews Studio
**Stack:** Astro 5 + Cloudflare Workers
**Domain:** `gallery.buildwithoracle.com`
**Session Date:** 2026-03-01
**Agents:** 5 read-only explorers

---

## What is Landing Oracle?

A static gallery website showcasing individual Oracles. Displays oracle profiles with:
- Custom color palettes (primary, secondary, background)
- Hero screenshot images
- Status ("live" = published, "known" = hidden)
- Responsive gallery grid + dot visualization
- Theme switching system (3 themes, auto-rotating)

All data sourced from markdown files. No backend, no API, fully pre-rendered.

---

## Key Discovery: Screenshots

**Main Question:** How are screenshots implemented and managed?

### Answer: Manual Capture + Manual Commit

**Architecture:**
- Screenshot files stored in `public/screenshots/*.png` (17+ images)
- 16:10 aspect ratio (1280×800 recommended)
- Referenced in oracle markdown frontmatter: `screenshot: /screenshots/{name}.png`
- Displayed in GalleryCard component with lazy loading + async decoding
- Dot grid shows 180×120px thumbnail preview on hover

**Process:**
1. Developer navigates to Oracle landing page (browser)
2. Captures screenshot manually (Print-to-PDF, screenshot tool, or Playwright CLI)
3. Crops to hero/header area
4. Resizes to 16:10 aspect ratio
5. Saves PNG to `public/screenshots/`
6. Commits to git + deploys

**Automation Status:**
- ❌ No Playwright config in project
- ❌ No Puppeteer dependency
- ❌ No GitHub Actions workflow for automated capture
- ❌ No batch screenshot script
- ✅ Ad-hoc Playwright CLI works: `npx playwright screenshot --viewport-size="1280,800" URL output.png`

**This Session:** We demonstrated Playwright CLI as a one-off tool. Not part of regular workflow.

---

## Document Guide

### 1. **1307_ARCHITECTURE.md** — System Design
**Read this to understand how things fit together.**

Topics:
- Data model (oracle `.md` files + Zod schema)
- Component hierarchy (GalleryCard, main page, theme store)
- Content loading pipeline (markdown → validation → HTML)
- Deployment (Cloudflare Workers, static serving)
- Extension points (add new oracle via `.md` file)

Start here for high-level overview.

### 2. **1307_CODE-SNIPPETS.md** — Implementation Patterns
**Read this to see how to write code for this project.**

Topics:
- GalleryCard component (lazy loading, aspect ratio, hover effects)
- Content schema (Zod validation, field types)
- Theme system (nanostores, auto-rotation, localStorage)
- Dot grid preview (CSS custom properties, hover behavior)
- Content Collections setup (glob loader, getCollection API)

Useful when implementing features or fixing components.

### 3. **1307_QUICK-REFERENCE.md** — How-To Guide
**Read this to add an Oracle or work with screenshots.**

Topics:
- 5-step process to add new Oracle
- Screenshot capture methods (manual + Playwright CLI)
- Screenshot specs (16:10 aspect ratio, <400KB, PNG)
- File structure reference
- Frontmatter validation rules
- Troubleshooting common issues

Print this out if you're doing Oracle maintenance.

### 4. **1307_TESTING.md** — Quality & Automation
**Read this to understand quality gaps and testing needs.**

Topics:
- Critical finding: no screenshot automation exists
- Current state inventory (what's present, what's missing)
- Code quality: TypeScript strict + Zod validation (good)
- Test coverage: unit tests, e2e tests, linting (none)
- Recommended additions (script to validate screenshots, GitHub Actions CI)
- Manual pre-deploy checklist

Useful for improving build robustness and preventing regressions.

### 5. **1307_API-SURFACE.md** — Data & Integration
**Read this to understand how to query and extend the site.**

Topics:
- No backend API (fully static)
- Astro Content Collections as the "API layer"
- Data source: markdown files in `src/data/oracles/`
- Build-time transformations (validation, filtering, pre-rendering)
- Cloudflare Workers serving static files
- Extension patterns (add `.md` file or modify templates)

Useful when adding new data or creating custom queries.

---

## Quick Facts

| Question | Answer |
|----------|--------|
| **What's the tech stack?** | Astro 5 + CloudFlare Workers + Nanostores |
| **Where's the data?** | Markdown files in `src/data/oracles/` |
| **Is there a backend?** | No — fully static site |
| **How do screenshots work?** | Manual capture → `public/screenshots/` → frontmatter ref |
| **Can I automate screenshots?** | Not currently. Ad-hoc Playwright CLI works. No CI/CD integration. |
| **How many Oracles are in gallery?** | 17+ (across "live" and "known" statuses) |
| **How do themes work?** | 3 themes (clarity, royal, nature) auto-rotate every 6s, persist to localStorage |
| **Is the site cached?** | Yes — Cloudflare edge caching, long TTL for fingerprinted assets |
| **How do I deploy?** | `npm run build && wrangler deploy` |
| **What testing exists?** | TypeScript strict + Zod validation at build time. No unit/e2e tests. |

---

## File Map

```
landing-oracle/
├── src/
│   ├── data/oracles/          ← Oracle profile markdown files
│   ├── components/
│   │   └── GalleryCard.astro  ← Screenshot card component
│   ├── pages/
│   │   └── index.astro        ← Main gallery page
│   ├── stores/
│   │   └── theme.ts           ← Nanostores palette switching
│   ├── content/
│   │   └── config.ts          ← Content Collections setup
│   └── schemas.ts             ← Zod validation schemas
├── public/
│   └── screenshots/            ← PNG images (16:10 aspect ratio)
├── dist/                       ← Generated after build
├── astro.config.ts
├── tsconfig.json
└── wrangler.toml              ← CF Workers config
```

---

## How To Use These Docs

**Scenario: "I want to add a new Oracle"**
1. Read **QUICK-REFERENCE.md** (steps 1–5)
2. Reference **CODE-SNIPPETS.md** for frontmatter format
3. Use Playwright CLI from **TESTING.md** to capture screenshot

**Scenario: "I want to understand the code"**
1. Read **ARCHITECTURE.md** for high-level overview
2. Read **CODE-SNIPPETS.md** for detailed patterns
3. Read **API-SURFACE.md** to understand data flow

**Scenario: "I want to improve build robustness"**
1. Read **TESTING.md** (current gaps section)
2. Follow recommendations for screenshot validation + CI/CD
3. Implement suggested scripts

**Scenario: "I want to extend the gallery"**
1. Read **API-SURFACE.md** (extension points)
2. Modify `src/pages/index.astro` or create new templates
3. Use `getCollection("oracles")` to query data

---

## Critical Insights

### 1. Screenshot Reality
**Finding:** Landing-oracle has no automated screenshot pipeline. Screenshots are manually captured and committed to git.

**Implication:** Scaling to many Oracles requires documenting screenshot capture process (done in QUICK-REFERENCE.md) and providing tooling (Playwright CLI command in TESTING.md).

**Opportunity:** Add screenshot automation to CI/CD (GitHub Actions workflow + Playwright). See TESTING.md recommendations.

### 2. Static-First Architecture
**Finding:** All data is markdown files. All processing happens at build time. Zero runtime API.

**Implication:** Site is extremely fast (CF edge caching), requires rebuild to update data, and scales infinitely (no database limits).

**Opportunity:** Can add dynamic features (e.g., filter UI, sort options) via client-side JavaScript without touching backend.

### 3. Type Safety
**Finding:** TypeScript strict mode + Zod validation at build time. No runtime type checking needed.

**Implication:** Build failures catch schema violations early. Runtime is guaranteed type-safe.

**Opportunity:** Extend validation to check screenshot files exist, validate hex colors, enforce image dimensions.

---

## Session Summary

**Agents:** 5 read-only explorers simultaneously investigated codebase
**Duration:** ~45 minutes
**Coverage:** Architecture, components, data flow, screenshots, testing, API surface

**Key Deliverable:** Comprehensive screenshot discovery
- Manual capture process documented
- No CI/CD automation found
- Playwright CLI workaround provided
- Recommendations for future automation included

**Artifacts Created:**
- 1307_ARCHITECTURE.md (high-level design)
- 1307_CODE-SNIPPETS.md (implementation patterns)
- 1307_QUICK-REFERENCE.md (how-to guide)
- 1307_TESTING.md (quality gaps + recommendations)
- 1307_API-SURFACE.md (data layer + integration)
- HUB.md (this file — navigation + summary)

---

## Next Steps

### Immediate (If Adding Oracles)
- Use QUICK-REFERENCE.md to create new oracle
- Use Playwright CLI command from TESTING.md to capture screenshot
- Test locally with `npm run dev`
- Deploy with `wrangler deploy`

### Short-term (If Improving Robustness)
- Add screenshot validation script (from TESTING.md)
- Integrate into build pipeline
- Document in team wiki

### Medium-term (If Scaling)
- Implement GitHub Actions CI with Playwright automation
- Add unit tests for component logic
- Set up accessibility testing (WCAG contrast checks)
- Monitor CF analytics for performance

### Long-term (If Evolving)
- Consider adding search/filter UI
- Explore dynamic theme customization
- Add Oracle detail pages (currently just gallery)
- Integrate with main teaching platform

---

## Questions? Patterns Observed

**Q: Why no automated screenshots?**
A: Likely historical decision to keep deployment simple. Static `.png` files in git are reliable and require zero build orchestration.

**Q: What happens if a screenshot is missing?**
A: Component renders gracefully (shows colors only, no broken image). No build error. Risk: stale/incorrect oracle visual.

**Q: Can I customize the gallery layout?**
A: Yes — edit `src/pages/index.astro`. Data layer remains unchanged. All oracles automatically support layout changes.

**Q: Is there a way to add oracle-specific metadata (e.g., description, tags)?**
A: Yes — extend Zod schema in `src/schemas.ts` and markdown frontmatter. Astro Content Collections automatically validate new fields.

---

**Created:** 2026-03-01
**By:** 5 Read-Only Learning Agents + Analysis Framework
**For:** Nat + Two Rivers Oracle Teaching Mission
**Form:** Water Documentation — flows, layers, finds the path
