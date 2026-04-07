---
query: "compare 14 PSRU simulator pages"
target: "two-rivers-oracle"
mode: deep
timestamp: 2026-02-28 21:45
---

# Trace: Compare 14 PSRU Simulator Pages

**Target**: two-rivers-oracle
**Mode**: deep (5 parallel agents)
**Time**: 2026-02-28 21:45 GMT+7

## Structural Consistency

All 14 files share the floodboy.html template DNA:
- **MQTT broker**: ✅ All use `wss://dustboy-wss-bridge.laris.workers.dev/mqtt`
- **Dark theme**: ✅ All use `#0d1117` bg, `#161b22` panels, `#30363d` borders
- **3-col grid**: ✅ 12 of 14 (virtual-tour + vr-driving use full-screen + HUD overlay — correct for 3D)
- **Mobile responsive**: ✅ All have `@media (max-width: 900px)`
- **Status dot**: ✅ All have MQTT connection indicator
- **Header bar**: ✅ All have gradient title + nav links to index.html

### File Sizes

| File | Size | Lines | Tech |
|------|------|-------|------|
| vr-driving.html | 34KB | 1036 | Three.js |
| virtual-tour.html | 34KB | 949 | Three.js |
| coop-matching.html | 31KB | 777 | Chart.js + p5.js |
| phishing.html | 31KB | 741 | Chart.js + SVG |
| face-check.html | 31KB | 812 | p5.js |
| smartpentest.html | 31KB | 546 | Chart.js |
| smart-box.html | 29KB | 820 | p5.js |
| box-assembly.html | 28KB | 809 | p5.js |
| library.html | 27KB | 639 | Chart.js + Canvas |
| smartbin.html | 27KB | 705 | p5.js + Chart.js |
| smartbin-cv.html | 26KB | 686 | p5.js |
| carbon-credit.html | 25KB | 664 | p5.js + Chart.js |
| ev-bus.html | 24KB | 608 | Leaflet + Chart.js |
| delivery-robot.html | 22KB | 540 | Leaflet |

**Total**: ~401KB, ~10,332 lines across 14 files

## Thai Language Quality Tiers

### Tier 1: Excellent Thai Integration
| Page | Thai Strings | Defense Demo Quality |
|------|-------------|---------------------|
| SmartBin CV | ~35-40 | TTS: "กรุณาแยกฝาออก แยกฉลากออก แล้วทิ้งในถังรีไซเคิลค่ะ" |
| Face-Check | ~30-35 | "ตรวจพบรูปถ่าย — ปฏิเสธ" + Thai student names |
| SmartBin | ~25-30 | "ถังจะเต็มใน 3 ชม." prediction text |

### Tier 2: Good Thai Integration
| Page | Thai Strings | Notes |
|------|-------------|-------|
| Library | ~20-25 | "นศ.ยืมหนังสือ IT เพิ่ม 40%" AI insights |
| Delivery Robot | ~20 | Campus buildings: อาคาร IT, ห้องสมุด, โรงอาหาร |
| EV Bus | ~20-25 | "สาย A จะเต็มใน 10 นาที ควรเพิ่มรอบ" |
| Carbon Credit | ~15-20 | ปั่นจักรยาน, ปลูกต้นไม้, แยกขยะ |
| Coop-Matching | ~10-15 | Company + skill labels in Thai |
| Box Assembly | ~10-15 | Mode labels: วางผิดด้าน, กล่องเสียหาย |

### Tier 3: Light Thai (Room for Improvement)
| Page | Thai Strings | Gap |
|------|-------------|-----|
| SmartPenTest | ~10-15 | AI analysis output in English, should be Thai |
| Virtual Tour | ~5-10 | Equipment descriptions mostly English |
| VR Driving | ~8-12 | AI feedback should say "เบรกกะทันหัน -5 คะแนน" in Thai |
| Smart Box | ~8-12 | Missing Thai narration/feedback |
| Phishing | ~3-5 | AI explanations entirely English, advice says "อธิบายเป็นภาษาคน" |

## MQTT Topic Map

```
pentest/{id}/result          ← smartpentest
pentest/{id}/summary         ← smartpentest
SmartBin/{id}/status         ← smartbin
library/query                ← library
waste/{id}/detection         ← smartbin-cv
carbon/{wallet}/mint         ← carbon-credit
tour/{room}/position         ← virtual-tour
robot/{id}/action            ← box-assembly
delivery/{id}/position       ← delivery-robot
phishing/check               ← phishing
coop/match/{student}         ← coop-matching
evbus/{id}/position          ← ev-bus
evbus/{id}/count             ← ev-bus
driving/{id}/telemetry       ← vr-driving
sorting/{id}/action          ← smart-box
attendance/{room}/checkin    ← face-check
```

