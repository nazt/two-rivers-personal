# Three.js webgl_animation_skinning_morph — Quick Reference

**Source**: `/examples/webgl_animation_skinning_morph.html`
**Model**: `RobotExpressive.glb` (CC0, by Tomás Laulhé + Don McCurdy modifications)
**Date**: 2026-02-28

---

## What It Does

This example demonstrates skeletal animation (skinning) combined with facial expression control using morph targets. A character transitions between looping locomotion states (Idle, Walking, Running, Dance, Death, Sitting, Standing) via smooth crossfades, while one-shot emote actions (Jump, Yes, No, Wave, Punch, ThumbsUp) interrupt and restore to the base state. Facial expressions are controlled independently through morph targets on the Head_4 mesh, allowing expressions to play simultaneously with body animations.

---

## Key Concepts

| Concept | Meaning | Example |
|---------|---------|---------|
| **Skinning** | Vertex deformation driven by skeleton bones | Robot body moves as bones rotate |
| **Skeleton/Bones** | Hierarchical bone structure defining the rig | Spine → Shoulder → Arm → Hand |
| **Morph Targets** | Vertex position blends (shape keys) | "smile" = 0–1 blend on Head_4 |
| **AnimationMixer** | Engine that plays clips on a model | `mixer = new THREE.AnimationMixer(model)` |
| **AnimationAction** | Individual playing animation instance | `action = mixer.clipAction(clip)` |
| **AnimationClip** | Recorded sequence of keyframes | From GLTF: one clip per animation name |
| **Crossfade** | Smooth blend between two actions | `prev.fadeOut(0.5); new.fadeIn(0.5)` |
| **LoopOnce** | Play once, then stop (no repeat) | Emotes use this; states loop infinitely |
| **clampWhenFinished** | Hold final frame instead of rewinding | Emotes freeze on last frame |
| **morphTargetDictionary** | Map of expression names → indices | `{ "smile": 0, "frown": 1, ... }` |
| **morphTargetInfluences** | Array of current morph weights (0–1) | `face.morphTargetInfluences[0] = 0.8` |
| **Delta Time (dt)** | Milliseconds since last frame | `mixer.update(dt)` for smooth playback |
| **Timer** | Tracks elapsed time for delta calc | `timer.update()` then `timer.getDelta()` |

---

## Animation States

### Looping States (Base Locomotion)
Default loop behavior: `loop = THREE.LoopRepeat` (cycles infinitely)

| State | Duration | Use Case |
|-------|----------|----------|
| **Idle** | ~2s | Stationary, breathing pose |
| **Walking** | ~1.5s | Normal forward movement |
| **Running** | ~1.5s | Fast movement |
| **Dance** | ~3s | Celebratory gesture |
| **Sitting** | ~1s | Seated position (clamps) |
| **Standing** | ~1s | Transition to stand (clamps) |
| **Death** | ~2s | Collapse animation (clamps) |

### One-Shot Emotes (Gestures)
Loop behavior: `loop = THREE.LoopOnce` (play once, freeze)
Trigger behavior: Play emote → on "finished" event → restore to base state via crossfade

| Emote | Duration | Behavior |
|-------|----------|----------|
| **Jump** | ~0.6s | Vertical leap gesture |
| **Yes** | ~1s | Head nod affirmation |
| **No** | ~1s | Head shake negation |
| **Wave** | ~1s | Hand wave greeting |
| **Punch** | ~0.5s | Quick punch gesture |
| **ThumbsUp** | ~1s | Approval gesture |

---

## Morph Target Names (Head_4)

These are the available facial expressions (from `face.morphTargetDictionary`):

