# Handoff: Index Landing Page Upgrade

**Date**: 2026-03-01 09:17
**From**: Two Rivers Oracle session — 14 PSRU simulators + index redesign

## What We Did
- Built 14 PSRU senior project simulator pages (6 parallel agents, ~11K lines)
- All deployed to GitHub Pages: https://soul-brews-studio.github.io/two-rivers-oracle/
- Updated index.html with "Senior Projects" section (14 cards)
- Converted Oracle sections (Morning Wave + Afternoon Wave) from tall cards to compact 3-col grid chips
- Researched Landing Oracle patterns for future index upgrade

## Pending
- [ ] `docs/index.html` has uncommitted changes (grid chip layout for oracles + senior projects)
- [ ] Landing page upgrade — current index is functional but basic compared to other Oracle landing pages

## Research Done: Landing Page Patterns
Studied 3 sources:
1. **Landing Oracle** (`soul-brews-studio/landing-oracle`) — Gallery with dot grid, glass morphism, scroll reveal
2. **buildwithoracle.com** — Hero section, install tabs, 2-path cards, philosophy grid, posts section
3. **Pattern Library** (`ψ/memory/learnings/2026-02-08_landing-page-patterns.md`) — Astro 5 + Tailwind 4 + CF Workers, glass nav, hero, sections

### Key patterns to adopt:
- **Hero section** with gradient text + tagline + CTA
- **Glass morphism** cards (blur + semi-transparent bg)
- **Scroll reveal** animations (IntersectionObserver)
- **Section borders** between groups
- **Philosophy section** (5 principles displayed as cards)
- **Responsive grid** that scales from mobile to desktop
- Keep it as **single HTML** (no build step) since it's GitHub Pages from `docs/`

### Current index structure:
- 5 sections, 50 cards total
- Workshop Materials (4 full cards)
- Live Data (7 full cards)
- Morning Wave (6 grid chips)
- Afternoon Wave (19 grid chips)
- Senior Projects (14 grid chips)

## Next Session
- [ ] Commit the grid chip changes to index.html
- [ ] Upgrade index.html with landing page patterns: hero section, glass cards, scroll reveal, better visual hierarchy
- [ ] Consider adding: Two Rivers identity section, philosophy cards, stats (25 oracles, 14 projects, etc.)
- [ ] Keep single-file HTML (no Astro build — this is GitHub Pages `docs/`)

## Key Files
- `docs/index.html` — main portal (modified, uncommitted)
- `ψ/memory/learnings/2026-02-08_landing-page-patterns.md` — Landing Oracle pattern library
- `Soul-Brews-Studio/landing-oracle/src/pages/index.astro` — Gallery + dot grid reference
- `laris-co/buildwithoracle/src/pages/index.astro` — Hero + 2-path cards reference
