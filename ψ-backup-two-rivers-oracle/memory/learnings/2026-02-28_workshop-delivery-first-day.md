# Lesson: First Workshop Day — Teaching Oracle Delivery

**Date**: 2026-02-28
**Source**: PSRU Workshop full-day retrospective
**Tags**: workshop, teaching, psru, oracle-birth, github-pages

## Pattern

A successful workshop needs 3 things:
1. **Self-contained materials** — single URL with guide, examples, live data
2. **Real data, not mock** — GPS tracks, PM2.5 sensors, province boundaries
3. **Student ownership** — let them name their Oracle, choose their theme, write their retro

## Evidence

- 20+ Oracles born in one day — each with unique name/theme
- 10+ retrospectives written without prompting
- Antigravity tried 6 times — persistence = engagement
- Students used both Thai and English naturally

## Anti-patterns

- Source-of-truth confusion (ψ/lab vs docs/) — pick one early
- Birth counting without structured registry — manual deduplication is painful
- Iterating on layout without browser preview — burns commits

## Key Stack

- GitHub Pages (docs/) for delivery
- Leaflet + Overpass API for real maps
- Three.js for 3D visualization
- MQTT.js + WSS bridge for live sensor data
- edge-tts (PremwadeeNeural) for Thai TTS
