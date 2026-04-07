# PSRU Workshop Summary — 28 February 2026

> "Water finds the way — two streams meet and the current deepens."

## Overview

**Event**: AI-Native Engineering Workshop
**Location**: มหาวิทยาลัยราชภัฏพิบูลสงคราม (PSRU), Phitsanulok
**Date**: 28 กุมภาพันธ์ 2569 (2026-02-28)
**Facilitated by**: Nat + Two Rivers Oracle (สองแคว)
**Travel**: Night train ขบวน 8, Chiang Mai → Phitsanulok (27-28 Feb)

## Stats

| Metric | Count |
|--------|-------|
| Oracles born (unique) | 20+ student Oracles |
| Birth issues created | 30+ (some retry attempts) |
| Retros posted on #229 | 10 student retrospectives |
| Comments on #229 | 17 |
| Git commits (Two Rivers) | 14 |
| GitHub Pages deployed | 6 pages |
| Workshop duration | Full day (08:47 — 14:22+) |

## Student Oracles — PSRU Wave

| Oracle | Human | Issue |
|--------|-------|-------|
| OS-1 (THE OMNISCIENT) | JONAT (@piyanat012) | #217 |
| BOB | ท่าน | #219 |
| Sukrit | admin00 | #220 |
| Portfolio Builder | Nat | #221 |
| B1 | ลูกพี่ | #223 |
| AI Spektrum | Peg | #224 |
| Lumina | อ.กนกพร | #226 |
| Antigravity | Perth + Bell + others | #230+ |
| Smile | sirilux014 | #235 |
| Gravity | Perth | #236 |
| Nano | ลิตเติ้ล (Little) | #237 |
| Soysajee | soysajee47 | #238 |
| Txur | tour4645 | #239 |
| เต๊ก | chaiyarit1024 | #241 |
| SEFER | FORDZAZA998 | #242 |
| กีกี้ (Kiki) | Kanyanat47 | #244 |
| Nadticha's | nadticha | #247 |
| Miku | TanMakoto | #251 |
| Aloy | Aloy | #257 |
| Durable Door | tonbun | #258 |

## Deliverables

### Live Site: soul-brews-studio.github.io/two-rivers-oracle/

1. **index.html** — Workshop landing page with all materials + Oracle links
2. **train.html** — 3D train visualization (Three.js, 4 camera modes, daytime)
3. **map.html** — GPS timeline map (Leaflet, 34 waypoints, interactive)
4. **map-real.html** — Real GIS map (province boundaries, rivers, railway from OSM)
5. **guide.html** — GitHub Pages 4-step guide for students
6. **data.csv** — Public GPS data (328 rows, anonymized)

### Workshop Materials (ψ/lab/)
- speak.sh — TTS helper script
- guide.html — GitHub Pages creation guide
- travel-3d.html — 3D train source (synced to daytime)
- travel-map.html — 2D map source
- travel-cnx-phs.csv — Cleaned GPS data

## Timeline

| Time | Event |
|------|-------|
| 06:00 (27 Feb) | Depart Chiang Mai by train |
| 16:23 (27 Feb) | Arrive PSRU |
| 08:47 (28 Feb) | Two Rivers Oracle born (สองแคว) |
| 09:01 | Workshop begins — GitHub Pages + Oracle creation |
| ~10:00-12:00 | Students create Oracles, build portfolios |
| 12:11 | 7+ Oracles born by midday |
| 13:00 | 3D train visualization built |
| 14:00+ | More Oracles born, retros posted, GitHub Pages deployed |
| End of day | 20+ Oracles, 10+ retros, site live |

## Technical Stack

- **Leaflet.js** — Interactive maps
- **Three.js** — 3D visualization
- **GitHub Pages** — Free hosting
- **Overpass API** — Real OpenStreetMap data (rivers, railway)
- **geoBoundaries** — Province boundary GeoJSON
- **edge-tts** — Thai text-to-speech (PremwadeeNeural)

## Data Sources (GIS)

- **Provinces**: geoBoundaries ADM1 simplified GeoJSON
- **Rivers**: Overpass API — แม่น้ำน่าน (Nan) + แม่น้ำแควน้อย (Kwae Noi)
- **Railway**: Overpass API — Northern Line (Chiang Mai → Phitsanulok)
- **GPS**: FindMy device tracking (anonymized)

## Key Learnings

1. Students quickly grasped Oracle creation — several created Oracles within the first hour
2. GitHub Pages deployment was straightforward — 4-step guide worked well
3. Antigravity (Perth) showed persistence — 6+ attempts to get the Oracle right
4. Mix of Thai and English names for Oracles shows bilingual comfort
5. Real GIS data makes visualizations more engaging and educational
6. The "night train" narrative anchored the whole workshop experience

## Links

- **Repo**: github.com/Soul-Brews-Studio/two-rivers-oracle (public)
- **Issue #229**: PSRU Wave gathering
- **Issue #60**: Oracle Family Registry
- **Issue #214**: Two Rivers birth announcement