| Index | Name | Effect | Range |
|-------|------|--------|-------|
| 0 | `browDownLeft` | Left eyebrow furrow | 0–1 |
| 1 | `browDownRight` | Right eyebrow furrow | 0–1 |
| 2 | `browInnerUp` | Inner eyebrow raise | 0–1 |
| 3 | `browOuterUpLeft` | Left outer eyebrow raise | 0–1 |
| 4 | `browOuterUpRight` | Right outer eyebrow raise | 0–1 |
| 5 | `cheekPuff` | Cheek inflation | 0–1 |
| 6 | `cheekSquintLeft` | Left eye squint | 0–1 |
| 7 | `cheekSquintRight` | Right eye squint | 0–1 |
| 8 | `eyeBlinkLeft` | Left eyelid close | 0–1 |
| 9 | `eyeBlinkRight` | Right eyelid close | 0–1 |
| 10 | `eyeDown` | Eyes down gaze | 0–1 |
| 11 | `eyeInnerUp` | Eyes inner up | 0–1 |
| 12 | `eyeLeft` | Eyes gaze left | 0–1 |
| 13 | `eyeOuterUp` | Eyes outer up | 0–1 |
| 14 | `eyeRight` | Eyes gaze right | 0–1 |
| 15 | `eyeSquintLeft` | Left eye squint | 0–1 |
| 16 | `eyeSquintRight` | Right eye squint | 0–1 |
| 17 | `eyeUp` | Eyes up gaze | 0–1 |
| 18 | `jawForward` | Jaw forward thrust | 0–1 |
| 19 | `jawLeft` | Jaw shift left | 0–1 |
| 20 | `jawOpen` | Mouth opening | 0–1 |
| 21 | `jawRight` | Jaw shift right | 0–1 |
| 22 | `mouthClose` | Lips close | 0–1 |
| 23 | `mouthDimpleLeft` | Left dimple | 0–1 |
| 24 | `mouthDimpleRight` | Right dimple | 0–1 |
| 25 | `mouthFrownLeft` | Left mouth corner down | 0–1 |
| 26 | `mouthFrownRight` | Right mouth corner down | 0–1 |
| 27 | `mouthFunnel` | Mouth funnel shape | 0–1 |
| 28 | `mouthLeft` | Mouth shift left | 0–1 |
| 29 | `mouthLowerDownLeft` | Lower mouth left | 0–1 |
| 30 | `mouthLowerDownRight` | Lower mouth right | 0–1 |
| 31 | `mouthPressLeft` | Left lip press | 0–1 |
| 32 | `mouthPressRight` | Right lip press | 0–1 |
| 33 | `mouthPucker` | Lip pucker | 0–1 |
| 34 | `mouthRight` | Mouth shift right | 0–1 |
| 35 | `mouthRollLower` | Lower lip roll | 0–1 |
| 36 | `mouthRollUpper` | Upper lip roll | 0–1 |
| 37 | `mouthShrugLower` | Lower mouth shrug | 0–1 |
| 38 | `mouthShrugUpper` | Upper mouth shrug | 0–1 |
| 39 | `mouthSmileLeft` | Left smile | 0–1 |
| 40 | `mouthSmileRight` | Right smile | 0–1 |
| 41 | `mouthStretchLeft` | Left mouth stretch | 0–1 |
| 42 | `mouthStretchRight` | Right mouth stretch | 0–1 |
| 43 | `mouthUpperUpLeft` | Upper mouth left | 0–1 |
| 44 | `mouthUpperUpRight` | Upper mouth right | 0–1 |
| 45 | `noseSneerLeft` | Left nose sneer | 0–1 |
| 46 | `noseSneerRight` | Right nose sneer | 0–1 |
| 47 | `tongueOut` | Tongue protrude | 0–1 |

**Total: 48 morph targets**

---

## Code Patterns

### 1. Load Model & Create Mixer

```javascript
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';

const loader = new GLTFLoader();
loader.load('models/gltf/RobotExpressive/RobotExpressive.glb', (gltf) => {
  const model = gltf.scene;
  scene.add(model);

  // Create animation mixer
  const mixer = new THREE.AnimationMixer(model);

  // Store all animation actions by name
  const actions = {};
  for (let clip of gltf.animations) {
    actions[clip.name] = mixer.clipAction(clip);
  }

  // Play initial action
  const walkAction = actions['Walking'];
  walkAction.play();
});
```

