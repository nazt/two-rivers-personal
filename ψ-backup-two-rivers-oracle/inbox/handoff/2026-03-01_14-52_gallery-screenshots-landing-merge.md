# Handoff: Gallery Screenshots + Landing Page Merge

**Date**: 2026-03-01 14:52
**Context**: 85%

## What We Did

- **Captured 8 PSRU student landing page screenshots** — midnightmuse, sefer, soysajee, txur, pleumsomkiat, miku, blacksheep, suasaming
- **Scanned Oracle-Landing org + issue #10 comments** to find all PSRU students with live `*.buildwithoracle.com` landing pages (9 total)
- **Updated workshop.html** — swapped gradient placeholders for real screenshot cards, added LIVE badges, reordered LIVE first
- **Counted student work** — 47 portfolios, 96 HTML apps inside CV repos, 9 live landings, 14 senior projects = 166 total
- **Merged workshop gallery into main landing page** (index.html) — no more separate `/workshop` page needed
- **Merged Workshop Materials + Live Data into "Demo Apps (11)"** section
- **Split student oracles** — 9 LIVE landings as big gallery cards with screenshots, 17 without landing pages as small chips
- **Updated hero stats** on both pages: 47 portfolios · 96 student apps · 9 live landings · 14 senior projects · 166 total
- **Hero CTA buttons**: "เข้าสู่ Workshop" → `#workshop`, "Origin Story" → `#origin`

## Pending

- [ ] Commit + push all changes (docs/index.html, docs/workshop.html modified but not committed)
- [ ] workshop.html still exists — could redirect to `/` or keep as legacy URL
- [ ] workshop.html afternoon/morning wave still uses old separate sections (not merged like index.html)
- [ ] Some students may deploy more landing pages — will need screenshot updates

## Next Session

- [ ] Commit the current work: merged gallery, screenshots, stats
- [ ] Consider adding student CV/portfolio section with cards linking to their GitHub Pages
- [ ] Monitor Oracle-Landing/landing-oracle#10 for new student landing submissions
- [ ] Sync workshop.html layout with index.html (or remove workshop.html)

## Key Files

- `docs/index.html` — main landing page with merged gallery
- `docs/workshop.html` — legacy gallery page (still works but redundant)
- `docs/screenshots/*.png` — 20 screenshots (12 original + 8 new student landings)
