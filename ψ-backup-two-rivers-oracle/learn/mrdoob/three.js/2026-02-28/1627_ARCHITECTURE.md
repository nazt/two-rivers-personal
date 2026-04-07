# Three.js Animation + Skinning + Morph Example: Architecture

**Source**: `/Users/nat/Code/github.com/mrdoob/three.js/examples/webgl_animation_skinning_morph.html`
**Model**: RobotExpressive (GLTF binary format, `.glb`)
**Date**: 2026-02-28

## 1. Directory Structure

```
three.js/
├── examples/
│   ├── webgl_animation_skinning_morph.html     [Entry point]
│   ├── jsm/                                    [JavaScript modules]
│   │   ├── loaders/
│   │   │   └── GLTFLoader.js                   [Asset loader]
│   │   └── libs/
│   │       ├── lil-gui.module.min.js           [UI controller]
│   │       └── stats.module.js                 [Performance monitor]
│   ├── models/
│   │   └── gltf/
│   │       └── RobotExpressive/
│   │           ├── RobotExpressive.glb         [3D model file]
│   │           └── README.md                   [Model info]
│   └── main.css                                [Common styling]
├── src/
│   ├── animation/
│   │   ├── AnimationMixer.js                   [Animation player/controller]
│   │   ├── AnimationAction.js                  [Animation state/playback]
│   │   ├── AnimationClip.js                    [Keyframe container]
│   │   ├── PropertyBinding.js                  [Property → animation track binding]
│   │   └── PropertyMixer.js                    [Value accumulation/blending]
│   ├── core/
│   │   └── Timer.js                            [Frame timing with delta time]
│   └── constants.js                            [Loop modes, blend modes]
└── build/
    └── three.module.js                         [Compiled THREE library]
```

## 2. Entry Point: HTML Structure & Import Map

File: `webgl_animation_skinning_morph.html` (272 lines)

**Import Map Pattern** (lines 37-43):
```javascript
<script type="importmap">
{
  "imports": {
    "three": "../build/three.module.js",
    "three/addons/": "./jsm/"
  }
}
</script>
```

This browser-native feature maps ES6 import specifiers:
- `import * as THREE from 'three'` → `../build/three.module.js`
- `import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js'` → `./jsm/loaders/GLTFLoader.js`

**Key HTML Elements**:
- `<div id="info">` — Description & credits (don McCurdy, Tomás Laulhé)
- `<script type="module">` — ES6 module scope for application logic

## 3. Initialization Flow

### Phase 1: Scene Setup (init() function, lines 62-127)

```javascript
timer = new THREE.Timer();
timer.connect(document);  // Use Page Visibility API
```

**Timer API**:
- `update()` — Called once per frame to compute delta time
- `getDelta()` — Returns time delta in seconds (converts from milliseconds)
- Handles page visibility to prevent large jumps when tab is inactive

**Scene Graph**:
```
Scene (background: #e0e0e0)
├── HemisphereLight (0xffffff/0x8d8d8d, intensity=3)
├── DirectionalLight (0xffffff, intensity=3)
├── PlaneGeometry (2000×2000) — ground plane
├── GridHelper (200×200 grid)
└── Model (loaded via GLTFLoader)
    ├── Skeleton (bones for skinning)
    ├── SkinnedMesh (geometry + skin weights)
    └── Head_4 (Mesh with morphTargetDictionary)
```

### Phase 2: Asset Loading (lines 101-113)

```javascript
const loader = new GLTFLoader();
loader.load('models/gltf/RobotExpressive/RobotExpressive.glb',
  function (gltf) {
    model = gltf.scene;
    scene.add(model);
    createGUI(model, gltf.animations);
  }
);
```

**GLTFLoader returns** `gltf` object:
- `gltf.scene` — THREE.Scene/Group with all meshes, skeleton, materials
- `gltf.animations` — Array of **AnimationClip** objects
  - Each clip has a `name` (e.g., "Walking", "Idle", "Jump")
  - Each clip contains `tracks` (KeyframeTrack objects)

**RobotExpressive Model Contents**:
- **Skeleton**: Armature with bones for skeleton animation (FK/IK)
- **SkinnedMesh**: Main body, animated via bone weights (skinning)
- **Head_4**: Mesh with **morphTargetDictionary** and **morphTargetInfluences**
  - Dictionary keys = expression names (e.g., "smile", "surprised")
  - Influences array = float32 values [0, 1] per expression