## Animation Engine Distribution

| Engine | Pages | FPS |
|--------|-------|-----|
| p5.js draw() | 8 pages | 30 FPS |
| Three.js requestAnimationFrame() | 2 pages | 60 FPS |
| setInterval() | 3 pages | Variable |
| setTimeout() | 1 page | Variable |

## Interactivity Depth

### Most Interactive (Full Simulation Loops)
1. **VR Driving** — WASD driving, AI scoring, speedometer, traffic signs, session grades
2. **Virtual Tour** — WASD walking, pointer lock, gaze triggers, info panels
3. **Face-Check** — Multi-phase detection flow, anti-spoofing demo, attendance table
4. **SmartBin CV** — Conveyor + YOLOv8 bounding boxes + TTS instructions

### Strong Interactive (Good Controls + Visualization)
5. **Box Assembly** — Robot arm IK, conveyor, defect detection, 5 modes
6. **Smart Box** — Arm sorting, measurement overlay, size thresholds
7. **SmartBin** — Radar pulses, fill gauge, prediction chart, 5 presets
8. **Delivery Robot** — Map navigation, obstacle avoidance, battery drain
9. **EV Bus** — 3 routes, moving bus icons, people count badges, ridership chart
10. **Carbon Credit** — Blockchain viz, NFT minting, activity verification

### Moderate Interactive (Form + Results)
11. **Coop-Matching** — Profile form, matching animation, radar chart comparison
12. **Phishing** — URL analysis, feature extraction, risk gauge
13. **SmartPenTest** — Scan phases, vulnerability cards, AI explanation
14. **Library** — Heatmap, filters, recommendations, AI insights

## Advice Alignment Score

How well each simulator reflects Nat's specific advice from the consultation:

| Page | Advice Point | Implemented? |
|------|-------------|-------------|
| SmartBin | "prediction ถังจะเต็มใน 3 ชม." | ✅ Yes |
| SmartBin CV | "เสียงพูดไทย กรุณาแยกฝาออก" | ✅ Yes (text, not audio) |
| Library | "heatmap ช่วงเวลายืม, collaborative filtering" | ✅ Yes |
| Face-Check | "liveness detection ป้องกันใช้รูปหลอก" | ✅ Yes |
| Carbon Credit | "block explorer ให้กรรมการดู transaction" | ✅ Blockchain viz |
| Virtual Tour | "AI narrator อธิบายชิ้นส่วนเมื่อ user จ้องมอง" | ⚠️ Gaze trigger yes, Thai narrator partial |
| Box Assembly | "anomaly detection + dashboard pass/fail rate" | ✅ Yes |
| Delivery Robot | "MQTT real-time tracking บน web map" | ✅ Yes (Leaflet) |
| EV Bus | "AI predict อีก 10 นาที รถจะเต็ม" | ✅ Yes |
| VR Driving | "AI scoring เบรก เลี้ยว + feedback" | ✅ Yes |
| SmartPenTest | "AI อธิบายว่าช่องโหว่คืออะไร แก้ยังไง" | ⚠️ English, not Thai |
| Phishing | "LLM อธิบายเป็นภาษาคน" | ⚠️ English explanations |
| Coop-Matching | "LLM อธิบาย จับคู่เพราะ..." | ⚠️ Partial Thai |
| Smart Box | "vision measurement กล้อง + reference object" | ✅ Yes |

**Score: 10/14 fully aligned, 4/14 partially (Thai language gap)**

## Summary

**What went right**:
- Structural consistency across all 14 pages is excellent — same dark theme, MQTT, responsive grid
- Tech grouping (p5.js / Three.js / Leaflet / Chart.js) produced coherent output per group
- 10 of 14 pages directly implement the specific "จุดเด่นตอน defense" from Nat's advice
- MQTT topic naming is clean and consistent across all pages

**What could improve**:
- 4 pages (smartpentest, phishing, virtual-tour, vr-driving) have AI explanations in English instead of Thai
- The security pages (smartpentest, phishing) would benefit most from Thai AI analysis text
- VR Driving's Thai feedback messages need verification (the advice specifically says "เบรกกะทันหัน" style)

**Recommendation**: A focused Thai-language pass on the 4 Tier 3 pages would bring all 14 to consistent quality.