### 2. Play Base Animation (Looping)

```javascript
// Start walking
const walkAction = actions['Walking'];
walkAction.loop = THREE.LoopRepeat;  // Loop infinitely
walkAction.play();
```

### 3. Crossfade to Another State

```javascript
function fadeToAction(name, duration = 0.5) {
  const previousAction = activeAction;
  activeAction = actions[name];

  if (previousAction !== activeAction) {
    previousAction.fadeOut(duration);
  }

  activeAction
    .reset()
    .setEffectiveTimeScale(1)
    .setEffectiveWeight(1)
    .fadeIn(duration)
    .play();
}

// Switch states smoothly
fadeToAction('Running', 0.5);  // Fade over 500ms
```

### 4. Trigger One-Shot Emote

```javascript
function playEmote(emoteName) {
  const previousAction = activeAction;
  const emoteAction = actions[emoteName];

  // Configure one-shot
  emoteAction.loop = THREE.LoopOnce;
  emoteAction.clampWhenFinished = true;

  // Quick crossfade to emote
  previousAction.fadeOut(0.2);
  emoteAction
    .reset()
    .fadeIn(0.2)
    .play();

  // On finish, return to base state
  mixer.addEventListener('finished', () => {
    mixer.removeEventListener('finished', arguments.callee);
    fadeToAction(api.state, 0.2);  // Back to Walk/Idle/etc
  });
}

// Trigger emote
playEmote('Wave');
```

### 5. Control Morph Targets (Expressions)

```javascript
// Get head mesh
const face = model.getObjectByName('Head_4');

// Read available expressions
const expressions = Object.keys(face.morphTargetDictionary);
console.log(expressions);  // ['browDownLeft', 'browDownRight', ...]

// Set expression by index
const browIndex = face.morphTargetDictionary['browDownLeft'];
face.morphTargetInfluences[browIndex] = 0.8;  // Frown (0–1)

// Set by name (loop version)
function setExpression(name, weight) {
  const index = face.morphTargetDictionary[name];
  if (index !== undefined) {
    face.morphTargetInfluences[index] = Math.max(0, Math.min(1, weight));
  }
}

setExpression('mouthSmileLeft', 1.0);   // Smile
setExpression('eyeBlinkLeft', 0.5);     // Half blink
setExpression('tongueOut', 0.3);        // Subtle tongue
```

### 6. Blend Multiple Expressions

```javascript
// Combine expressions (they sum, but clamped at 1)
face.morphTargetInfluences[face.morphTargetDictionary['mouthSmileLeft']] = 0.8;
face.morphTargetInfluences[face.morphTargetDictionary['mouthSmileRight']] = 0.8;
face.morphTargetInfluences[face.morphTargetDictionary['eyeBlinkLeft']] = 0.3;
// Result: smile + half-blink
```

### 7. Animation Loop (Main Update)

```javascript
const timer = new THREE.Timer();
timer.connect(document);

function animate() {
  timer.update();
  const dt = timer.getDelta();  // Delta in seconds

  if (mixer) mixer.update(dt);  // Update animations

  renderer.render(scene, camera);
  requestAnimationFrame(animate);
}

animate();
```

---

## CDN Setup

Use Three.js from CDN (importmap):

```html
<script type="importmap">
{
  "imports": {
    "three": "https://cdn.jsdelivr.net/npm/three@r128/build/three.module.js",
    "three/addons/": "https://cdn.jsdelivr.net/npm/three@r128/examples/jsm/"
  }
}
</script>

<script type="module">
import * as THREE from 'three';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';
import { GUI } from 'three/addons/libs/lil-gui.module.min.js';
</script>
```

Or local (as in example):

```html
<script type="importmap">
{
  "imports": {
    "three": "../build/three.module.js",
    "three/addons/": "./jsm/"
  }
}
</script>
```

