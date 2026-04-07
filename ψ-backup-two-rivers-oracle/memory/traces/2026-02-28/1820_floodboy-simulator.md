---
query: "floodboy simulator"
target: "Soul-Brews-Studio/two-rivers-oracle"
mode: deep
timestamp: 2026-02-28 18:20
---

# Trace: floodboy simulator

**Target**: Soul-Brews-Studio/two-rivers-oracle
**Mode**: deep (5 parallel agents + Oracle)
**Time**: 2026-02-28 18:20

## Oracle Results
- FloodBoy Oracle awakened (oracle-v2 #82, #80)
- FloodBoy Astro deployed at blockchain.floodboy.online
- FloodBoy Oracle repo: laris-co/floodboy-oracle
- FloodBoy = water monitoring with Claude AI (Nat's project)

## Files Found
- **Not in this repo** — FloodBoy simulator lives at `laris-co/floodboy-simulator`
- Local path: `/Users/nat/Code/github.com/laris-co/floodboy-simulator`

## Git History
- 0 commits in two-rivers-oracle mentioning floodboy
- floodboy-simulator has 3 commits (latest: port change to 3333)

## GitHub Issues/PRs
- oracle-v2 #82: FloodBoy Oracle Awakens
- oracle-v2 #80: New Oracle Spawning: Flood Boy
- oracle-identity #28: Verify Floodboy Oracle

## Cross-Repo Matches
8 FloodBoy repos found in ghq:
- laris-co/floodboy-simulator (Docker data quality validation)
- laris-co/floodboy (core firmware)
- laris-co/floodboy-oracle (Oracle)
- laris-co/floodboy-ui-oss (UI)
- laris-co/esphome-floodboy-4g (ESP hardware)
- LarisLabs/floodboy-astro (website)
- LarisLabs/floodboy-metadata (metadata)
- nazt/floodboy-claude (Claude AI)

## Architecture
```
Simulator UI :3333 → MQTT :1883/:9001 → Telegraf (Starlark) → Buffer API :8080 → InfluxDB :8086
```

## Summary
FloodBoy Simulator is a Docker-based data quality validation pipeline for water level sensors. 7 glitch modes, two-pass validation (Starlark + rate-of-change), SQLite audit trail. Separate from Two Rivers Oracle teaching repo.
