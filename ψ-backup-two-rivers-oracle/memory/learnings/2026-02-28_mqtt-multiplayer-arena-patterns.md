# MQTT Multiplayer Arena Patterns

**Date**: 2026-02-28
**Source**: Building arena.html — real-time PVP with RobotExpressive
**Tags**: #mqtt #multiplayer #threejs #game #arena

## Key Patterns

### SkeletonUtils.clone for Multi-Player

```javascript
import * as SkeletonUtils from 'three/addons/utils/SkeletonUtils.js';
const clone = SkeletonUtils.clone(originalScene);
const mixer = new THREE.AnimationMixer(clone);
// Clips from original GLTF work with any mixer
for (const clip of gltf.animations) {
  actions[clip.name] = mixer.clipAction(clip);
}
```

Each clone gets independent bones, morphs, and mixer. Regular `.clone()` on skinned meshes shares skeleton — broken.

### MQTT Topic Design for Game State

```
arena/join          — { id, name, color, ts }
arena/state/{id}    — { x, z, ry, anim, hp, name, color, alive, ts } @ 10Hz
arena/action/{id}   — { type: "hit"|"punch"|"death"|"respawn", targetId?, damage? }
arena/leave/{id}    — { id, ts }
```

Include name+color in state messages (not just join) so late-joining players can create models from first state message received.

### MQTT Will Message for Disconnect

```javascript
mqtt.connect(broker, {
  will: { topic: `arena/leave/${id}`, payload: JSON.stringify({ id, ts }), qos: 0, retain: false }
});
```

Broker auto-publishes will message if client disconnects unexpectedly.

### Client-Authoritative Hit Detection

- Attacker checks proximity + facing cone locally
- Publishes `{ type: "hit", targetId, damage }` on action topic
- Target receives hit and applies damage to own HP
- Simple for teaching — no server needed. Not cheat-proof.

### Facing Direction in Three.js

Forward = -Z when rotation.y = 0. To face movement direction (dx, dz):
```javascript
rotation.y = Math.atan2(-dx, -dz);
```

Punch cone check (120°):
```javascript
const forward = new Vector2(-Math.sin(ry), -Math.cos(ry));
const toTarget = targetPos.clone().sub(myPos).normalize();
if (forward.dot(toTarget) > 0.3) { /* hit */ }
```

### Remote Player Interpolation

Don't snap to received positions. Lerp:
```javascript
p.x = lerp(p.x, p.targetX, 0.15);
p.ry = lerpAngle(p.ry, p.targetRy, 0.15);
```

LerpAngle must handle wrap-around at ±π.

### Stale Player Cleanup

Track `lastUpdate` timestamp per remote player. Remove if no state message received for 5 seconds. Handles tab closes, network drops, etc.
