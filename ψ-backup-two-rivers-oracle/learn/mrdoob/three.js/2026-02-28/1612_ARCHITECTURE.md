# Three.js `webgl_animation_skinning_morph` Architecture

## Overview

This example demonstrates a sophisticated character animation system combining three independent animation layers:

1. **Skeletal Animation** — Rigged character with bone-driven locomotion (walking, running, dancing)
2. **One-Shot Emotes** — Single-play animations that interrupt state and restore (jump, yes, no, wave, punch, thumbs up)
3. **Morph Target Expressions** — Real-time facial animations applied independently to the Head mesh

The system uses `AnimationMixer` as a state machine with smooth crossfading between animation clips, and `lil-gui` controls for interactive switching.

---

## Architecture Layers

```
┌─────────────────────────────────────────────────────┐
│  Morph Targets (Expressions Layer)                  │
│  Independent of skeletal animation                  │
│  Real-time morphTargetInfluences updates            │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  Animation Mixer (Skeletal Animation Layer)         │
│  Body States + Emotes (Walking, Dance, Jump, etc)   │
│  Crossfading system for smooth transitions          │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  Scene & Rendering (Three.js Core)                  │
│  Camera, Lights, GLTF Model, WebGL Renderer         │
└─────────────────────────────────────────────────────┘
```

---

## Initialization Pipeline

### 1. `init()` — Scene Setup

```javascript
init()
├── Create container (DOM)
├── Setup camera (PerspectiveCamera, 45°, -5, 3, 10)
├── Create scene (background, fog)
├── Initialize Timer (for delta time)
├── Add lights
│   ├── HemisphereLight (ambient)
│   └── DirectionalLight (shadows/fill)
├── Add floor + grid
├── Load GLTF model asynchronously
│   └── Call createGUI(model, animations)
├── Setup WebGL renderer
└── Attach event listeners (resize)
```

**Key Detail**: The GLTF loader is asynchronous. `createGUI()` is only called when the model + animations are fully loaded.

---

## Animation System Architecture

### 2. `createGUI()` — Animation Preparation

This function constructs the three-layer animation system:

#### Layer 1: State Animations (Looping)

```javascript
states = ['Idle', 'Walking', 'Running', 'Dance', 'Death', 'Sitting', 'Standing']

// Properties:
- clampWhenFinished: false (looping)
- loop: THREE.LoopRepeat (default)
```

These are **continuous, looping** animations. Only one is active at a time. Switching between them uses `fadeToAction()` with smooth crossfading.

#### Layer 2: Emote Animations (One-Shot)

```javascript
emotes = ['Jump', 'Yes', 'No', 'Wave', 'Punch', 'ThumbsUp']

// Properties:
- clampWhenFinished: true (holds final frame)
- loop: THREE.LoopOnce (plays once, stops)
```

When an emote is triggered:
1. Fade out the current state animation
2. Fade in and play the emote
3. Listen for `mixer.addEventListener('finished', ...)`
4. Restore the previous state animation

```javascript
function createEmoteCallback(name) {
  api[name] = function() {
    fadeToAction(name, 0.2);                    // Play emote
    mixer.addEventListener('finished', restoreState);  // Listen
  };
}

function restoreState() {
  mixer.removeEventListener('finished', restoreState);
  fadeToAction(api.state, 0.2);                 // Restore state
}
```

#### Layer 3: Morph Target Expressions (Continuous)

```javascript
face = model.getObjectByName('Head_4');  // Get head mesh
expressions = Object.keys(face.morphTargetDictionary);

// Create GUI slider for each expression
for (let i = 0; i < expressions.length; i++) {
  expressionFolder.add(
    face.morphTargetInfluences,   // Reference to influences array
    i,                             // Array index (expression ID)
    0, 1,                          // Min/max (0 = off, 1 = max)
    0.01                           // Step size
  ).name(expressions[i]);          // Label from GLTF metadata
}
```

**Key Design**: Morph targets are **completely independent** from skeletal animation. A character can walk AND smile simultaneously because:
- Skeletal animation modifies **bone transforms**
- Morph targets modify **vertex positions** in the Head mesh

They operate on different data structures and can coexist without conflict.

---

### 3. Animation Crossfading System

#### The `fadeToAction()` Function

```javascript
function fadeToAction(name, duration) {
  previousAction = activeAction;        // Remember old action
  activeAction = actions[name];         // Switch to new action

  if (previousAction !== activeAction) {
    previousAction.fadeOut(duration);   // Smooth exit over N seconds
  }

  // Smooth entry + play
  activeAction
    .reset()                            // Start from frame 0
    .setEffectiveTimeScale(1)           // 1x speed
    .setEffectiveWeight(1)              // 100% influence
    .fadeIn(duration)                   // Smooth entry over N seconds
    .play();
}
```

**Why This Works**:
- `fadeOut()` and `fadeIn()` are built into Three.js `AnimationAction`
- Two actions can be active simultaneously during a crossfade
- The mixer blends their influence values (0→1 range)
- Creates smooth visual transition (no pop/jump)

**Crossfade Durations**:
- States → States: `0.5s` (slower, more weight change)
- States → Emotes: `0.2s` (faster, need quick response)

---

## Data Flow Diagram

```
GLTF Model (RobotExpressive.glb)
│
├── Skeleton (Bones)
│   └── Armature
│       ├── Root
│       ├── Spine
│       ├── Arm.L / Arm.R
│       └── Leg.L / Leg.R
│
├── Animation Clips (from GLTF)
│   ├── Walking (0.0–2.5s)
│   ├── Running (0.0–2.5s)
│   ├── Dance (0.0–3.0s)
│   ├── Jump (0.0–0.5s) ← emote
│   └── ... (20+ total clips)
│
└── Mesh "Head_4"
    └── morphTargetDictionary
        ├── "browDown_L"
        ├── "eyeBlinkLeft"
        ├── "mouthSmile"
        └── ... (50+ expressions)
```

