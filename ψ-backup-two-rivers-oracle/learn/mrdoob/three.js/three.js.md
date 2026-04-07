# Three.js Learning Index

## Source
- **Origin**: ./origin/
- **GitHub**: https://github.com/mrdoob/three.js

## Focus
`webgl_animation_skinning_morph` — RobotExpressive model with skeletal animation, emotes, and morph target expressions.

## Explorations

### 2026-02-28 16:27 (default, 3 agents)
- [Architecture](2026-02-28/1627_ARCHITECTURE.md) — Full animation pipeline: Mixer, Action, Timer, PropertyBinding
- [Code Snippets](2026-02-28/1627_CODE-SNIPPETS.md) — 6 patterns: GLTF loading, crossfade, emotes, morph targets, MorphController helper
- [Quick Reference](2026-02-28/1627_QUICK-REFERENCE.md) — All 48 morph targets, bone hierarchy, 7 states + 6 emotes, integration ideas

**Key insights**: AnimationMixer is property-agnostic (works for bones, morphs, cameras). Morph targets are fully independent from skeletal animation. Timer replaces Clock with simpler API + Page Visibility handling.

### 2026-02-28 16:12 (default, 3 agents)
- [Architecture](2026-02-28/1612_ARCHITECTURE.md) — 3-layer architecture, crossfade system, data flow
- [Code Snippets](2026-02-28/1612_CODE-SNIPPETS.md) — Integration patterns for hand-tracking + MQTT
- [Quick Reference](2026-02-28/1612_QUICK-REFERENCE.md) — CDN setup, animation states, common gotchas

**Key insights**: RobotExpressive has both arms (unlike Kira), 13 animation clips, CC0 license. Emote pattern uses 'finished' event + restoreState for auto-recovery. morphTargetInfluences on Head_4 mesh only.
