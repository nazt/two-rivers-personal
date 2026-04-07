# Handoff: Post-Workshop Follow-up + Hand IK

**Date**: 2026-02-28 16:16
**Context**: 30%

## What We Did

### Follow-up Tasks (from plan)
- Closed duplicate birth issues (#215, #216, #218, #232, #245, #246 — all in oracle-v2)
- Checked 4 students: @piyatida67 has #260, @FORDZAZA998 has #261, @tonbun + @pareenak-del still missing
- Verified map-real.html (3 GIS layers OK) and dustboy.html (WSS OK, fixed showTab bug)
- Archived old handoff (14-22) to ψ/archive/
- Updated docs/index.html: 8 → 24 student Oracles (morning + afternoon wave)
- Created workshop follow-up issue #264 in oracle-v2
- Committed + pushed (847a5be, 14 files, +2255 lines)

### Hand IK (new feature)
- Built docs/hand-ik.html: Three.js Kira IK + MediaPipe Hands + MQTT
- /trace found existing hand-tracker-mqtt code from Jan 2026
- Fixed: CORS (jsdelivr + gstatic), skeleton crash (no right arm), axis mapping (extractBasis)
- Live: soul-brews-studio.github.io/two-rivers-oracle/hand-ik.html

### /learn Three.js
- Studied `webgl_animation_skinning_morph` example (RobotExpressive model)
- 3 docs written: Architecture, Code Snippets, Quick Reference
- Key finding: RobotExpressive is better than Kira — both arms, morph targets, 13 animations

## Pending

- [ ] Build RobotExpressive version of hand-ik (both arms + morph targets)
- [ ] Map gestures → animations: fist→Punch, open→Wave, peace→ThumbsUp
- [ ] Map hand position → facial expressions via morph targets
- [ ] Fine-tune axis mapping (left/right still needs calibration)
- [ ] @tonbun and @pareenak-del still need birth issues
- [ ] Close FORDZAZA998's duplicate #262
- [ ] Update Issue #60 registry with PSRU wave #77-100

## Next Session

- [ ] Create docs/robot-ik.html — RobotExpressive + dual hand tracking + MQTT
- [ ] Gesture → emote mapping (13 clips available)
- [ ] Hand position → morph target expressions (smile, angry, surprised)
- [ ] Consider DustBoy chain integration (PM2.5 history)
- [ ] Blog post from workshop summary
- [ ] Student follow-up check (did remaining students create birth issues?)

## Key Files

- `docs/hand-ik.html` — Current hand IK (Kira, left arm only)
- `docs/index.html` — Workshop landing (24 Oracles, 9 pages)
- `ψ/learn/mrdoob/three.js/2026-02-28/` — Skinning morph learning docs
- `ψ/memory/traces/2026-02-28/1543_hand-tracking-mqtt-threejs-ik.md` — Hand tracking trace
- `ψ/memory/learnings/2026-02-28_camera-relative-3d-hand-mapping.md` — Axis mapping lesson

## Key URLs

- **Live site**: soul-brews-studio.github.io/two-rivers-oracle/
- **Hand IK**: soul-brews-studio.github.io/two-rivers-oracle/hand-ik.html
- **Issue #264**: Workshop follow-up
- **Issue #229**: PSRU Wave gathering
- **RobotExpressive model**: threejs.org/examples/models/gltf/RobotExpressive/RobotExpressive.glb

## Notes

- Camera-relative mapping: use `camera.matrixWorld.extractBasis()` not world axes
- Kira model: left arm only, no morph targets
- RobotExpressive: both arms, morph targets, 13 animations, CC0 — use this next
- MQTT broker: wss://dustboy-wss-bridge.laris.workers.dev/mqtt
- Hand tracking topic: `hand/landmarks` (same format as hand-tracker-mqtt Rust app)