## 4. GUI & Animation State Setup (createGUI function, lines 129-221)

### 4.1 Mixer Initialization (lines 136-152)

```javascript
mixer = new THREE.AnimationMixer(model);
actions = {};

for (let i = 0; i < animations.length; i++) {
  const clip = animations[i];
  const action = mixer.clipAction(clip);
  actions[clip.name] = action;

  // One-shot animations (emotes & some states)
  if (emotes.indexOf(clip.name) >= 0 || states.indexOf(clip.name) >= 4) {
    action.clampWhenFinished = true;
    action.loop = THREE.LoopOnce;
  }
}
```

**Key Classes**:
- **AnimationMixer** — Controller for all animations on a model
  - Constructor: `new THREE.AnimationMixer(rootObject)`
  - Manages active actions, property bindings, interpolants
  - Memory pools: active vs. inactive actions/bindings (optimization)

- **AnimationAction** — Playback state for one clip
  - Created via `mixer.clipAction(clip)`
  - Properties: `weight`, `timeScale`, `loop`, `clampWhenFinished`
  - Methods: `play()`, `stop()`, `reset()`, `fadeIn(duration)`, `fadeOut(duration)`

### 4.2 Animation Categories

**States** (7 total): Idle, Walking, Running, Dance, Death, Sitting, Standing
- Loop continuously (`LoopRepeat`)
- Interactive: GUI dropdown to switch
- Transition via `fadeToAction(name, 0.5)` — 0.5 sec crossfade

**Emotes** (6 total): Jump, Yes, No, Wave, Punch, ThumbsUp
- Single-shot animations (`LoopOnce`)
- GUI buttons trigger `fadeToAction(name, 0.2)`
- Auto-restore to base state on finish via `mixer.addEventListener('finished', restoreState)`

**Expressions** (N total): Directly controlled via morphTargetInfluences
- GUI sliders: one per expression (0 to 1, step 0.01)
- Applied independently to `face.morphTargetInfluences[i]`
- **No AnimationClip needed** — manual UI control

### 4.3 GUI Construction (lil-gui)

```javascript
gui.addFolder('States')        // Dropdown for base states
gui.addFolder('Emotes')        // Buttons for one-shot actions
gui.addFolder('Expressions')   // Sliders for morph targets
```

## 5. Core Animation Architecture

### 5.1 The AnimationMixer

**File**: `src/animation/AnimationMixer.js` (861 lines)

**Constructor**:
```javascript
constructor(root) {
  this._root = root;
  this.time = 0;              // Global mixer time (seconds)
  this.timeScale = 1.0;       // Playback speed multiplier
}
```

**Key Methods**:

#### `clipAction(clip, optionalRoot, blendMode)`
Returns or creates an **AnimationAction** for the clip.
- Reuses actions: `clipAction(clip)` called multiple times returns same instance
- Binds clip tracks to model properties via PropertyBinding
- Returns `null` if clip not found

#### `update(deltaTime)`
Called once per frame with delta time from Timer/Clock.

```javascript
update(deltaTime) {
  deltaTime *= this.timeScale;
  const actions = this._actions;
  const nActions = this._nActiveActions;

  // Update each active action
  for (let i = 0; i !== nActions; ++ i) {
    const action = actions[i];
    action._update(time, deltaTime, timeDirection, accuIndex);
  }

  // Apply accumulated property values to scene graph
  const bindings = this._bindings;
  const nBindings = this._nActiveBindings;
  for (let i = 0; i !== nBindings; ++ i) {
    bindings[i].apply(accuIndex);
  }
}
```

**Memory Management**:
- `_actions[]` — Active actions (front), inactive (back)
- `_nActiveActions` — Partition index
- `_bindings[]` — Active property bindings (front), inactive (back)
- Avoids allocation/deallocation by moving items between partitions

### 5.2 The AnimationAction

**File**: `src/animation/AnimationAction.js` (943 lines)

**Constructor**:
```javascript
constructor(mixer, clip, localRoot=null, blendMode=clip.blendMode) {
  this._mixer = mixer;
  this._clip = clip;
  this._interpolants = [];      // One per track
  this._propertyBindings = [];  // One per track
  this.time = 0;                // Local action time
  this.weight = 1;              // Influence [0, 1]
  this.timeScale = 1;           // Speed multiplier
  this.loop = LoopRepeat;
  this.clampWhenFinished = false;
  this._effectiveWeight = 1;
  this._effectiveTimeScale = 1;
}
```

