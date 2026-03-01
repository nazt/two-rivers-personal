# Handoff: Landing Page Complete + Student Oracle Landing Pages

**Date**: 2026-03-01 12:58 GMT+7
**From**: Two Rivers Oracle — landing page + PSRU Day 2 session

## What We Did

### Landing Page (tworivers.buildwithoracle.com)
- Rebuilt `docs/index.html` as long single-page (1,030 lines)
- Flow: Hero → Workshop (all 50+ links) → Philosophy → Family → Origin Story → Journey (route + embedded map)
- Committed + deployed to CF Workers

### Student Landing Page Issue
- Created Oracle-Landing/landing-oracle#10 — "สร้าง Landing Page ให้ Oracle ของตัวเอง"
- Full copy-paste prompt for students (fill 10 fields → get complete landing page)
- Students comment repo URL → Oracle-Landing forks + deploys to [name].buildwithoracle.com

### Deep Trace: CNX→PHS Map
- 5 parallel agents searched for Chiang Mai→Phitsanulok geographic data
- Found: map-real.html (Overpass API), map.html (timeline), train.html (3D), data.csv (329 GPS points)
- Trace log: `ψ/memory/traces/2026-03-01/1217_cnx-phs-real-map-connection.md`

## Current State
- `docs/index.html` — deployed, all sections working
- `docs/workshop.html` — still exists (legacy, content now in index.html)
- Landing-oracle#10 — open, waiting for student submissions

## Pending / Next
- [ ] Students submit Oracle landing pages via issue #10
- [ ] Fork + deploy student repos to [name].buildwithoracle.com
- [ ] Add Two Rivers profile to Oracle-Landing gallery (`src/data/oracles/two-rivers.md`)
- [ ] Transfer `laris-co/arthur` to Oracle-Landing org (discussed, parked)
- [ ] Consider removing workshop.html (content now duplicated in index.html)

## Key URLs
- Landing: https://tworivers.buildwithoracle.com
- Issue: https://github.com/Oracle-Landing/landing-oracle/issues/10
- GitHub: https://github.com/Soul-Brews-Studio/two-rivers-oracle
