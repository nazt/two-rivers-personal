# Three.js webgl_animation_skinning_morph — Quick Reference

## What It Does

The `webgl_animation_skinning_morph` example demonstrates **skeletal animation + facial expression blending** in a single character rig.

- **Model**: RobotExpressive.glb (GLTF character by Tomás Laulhé / Don McCurdy, CC0)
- **Three layers of control**:
  - Body locomotion states (idle, walk, run)
  - One-shot emotes (dance, jump, wave, punch, thumbsup, yes, no)
  - Facial expressions (morph targets on Head_4 mesh)
- **Interactive**: GUI controls for all three animation layers

---

## Key Concepts

| Concept | Three.js Class | Purpose |
|---------|----------------|---------|
| **Skinning** | `SkinnedMesh` (in GLTF) | Bones deform mesh vertices; imported directly from glTF |
| **Morph Targets** | `morphTargetInfluences[]` | Per-vertex shape variations blended 0.0 → 1.0 |
| **Mixer** | `THREE.AnimationMixer` | Playback engine; manages clip scheduling + crossfading |
| **Action** | `mixer.clipAction(clip)` | Individual clip controller (play, stop, weight, timeScale) |
| **Timer** | `THREE.Timer` | Provides `delta()` for frame-independent animation timing |

---

## Animation States

### Locomotion (Looping)
- **Idle** — default resting pose
- **Walking** — forward locomotion loop
- **Running** — fast locomotion loop

### Emotes (One-Shot + Restore)
| Emote | Type |
|-------|------|
| Jump | Body + face |
| Yes | Head nod |
| No | Head shake |
| Wave | Arm gesture |
| Punch | Arm + body |
| ThumbsUp | Arm gesture |

### Facial Expressions (Morph Targets)
- **Location**: `Head_4` mesh only
- **Access**: `face.morphTargetDictionary` (name → index lookup)
- **Control**: `face.morphTargetInfluences[index]` (range: 0.0 → 1.0)
- **Blend**: Multiple targets can be active simultaneously

---

## Code Patterns

### Load + Parse Animations
```javascript
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';

const loader = new GLTFLoader();
const gltf = await loader.loadAsync('RobotExpressive.glb');
const model = gltf.scene;

const mixer = new THREE.AnimationMixer(model);
const clips = gltf.animations; // Array of AnimationClip objects
```

### Play Looping Animation
```javascript
const idleClip = THREE.AnimationClip.findByName(clips, 'Idle');
const action = mixer.clipAction(idleClip);
action.play(); // Loops by default
```

### Play One-Shot Emote + Restore
```javascript
const jumpClip = THREE.AnimationClip.findByName(clips, 'Jump');
const jumpAction = mixer.clipAction(jumpClip);
jumpAction.reset();
jumpAction.clampWhenFinished = true; // Hold final frame
jumpAction.play();

// After emote ends, restore locomotion state
mixer.addEventListener('finished', () => {
  locomotionAction.play(); // Resume idle/walk/run
});
```

### Control Morph Target
```javascript
const head = model.getObjectByName('Head_4');
const index = head.morphTargetDictionary['Smile'];
head.morphTargetInfluences[index] = 0.8; // 80% smile
```

### Update in Animation Loop
```javascript
const timer = new THREE.Timer();

function animate() {
  requestAnimationFrame(animate);
  const delta = timer.getDelta(); // Frame delta time in seconds
  mixer.update(delta);
  renderer.render(scene, camera);
}
```

---

## CDN Setup

### Import Map
```html
<script type="importmap">
{
  "imports": {
    "three": "https://cdn.jsdelivr.net/npm/three@0.170.0/build/three.module.js",
    "three/addons/": "https://cdn.jsdelivr.net/npm/three@0.170.0/examples/jsm/"
  }
}
</script>
```

### Model URL
```
https://threejs.org/examples/models/gltf/RobotExpressive/RobotExpressive.glb
```

---

## Integration Ideas

### Hand Tracking → Expressions
- Open hand = smile morph target → 1.0
- Fist = frown morph target → 1.0
- Thumbs up = trigger `ThumbsUp` emote

### MQTT → Remote Animation
```javascript
// Subscribe: mqtt/robot/state
// Message: { state: "dancing", expression: "happy" }
client.on('message', (topic, msg) => {
  const cmd = JSON.parse(msg);
  playLocomotionState(cmd.state);
  setMorphTarget(cmd.expression);
});
```

### Voice → Emotes
- "wave" → trigger Wave action
- "dance" → switch to Dancing state + happy expression
- "thumbs up" → trigger ThumbsUp action

### Sensor Data → Live Expressions
- PM2.5 level → sadness morph target (high pollution = sad face)
- Temperature → energy level (cold = slow walk, hot = run)
- Noise level → surprise expression (loud sound = surprised)

---

## Common Gotchas

1. **Mesh Name Mismatch**: Morph targets are only on `Head_4`. Other meshes won't respond to `morphTargetInfluences`.

2. **Action Weights**: When blending multiple actions, ensure weights sum to 1.0:
   ```javascript
   idleAction.setLoop(THREE.LoopRepeat);
   idleAction.weight = 0.5;
   walkAction.setLoop(THREE.LoopRepeat);
   walkAction.weight = 0.5;
   ```

3. **Crossfade vs Reset**: Use `crossFadeTo()` for smooth transitions, `reset()` before `play()` for emotes.
   ```javascript
   currentLocoAction.crossFadeTo(newLocoAction, 0.5, true);
   emoteAction.reset().play();
   ```

4. **Delta Time**: Always use `mixer.update(delta)` — not frame count. Supports 60fps, 120fps, or variable refresh rates.

---

## References

- **Three.js Docs**: https://threejs.org/docs/#api/en/animation/AnimationMixer
- **Live Example**: https://threejs.org/examples/#webgl_animation_skinning_morph
- **Model Creator**: Tomás Laulhé, Don McCurdy (CC0)
- **Source**: three.js/examples/webgl_animation_skinning_morph.html

---

*Quick reference created 2026-02-28*
*For Two Rivers Oracle teaching repository*
