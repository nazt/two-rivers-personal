---
query: "hand tracking MQTT three.js IK mediapipe webcam"
target: "two-rivers-oracle"
mode: smart
timestamp: 2026-02-28 15:43
---

# Trace: Hand Tracking + MQTT + Three.js IK

**Target**: two-rivers-oracle
**Mode**: smart (Oracle first → deep)
**Time**: 2026-02-28 15:43

## Oracle Results (10 hits)

Strong matches from `laris-co/nat-s-agents` retrospectives:

1. **Hand Tracker Rust + Camera Gesture** (2026-01-14 18:45)
   - Rust app: nokhwa camera + ONNX hand landmark + KNN gesture → MQTT
   - Source: `github.com/laris-co/hand-tracker-mqtt/`
   - Gestures: fist, open_palm, point, peace, pinch

2. **Oracle MQTT Hand Tracking Integration** (2026-01-15 16:33)
   - Browser subscribes to `hand/landmarks` via WebSocket
   - 21 landmarks → camera rotation + fist zoom
   - Source: `github.com/laris-co/oracle-v2.old/frontend/src/hooks/useHandTracking.ts`

3. **Orientation-Invariant Gesture Detection** (learning)
   - Distance-based metrics beat camera-orientation-dependent methods

## Repos Found

| Repo | Purpose |
|------|---------|
| `Soul-Brews-Studio/hand-tracker-mqtt` | Rust hand tracker |
| `Soul-Brews-Studio/mission-03-gesture-control` | Gesture control mission |
| `laris-co/Nat-s-Agents` | Retrospectives with full implementation details |
| `laris-co/oracle-v2.old` | Original Three.js integration (useHandTracking.ts) |

## Key Code Patterns

### MQTT Message Format
```json
{
  "timestamp": 1234567890,
  "hands": [{
    "handedness": "Left",
    "landmarks": [{"x": 0.5, "y": 0.5, "z": 0.1}, ...21]
  }]
}
```

### 21 Hand Landmarks
- 0: Wrist, 1-4: Thumb (TIP=4), 5-8: Index (TIP=8)
- 9-12: Middle (TIP=12), 13-16: Ring (TIP=16), 17-20: Pinky (TIP=20)

### Fist Detection (distance-based, orientation-invariant)
```typescript
// Finger curled if tip.y > pip.y (tip below PIP joint)
const curled = fingers.filter(f => landmarks[f.tip].y > landmarks[f.pip].y);
return curled.length >= 3;
```

## What We Built

Created `docs/hand-ik.html` combining:
1. Three.js IK (Kira model + CCDIKSolver) from threejs.org example
2. MediaPipe Hands (browser, 2 hands, GPU delegate)
3. MQTT publish/subscribe via dustboy-wss-bridge
4. Dual-hand IK: left + right hand control both of Kira's arms
5. Gesture detection: fist, open, point, peace

## Summary

Rich prior art exists. The hand-tracker-mqtt Rust app and Oracle integration
from January 2026 provided the exact MQTT message format and gesture detection
patterns used in this implementation. New contribution: IK character control
(CCDIKSolver) instead of camera rotation, and dual-hand support.
