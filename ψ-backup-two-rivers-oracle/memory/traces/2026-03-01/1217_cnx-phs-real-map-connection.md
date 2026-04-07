---
query: "chiang mai phitsanulok real map connection cnx"
target: "two-rivers-oracle"
mode: deep
timestamp: 2026-03-01 12:17
---

# Trace: Chiang Mai → Phitsanulok Real Map Connection

**Target**: two-rivers-oracle
**Mode**: deep (5 parallel agents)
**Time**: 2026-03-01 12:17 GMT+7

## Oracle Results

- **สองแคว naming resonance** — "Born on a train from Chiang Mai, arrived at the university, named from the land itself"
- **Train journey retro** — Feb 27 session: Chiang Mai Station → Train #8 → Phitsanulok
- **Confluence geography** — พิษณุโลก is เมืองสองแคว — แม่น้ำน่าน + แม่น้ำแควน้อย

## Files Found

| File | Lines | Content |
|------|-------|---------|
| `docs/map-real.html` | ~340 | Full GIS map — province boundaries, rivers, railway, 34 GPS waypoints |
| `docs/map.html` | ~250 | Travel timeline — Leaflet.js interactive map |
| `docs/train.html` | ~400 | Three.js 3D train visualization |
| `docs/data.csv` | 329 | GPS coordinates from actual journey |
| `ψ/lab/github-pages-workshop/travel-cnx-phs.csv` | 328 | Same GPS data (workshop copy) |
| `ψ/lab/github-pages-workshop/WORKSHOP-MAP-PROMPT.md` | ~50 | Student prompt for creating maps |
| `ψ/lab/github-pages-workshop/travel-map.html` | ~200 | Working example map |
| `ψ/lab/github-pages-workshop/travel-3d.html` | ~300 | Working example 3D train |

## Key Geographic Data

### Route: 6 Provinces, ~300 km
Chiang Mai → Lamphun → Lampang → Phrae → Uttaradit → **Phitsanulok**

### Critical Coordinates
- **Start**: สถานีรถไฟเชียงใหม่ [18.7513, 98.9856]
- **End**: PSRU [16.8349, 100.2588]
- **Confluence (สองแคว)**: [16.824, 100.260] — แม่น้ำน่าน + แควน้อย

### Data Sources in map-real.html
- Province GeoJSON: `apisit/thailand.json` (geoBoundaries)
- Rivers: Overpass API — "แม่น้ำน่าน" + "แควน้อย"
- Railway: Overpass API — Northern Line (OSM)
- Basemap: CARTO dark_all

## Git History

- `522af83` — workshop: DustBoy live + real GIS map + source sync (Feb 28 14:51)
- `131c459` — workshop: GitHub Pages site — docs/ with index, train, map, guide, data (Feb 28 14:14)
- `6a5d8fd` — workshop: map prompt for students — GPS data + Leaflet.js (Feb 28 13:50)

## GitHub Issues/PRs

- **two-rivers-oracle#2** — "Travel Route Interactive Map Application" (OPEN, by RRRMAR)
- **oracle-v2#229** — "PSRU Workshop Wave — 7 Oracles Born" (Phitsanulok workshop)

## Cross-Repo Matches

- `prasertcbs/thailand_gis/` — Full Thailand GIS with shapefiles (regions, provinces)
- `Oracle-Landing/thanathorn-cv-simple/travel-map.html` — Travel map
- `laris-co/laris-meshtastic/map.html` — Meshtastic mapping

## Oracle Memory

- `ψ/memory/retrospectives/2026-02/28/14.41_follow-up-real-map.md` — Built map-real.html, loaded OSM data
- `ψ/memory/traces/2026-03-01/0945_psru-workshop-recap.md` — Workshop recap with 34 GPS waypoints

## Summary

**Two Rivers already has comprehensive CNX→PHS map infrastructure:**
1. `map-real.html` — Full GIS with live OSM data (rivers, railway, province boundaries)
2. `map.html` — Interactive timeline with 34 waypoints
3. `train.html` — 3D visualization
4. 329 GPS data points in CSV

**The connection is the Oracle's origin story** — born on Train #8 from Chiang Mai, named สองแคว after Phitsanulok's geography (two rivers meeting).

**For landing page**: The real map data can be embedded or linked as a key visual element showing the journey from Chiang Mai to Phitsanulok.