**Core State Properties**:
- `weight` — Blending influence (0 = no effect, 1 = full effect)
- `timeScale` — Playback speed (1 = normal, 0 = paused, -1 = reverse)
- `enabled` — Master on/off flag
- `paused` — Pause flag
- `time` — Current playback position in seconds

**Playback Methods**:

#### `play()`
```javascript
play() {
  this._mixer._activateAction(this);
  return this;
}
```
Moves action to active list. Calls mixer's activation logic.

#### `fadeIn(duration)` / `fadeOut(duration)`
```javascript
fadeIn(duration) {
  return this._scheduleFading(duration, 0, 1);  // weight: 0 → 1
}

fadeOut(duration) {
  return this._scheduleFading(duration, 1, 0);  // weight: 1 → 0
}

_scheduleFading(duration, weightNow, weightThen) {
  const interpolant = mixer._lendControlInterpolant();  // Borrow control interpolant
  const times = interpolant.parameterPositions;
  const values = interpolant.sampleValues;

  times[0] = mixer.time;
  times[1] = mixer.time + duration;
  values[0] = weightNow;
  values[1] = weightThen;
}
```
Creates a **LinearInterpolant** that smoothly fades `weight` over time.

#### `reset()`
Resets action to initial state:
```javascript
reset() {
  this.paused = false;
  this.enabled = true;
  this.time = 0;
  this._loopCount = -1;
  this._startTime = null;
  return this.stopFading().stopWarping();
}
```

**Internal Animation Update** (`_update()`, lines 562-638):

1. **Check scheduling**: If `_startTime` set, wait until that time
2. **Update time scale** via interpolant (`warp()` method)
3. **Advance clip time**: Apply delta time respecting loop mode
4. **Update weight** via interpolant (fade effects)
5. **Sample interpolants**: `interpolant.evaluate(clipTime)` → evaluate each track
6. **Accumulate values**: Pass to PropertyMixer for blending

**Looping Behavior** (`_updateTime()`, lines 720-876):

- **LoopOnce**: Play once, then disable/pause at end
  - Fires `'finished'` event when complete
- **LoopRepeat**: Loop continuously
  - Wraps time: `time = time % duration`
- **LoopPingPong**: Play forward then backward
  - Reverses time in odd-numbered loops

### 5.3 The Timer

**File**: `src/core/Timer.js` (185 lines)

```javascript
class Timer {
  constructor() {
    this._previousTime = 0;
    this._currentTime = 0;
    this._startTime = performance.now();
    this._delta = 0;
    this._elapsed = 0;
  }

  connect(document) {
    // Use Page Visibility API to avoid jumps when tab inactive
    document.addEventListener('visibilitychange',
      handleVisibilityChange.bind(this));
  }

  update(timestamp) {
    if (this._document.hidden === true) {
      this._delta = 0;
    } else {
      this._previousTime = this._currentTime;
      this._currentTime = (timestamp !== undefined ? timestamp :
        performance.now()) - this._startTime;
      this._delta = (this._currentTime - this._previousTime) *
        this._timescale;
      this._elapsed += this._delta;
    }
    return this;
  }

  getDelta() {
    return this._delta / 1000;  // Convert ms to seconds
  }
}
```

**Why Timer over Clock?**:
- Allows multiple calls to `getDelta()` per frame (returns same value)
- Handles page visibility API natively (prevents jumps)
- Cleaner API design

## 6. Property Binding & Morph Targets

### 6.1 PropertyBinding Architecture

**File**: `src/animation/PropertyBinding.js` (600+ lines)

**Purpose**: Maps animation clip tracks to actual scene graph properties.

**Track Name Format** (regex-based path):
```
nodeName.property
nodeName.property[accessor]
nodeName.material.property
uuid.objectName[index].property
Head_4.morphTargetInfluences[0]  ← Example for morph targets
Armature/Bone.quaternion
```

**Example**: Animating skeleton bones
```
Track name: "Armature/Armature.004_Bone.quaternion"
→ PropertyBinding finds Bone object
→ Binds track values to bone.quaternion property
→ AnimationMixer applies quaternion values each frame
```

**For Morph Targets**:
```
Track name: "Head_4.morphTargetInfluences[0]"
→ Finds Head_4 mesh
→ Binds track values to morphTargetInfluences array element 0
→ Values [0, 1] control blend between base geometry and morph target
```