**Version note**: Use `r128+` for `Timer` class (added in r128)

---

## Model URL

**Local path** (in example):
```
models/gltf/RobotExpressive/RobotExpressive.glb
```

**For your project**, either:
1. Copy to `public/models/` and load relative to HTML
2. Host on CDN and use full URL

**Model stats**:
- File size: ~464 KB
- Bones: ~50+ (Skeleton hierarchy with Armature)
- Meshes: Multiple (body, clothes, etc.)
- Animations: 13 clips (7 states + 6 emotes)
- Morph targets: 48 (on Head_4 only)

---

## Integration Ideas

### Hand Tracking → Facial Expressions

```javascript
// From MediaPipe hand landmarks (0–1 normalized)
function updateExpressionFromHand(hand) {
  const palmOpen = hand.palmOpenness;  // 0–1
  const thumbOut = hand.thumbOut;      // 0–1

  face.morphTargetInfluences[
    face.morphTargetDictionary['jawOpen']
  ] = palmOpen * 0.8;  // Open mouth if palm open

  face.morphTargetInfluences[
    face.morphTargetDictionary['mouthSmileRight']
  ] = thumbOut;  // Smile if thumbs up
}
```

### MQTT Remote Control → Body Animations

```javascript
// Subscribe to MQTT topic
client.subscribe('robot/animation');

client.onMessage = (topic, msg) => {
  const cmd = JSON.parse(msg);
  // { action: 'Wave', duration: 0.3 }

  if (actions[cmd.action]) {
    fadeToAction(cmd.action, cmd.duration || 0.5);
  }
};
```

### Sensor Data → Expressions (IoT)

```javascript
// Temperature sensor → emotional response
websocket.onmessage = (e) => {
  const temp = JSON.parse(e.data).temp;  // °C

  if (temp > 35) {
    setExpression('mouthOpen', 0.8);     // Hot = open mouth
    setExpression('eyeBlinkRight', 0.5);
  } else if (temp < 10) {
    setExpression('eyeBlinkLeft', 1.0);  // Cold = blink
    setExpression('mouthClose', 0.9);
  }
};
```

### Speech → Mouth Sync (Viseme Mapping)

```javascript
// Map phoneme to morph targets
const visemes = {
  'A': { 'jawOpen': 0.8, 'mouthSmileRight': 0.3 },
  'E': { 'jawOpen': 0.5, 'mouthLeft': 0.2 },
  'O': { 'jawOpen': 0.7, 'mouthFunnel': 0.6 },
  'U': { 'jawOpen': 0.4, 'mouthPucker': 0.8 },
};

function playViseme(phoneme) {
  const targets = visemes[phoneme];
  for (const [name, weight] of Object.entries(targets)) {
    setExpression(name, weight);
  }
}
```

---

## Common Gotchas

### 1. Mesh Name Mismatch

**Problem**: `model.getObjectByName('Head_4')` returns `null`

**Cause**: Exact name matching. In RobotExpressive, it's `Head_4` not `Head` or `head`.

**Fix**: Inspect with:
```javascript
model.traverse(obj => console.log(obj.name));
```

### 2. Action Weights Not Blending

**Problem**: Crossfade doesn't smooth

**Cause**: Missing `.reset()` before `.play()`

**Fix**:
```javascript
action.reset().fadeIn(0.5).play();  // Reset is critical
```

### 3. Crossfade vs Reset Confusion

**Difference**:
- `.reset()`: Rewind animation to frame 0
- `.fadeIn(d) / .fadeOut(d)`: Blend weight over duration (keeps time)

**Best practice**: Always `.reset()` before switching locomotion states

### 4. Emote Doesn't Restore to Base State

**Problem**: After `playEmote('Wave')`, robot freezes

**Cause**: Forgot to listen for `'finished'` event

**Fix**:
```javascript
mixer.addEventListener('finished', restoreState);
mixer.removeEventListener('finished', restoreState);  // Clean up!
```

