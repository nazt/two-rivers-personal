# Screenshot Pipeline is the Missing Automation

**Date**: 2026-03-01
**Source**: Deep learn of landing-oracle + visual gallery planning
**Confidence**: High (confirmed by 5 independent agents)

## Pattern

The Oracle ecosystem has solid automation for:
- **Deployment**: wrangler.json → `wrangler deploy` → custom subdomain
- **Gallery registration**: Add .md file with YAML frontmatter → Zod validates → Astro renders
- **Student onboarding**: Fork → wrangler.json → deploy → comment on issue

But **screenshot capture is entirely manual**:
- No Playwright config in landing-oracle
- No batch capture script
- No CI/CD workflow for screenshots
- Each screenshot is manually taken and git-committed

## One-liner that works

```bash
npx playwright screenshot --viewport-size="1280,720" --wait-for-timeout=3000 URL output.png
```

## What's needed

A reusable script that:
1. Reads all oracle .md files from `src/data/oracles/`
2. Extracts `domain` field from each
3. Batch captures screenshots with Playwright
4. Saves to `public/screenshots/{name}.png`
5. Optionally: only re-capture if page has changed (incremental)

## Vercel static deployment

When HTML lives in a subdirectory (e.g., `docs/`), Vercel needs:
```json
{ "outputDirectory": "docs" }
```
in `vercel.json` at repo root. Without this → 404.

## Tags
screenshot, playwright, automation, gallery, vercel, deployment