**Runtime Flow**:

```
User Input (GUI)
│
├─ Change State Dropdown
│  └─> fadeToAction("Walking", 0.5)
│      └─> AnimationMixer blends clips + updates bones
│          └─> Renderer draws updated skeleton pose
│
├─ Click Jump Button
│  └─> fadeToAction("Jump", 0.2)
│      └─> Play Jump animation
│      └─> Listen for 'finished' event
│          └─> (Jump completes)
│              └─> fadeToAction("Walking", 0.2)
│
└─ Move Smile Slider
   └─> face.morphTargetInfluences[5] = 0.75
       └─> Renderer blends vertex positions on Head
           └─> Character smiles (independent of body animation)
```

---

## Core Dependencies

### Three.js Core
- **PerspectiveCamera** — View frustum (45° FOV)
- **Scene** — World container with fog
- **WebGLRenderer** — Rasterizer (antialias enabled)
- **Timer** — Provides delta time for animation

### Animation System
- **AnimationMixer** — Plays clips, manages state transitions, blends influences
- **AnimationAction** — Individual clip instance with play/fadeIn/fadeOut
- **AnimationClip** — Pre-baked animation data from GLTF

### Loaders
- **GLTFLoader** — Deserializes binary/JSON + texture embedding, returns:
  - `gltf.scene` — Full hierarchy (skeleton + meshes)
  - `gltf.animations` — Array of AnimationClips

### UI
- **lil-gui** — Creates folders + controls (dropdowns, buttons, sliders)

---

## The Animate Loop

```javascript
function animate() {
  timer.update();           // Tick system clock
  const dt = timer.getDelta();  // Elapsed time since last frame

  if (mixer) {
    mixer.update(dt);       // Step all active AnimationActions
                            // Updates bone transforms
                            // Evaluates animation curves at current time
                            // Blends overlapping actions
  }

  renderer.render(scene, camera);  // Draw the current pose
  stats.update();           // FPS counter
}
```

**Critical**: `mixer.update(dt)` is called every frame. This is what makes animation happen:
1. Each `AnimationAction` advances its internal time
2. It reads keyframes from its clip
3. It writes transforms to bones (via skeletal binding)
4. If two actions are active, their influences are blended
5. The skeleton is updated, and the mesh deforms accordingly

---

## Why This Architecture Works

### Separation of Concerns

| Layer | Owns | Updates | Frequency |
|-------|------|---------|-----------|
| **Skeletal** | Bone transforms | Every frame via mixer | Per-frame |
| **Emotes** | Clip selection + state machine | On user click | Event-driven |
| **Expressions** | morphTargetInfluences array | On slider change | Real-time user input |

Each layer can be modified independently without affecting others.

### Scalability

- **Add a new state**: Create a new AnimationClip in the GLTF → it's automatically available
- **Add a new emote**: Same — just add to emotes array and it works
- **Add facial features**: Just add to `morphTargetDictionary` in the GLTF
- **No hard-coded animation logic** — Everything is data-driven from the GLTF file

### Smooth Interactions

- Crossfading prevents animation pops
- Emote restoration is event-driven (not time-based), so emotes always complete fully
- Morph targets update in real-time, allowing animation + expression to run in parallel

---

## Key Insights

### 1. AnimationMixer is a Scheduler, Not a Player

It doesn't *play* animations like a video player. It:
- Tracks which clips are active
- Evaluates keyframe curves at the current time
- Blends overlapping actions by multiplying influence weights
- Updates the target (the model) with the blended result

### 2. Morph Targets are Separate

They're not in the animation system at all. They're just properties on a mesh:

```javascript
// Skeletal animation: changes bone[5].position, bone[5].quaternion
// Morph target: changes mesh.morphTargetInfluences[5] (0.0–1.0)
// Both affect how the mesh is rendered, but via different pathways
```

### 3. The Emote Pattern

Emotes use a clever pattern:
- One-shot clips that hold their final frame
- Event listener that detects completion
- Automatic state restoration

This decouples emote playback from the main state machine. The character can jump without the GUI dropdown changing.

### 4. Timer.getDelta() is Essential

Without delta time, animation would be framerate-dependent:

```javascript
// Bad (framerate-dependent):
animationTime += 0.016;  // Assumes 60 FPS

// Good (framerate-independent):
animationTime += deltaTime;  // Works at any FPS
```

---

## File Structure Summary

```
RobotExpressive.glb (Khronos GLTF format)
├── Binary buffer (geometry, skeleton data)
├── 20+ named AnimationClips
│   ├── Idle, Walking, Running, Dance... (looping)
│   └── Jump, Yes, No, Wave... (one-shot)
├── 1 Armature with skeleton hierarchy
└── Head_4 mesh with ~50 morph targets
    └── morphTargetDictionary maps names → indices
```

---

## References & Learning Paths

**Next Steps**:
1. **Load your own GLTF** — Export from Blender with animations and morph targets
2. **Extend the emote system** — Add emote queuing (jump → wave → sit)
3. **Blend multiple states** — Use `setEffectiveWeight()` to layer walk + lean
4. **Export morph targets** — Rig a character with Blend Shapes in Blender
5. **Timing & sync** — Use `AnimationClip.duration` to choreograph sequences

---

## Document Metadata

- **Example**: `webgl_animation_skinning_morph`
- **Model**: RobotExpressive.glb (Khronos GLTF 2.0)
- **Key Classes**: AnimationMixer, AnimationAction, GLTFLoader, Timer, GUI
- **Pattern**: Three-layer animation state machine
- **Created**: 2026-02-28