### 5. Morph Target Index Out of Bounds

**Problem**: `morphTargetInfluences[99]` is undefined, throws error

**Cause**: Assuming fixed index. Head_4 only has 48 targets.

**Fix**: Always validate:
```javascript
const idx = face.morphTargetDictionary[name];
if (idx !== undefined) {
  face.morphTargetInfluences[idx] = value;
}
```

### 6. Delta Time Huge on First Frame

**Problem**: Mixer jumps a full second on first update

**Cause**: Not using `Timer` class (or calling `getDelta()` twice)

**Fix**:
```javascript
const timer = new THREE.Timer();
timer.connect(document);

function animate() {
  timer.update();  // Once per frame
  const dt = timer.getDelta();
  mixer.update(dt);
  // ...
}
```

### 7. Animations Not Loading

**Problem**: `gltf.animations` is empty array

**Cause**: GLB doesn't contain animation clips (wrong model or stripped)

**Check**: Use GLB viewer (three.js/editor) or inspect:
```javascript
console.log(gltf.animations.length, gltf.animations.map(c => c.name));
```

### 8. Two Animations Playing at Once

**Problem**: Walk and Run both audible/visible

**Cause**: Didn't fade out previous action

**Fix**:
```javascript
previousAction.fadeOut(duration);  // Essential
activeAction.fadeIn(duration).play();
```

---

## Skeleton Bone Hierarchy (RobotExpressive)

The model uses a standard humanoid armature with these major bones:

```
Armature (root)
├── Hips (center of gravity)
│   ├── Spine (lower back)
│   │   ├── Spine1 (mid-back)
│   │   ├── Spine2 (upper back)
│   │   ├── Chest
│   │   │   ├── Shoulder_L (left shoulder)
│   │   │   │   ├── ArmUpper_L
│   │   │   │   ├── ArmLower_L
│   │   │   │   └── Hand_L
│   │   │   └── Shoulder_R (right shoulder)
│   │   │       ├── ArmUpper_R
│   │   │       ├── ArmLower_R
│   │   │       └── Hand_R
│   │   └── Neck
│   │       └── Head
│   ├── UpLeg_L (left thigh)
│   │   ├── Leg_L (left shin)
│   │   └── Foot_L
│   └── UpLeg_R (right thigh)
│       ├── Leg_R (right shin)
│       └── Foot_R
```

**Note**: Bone names are approximations (verify with `.traverse()`). The actual structure uses FBX naming conventions: `Armature`, `Hips`, `Spine`, `Shoulder.L/R`, etc.

---

## Tips for Advanced Integration

1. **Blend Multiple States**: Use `setEffectiveWeight()` to crossfade 3+ animations
2. **Time Scrubbing**: Use `mixer.setTime(seconds)` to preview animation frames
3. **Speed Control**: `action.setEffectiveTimeScale(2)` doubles animation speed
4. **Detect Animation End**: Listen to `'finished'` event on mixer
5. **Action Callbacks**: Each action is an EventTarget; use `action.addEventListener()`
6. **Clone vs Reuse**: Create one mixer per model; reuse actions with same model
7. **Performance**: Morph targets are GPU-computed (cheap). Skinning is also efficient.
8. **Blinking Loop**: Trigger blink emotes periodically for life-like behavior

---

## References

- **Example source**: `/Users/nat/Code/github.com/Soul-Brews-Studio/two-rivers-oracle/ψ/learn/mrdoob/three.js/origin/examples/webgl_animation_skinning_morph.html`
- **Model**: `/examples/models/gltf/RobotExpressive/RobotExpressive.glb`
- **Three.js docs**: [AnimationMixer](https://threejs.org/docs/#api/en/animation/AnimationMixer), [AnimationAction](https://threejs.org/docs/#api/en/animation/AnimationAction)
- **Morph targets** (also called "shape keys" in Blender, "blend shapes" in Maya)