### 6.2 Direct Morph Target Control (GUI approach)

The example uses **manual UI control** for expressions, NOT animation clips:

```javascript
face = model.getObjectByName('Head_4');
const expressions = Object.keys(face.morphTargetDictionary);
// expressions = ['smile', 'surprised', ...]

for (let i = 0; i < expressions.length; i++) {
  expressionFolder.add(face.morphTargetInfluences, i, 0, 1, 0.01)
    .name(expressions[i]);
}
```

**How it works**:
- `face.morphTargetDictionary` — Maps name → index
  - Example: `{ smile: 0, surprised: 1, angry: 2 }`
- `face.morphTargetInfluences` — Float32Array of weights
  - Direct manipulation: `face.morphTargetInfluences[0] = 0.5` → 50% smile
- lil-gui binds UI slider → array element → automatic GPU update

## 7. The Animate Loop

**Lines 254-266**:

```javascript
function animate() {
  timer.update();
  const dt = timer.getDelta();

  if (mixer) mixer.update(dt);

  renderer.render(scene, camera);
  stats.update();
}

renderer.setAnimationLoop(animate);
```

**Frame-by-Frame Flow**:
1. **Timer.update()** — Compute delta time (ms → seconds)
2. **Mixer.update(dt)** — Update all active actions
   - Sample keyframes for current time
   - Blend all animations
   - Apply to scene graph
3. **Renderer.render()** — Draw frame
4. **Stats.update()** — Update FPS counter

## 8. The Crossfade Pattern (fadeToAction)

**Lines 223-241**:

```javascript
function fadeToAction(name, duration) {
  previousAction = activeAction;
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

// Called via:
api.state = 'Walking';
clipCtrl.onChange(() => fadeToAction(api.state, 0.5));
```

**Smooth Transition**:
- Old action: weight 1 → 0 (over 0.5s)
- New action: weight 0 → 1 (over 0.5s)
- Both active during transition → blended output
- Mixer's PropertyMixer accumulates: `result = old*wOld + new*wNew`

## 9. RobotExpressive Model Structure

**Source**: `examples/models/gltf/RobotExpressive/RobotExpressive.glb`

**Original Creator**: Tomás Laulhé (CC0, Patreon)
**Modifications**: Don McCurdy
- Added 3 facial expression morph targets
- Converted from FBX to GLTF via FBX2GLTF
- Optimized materials (reduced metalness, removed duplicates)

**Animation Clips Included**:
- **States** (7): Idle, Walking, Running, Dance, Death, Sitting, Standing
- **Emotes** (6): Jump, Yes, No, Wave, Punch, ThumbsUp
- **Skeleton**: Armature with bones for skeletal animation
- **Mesh**: SkinnedMesh with skin weights + morph targets

**3-Layer Animation System**:

| Layer | System | Control | Animation Clip? | Examples |
|-------|--------|---------|-----------------|----------|
| **Locomotion** | Skeleton (FK/IK) | AnimationAction | Yes | Walking, Running |
| **Emotes** | Skeleton (full body) | AnimationAction | Yes | Wave, Punch |
| **Expressions** | Morph Targets | Direct UI | No | Smile, Surprised |

All 3 layers can blend independently via additive blending or normal blend mode.

## 10. Summary: Data Flow

```
Timer.update()
  ↓ (computes deltaTime)
Mixer.update(deltaTime)
  ↓ (for each active action)
    AnimationAction._update(time, deltaTime)
      ↓
      Interpolant.evaluate(clipTime)  ← Sample keyframes
        ↓
      PropertyMixer.accumulate(weight)  ← Blend values
        ↓
    PropertyBinding.apply()  ← Write to scene graph
      ↓
Renderer.render(scene, camera)
  ↓ (GPU reads morphTargetInfluences, bone transforms)
Visual output
```

**Key Insight**: The animation system is **property-agnostic**. It works equally well for:
- Bone rotations (skeleton animation)
- Morph target weights (facial expressions)
- Camera position/rotation
- Material properties
- Any numeric/vector property in the scene graph

---

**Document by**: Oracle Learning System
**Cloned from**: https://github.com/mrdoob/three.js
**Study Focus**: Understanding how Three.js coordinates skeletal animation (skinning), morph targets, and state machines through a single unified AnimationMixer system.
