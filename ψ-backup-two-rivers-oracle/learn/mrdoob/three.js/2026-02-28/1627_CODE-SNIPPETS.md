# Three.js Animation Patterns: Skinning & Morphing

**Source:** `examples/webgl_animation_skinning_morph.html`
**Loaded:** 2026-02-28 · 16:27 GMT+7
**Model:** RobotExpressive (GLTF/GLB format)

---

## Overview

This document extracts **six core patterns** from Three.js's most complete animation example:

1. **GLTF Loading** — Async model + animation parsing
2. **AnimationMixer Setup** — Pre-instantiate all actions
3. **Crossfade Function** — `fadeToAction()` with weight blending
4. **Emote Pattern** — One-shot play + finish listener restore
5. **Morph Target Control** — Direct influence access
6. **Timer + Animate Loop** — Frame-independent updates

Each pattern includes:
- Full source code (verbatim from Three.js)
- How it works internally
- How to reuse it (hand-tracking, MQTT, etc.)

---

## 1. GLTF Loading Pattern

Load a model + all embedded animations in one async call.

### Source Code

```javascript
const loader = new GLTFLoader();
loader.load( 'models/gltf/RobotExpressive/RobotExpressive.glb',
  function ( gltf ) {
    // gltf.scene = Three.js scene graph (Object3D)
    // gltf.animations = Array<AnimationClip> with all embedded clips
    model = gltf.scene;
    scene.add( model );
    createGUI( model, gltf.animations );
  },
  undefined,  // onProgress callback (optional)
  function ( e ) {
    console.error( e );
  }
);
```

### How It Works

- **GLTFLoader** extends `Loader` base class
- Calls `load()` with three callbacks: `onLoad`, `onProgress`, `onError`
- Returns **parsed GLTF object** with:
  - `gltf.scene` — Complete scene graph with meshes, bones, lights
  - `gltf.animations` — Array of `AnimationClip` objects
  - `gltf.cameras`, `gltf.lights` — Optional scene elements
- **Blocking:** Loader automatically manages XHR, texture loading, DRACO decompression

### Internal Structure (AnimationClip)

```javascript
class AnimationClip {
  constructor( name = '', duration = -1, tracks = [] ) {
    this.name = 'Walking';        // Clip name (e.g., 'Idle', 'Jump')
    this.tracks = [ ... ];         // Array<KeyframeTrack>
    this.duration = 2.4;           // Seconds
    this.uuid = generateUUID();    // Unique ID
    this.userData = {};            // Custom data
  }
}
```

Each **track** controls one property path (e.g., `Armature.Bone.position.x`).

### Reuse: Hand-Tracking / MQTT

For hand-tracking that loads dynamic models:

```javascript
// Async pattern with Promise
const gltf = await loader.loadAsync( 'models/hand.glb' );
const handModel = gltf.scene;

// Extract animations
const animations = gltf.animations; // [ 'Point', 'Pinch', 'Open' ]

// For MQTT: Load model once, replay clips based on topic
mqttClient.subscribe( 'hand/gesture' );
mqttClient.on( 'message', ( topic, buffer ) => {
  const gesture = buffer.toString(); // 'Point', 'Pinch', etc.
  if ( animations.find( a => a.name === gesture ) ) {
    fadeToAction( gesture, 0.3 );
  }
});
```

---

## 2. AnimationMixer Setup

Create a mixer and pre-instantiate all actions at init time (not on-demand).

### Source Code

```javascript
function createGUI( model, animations ) {
  const states = [ 'Idle', 'Walking', 'Running', 'Dance', 'Death', 'Sitting', 'Standing' ];
  const emotes = [ 'Jump', 'Yes', 'No', 'Wave', 'Punch', 'ThumbsUp' ];

  // 1. Create mixer for this model
  mixer = new THREE.AnimationMixer( model );

  // 2. Pre-instantiate all actions from clips
  actions = {};
  for ( let i = 0; i < animations.length; i ++ ) {
    const clip = animations[ i ];
    const action = mixer.clipAction( clip );  // Create action from clip
    actions[ clip.name ] = action;            // Store in dictionary

    // 3. Configure loop mode per action
    if ( emotes.indexOf( clip.name ) >= 0 || states.indexOf( clip.name ) >= 4 ) {
      // One-shot animations (emotes + Death/Sitting/Standing)
      action.clampWhenFinished = true;   // Hold last frame when done
      action.loop = THREE.LoopOnce;      // Play once, don't repeat
    }
    // else: default is THREE.LoopRepeat
  }
}
```

### How It Works

- **AnimationMixer** — Engine that plays clips on a specific object
  - Constructor takes root `Object3D` to animate
  - One mixer per animated model
- **clipAction()** — Creates an **AnimationAction** for a clip
  - Returns same action object if called twice with same clip (cached)
  - Action holds playback state: time, weight, speed, loop mode
- **Loop Modes:**
  - `LoopRepeat` — Loop infinitely (default for states)
  - `LoopOnce` — Play once, stop
  - `LoopPingPong` — Loop backwards + forwards
- **clampWhenFinished** — When `LoopOnce` finishes, **hold pose** (don't reset)

### AnimationAction Properties

```javascript
// Key properties set at init
action.loop = THREE.LoopOnce;           // Don't repeat
action.clampWhenFinished = true;        // Hold last frame
action.zeroSlopeAtStart = true;         // Smooth start interpolation
action.zeroSlopeAtEnd = true;           // Smooth end interpolation
action.weight = 1;                       // Influence (0=none, 1=full)
action.timeScale = 1;                    // Playback speed (1=normal)
action.paused = false;                   // Is paused?
action.enabled = true;                   // Is active?
```

### Reuse: Multi-Body Animation

For hand-tracking with separate models (hand, head, body):

```javascript
// Create separate mixers
const handMixer = new THREE.AnimationMixer( handModel );
const headMixer = new THREE.AnimationMixer( headModel );
const bodyMixer = new THREE.AnimationMixer( bodyModel );

// Pre-instance actions
const handActions = {};
gltfHand.animations.forEach( clip => {
  handActions[ clip.name ] = handMixer.clipAction( clip );
});

// Update all mixers in animate loop
function animate() {
  const dt = timer.getDelta();
  handMixer.update( dt );
  headMixer.update( dt );
  bodyMixer.update( dt );
  renderer.render( scene, camera );
}
```

---

## 3. Crossfade Function: fadeToAction()

Smoothly transition between animations with weight blending.

### Source Code

```javascript
function fadeToAction( name, duration ) {
  previousAction = activeAction;
  activeAction = actions[ name ];

  if ( previousAction !== activeAction ) {
    // Fade out old animation
    previousAction.fadeOut( duration );
  }

  // Reset, configure, and play new animation
  activeAction
    .reset()                          // time = 0, loopCount = -1
    .setEffectiveTimeScale( 1 )       // Play at normal speed
    .setEffectiveWeight( 1 )          // Full influence
    .fadeIn( duration )               // Gradually increase weight 0→1
    .play();                          // Start playback
}
```

**Called from:**
```javascript
// State change (looping animations)
const clipCtrl = statesFolder.add( api, 'state' ).options( states );
clipCtrl.onChange( function () {
  fadeToAction( api.state, 0.5 );  // 0.5 second fade
});
```

### How It Works

#### fadeOut(duration)
```javascript
// Internal: schedules weight interpolation 1 → 0 over duration
previousAction.fadeOut( 0.5 );
// After 0.5s, action.weight will be 0 (no influence)
```

#### reset()
```javascript
// Resets internal playback state
this.paused = false;
this.enabled = true;
this.time = 0;           // Start from frame 0
this._loopCount = -1;    // Forget previous loops
this._startTime = null;  // Forget scheduling
```

#### fadeIn(duration)
```javascript
// Schedules weight interpolation 0 → 1 over duration
this.fadeIn( 0.5 );
// After 0.5s, action.weight will be 1 (full influence)
```

#### play()
```javascript
// Activates action: binds property tracks to scene objects
// Starts updating in mixer.update()
this._mixer._activateAction( this );
```

### Timeline Example

```
Time:     0ms        250ms       500ms
          ├─────────┬───────────┤
Walking:  1.0       0.5         0.0  ← fadeOut
Running:  0.0       0.5         1.0  ← fadeIn

Result:   100%      50/50 blend  0%
          Walking   (both)       Running
```

### Reuse: Smooth Hand Gesture Transitions

```javascript
// Hand switches from 'Open' to 'Point'
// Smoothly blend over 0.2 seconds
function switchHandGesture( newGesture ) {
  const fadeDuration = 0.2;
  fadeToAction( newGesture, fadeDuration );
}

// Called on MQTT message
mqttClient.on( 'message', ( topic, gesture ) => {
  if ( topic === 'hand/gesture' ) {
    switchHandGesture( gesture );
  }
});
```

---

## 4. Emote Pattern: One-Shot + Finish Listener

Play an animation once, then restore the previous looping state.

### Source Code

```javascript
function createEmoteCallback( name ) {
  api[ name ] = function () {
    // 1. Play one-shot emote with quick fade
    fadeToAction( name, 0.2 );

    // 2. Listen for finish event
    mixer.addEventListener( 'finished', restoreState );
  };

  emoteFolder.add( api, name );
}

function restoreState() {
  // 3. Remove listener to avoid stacking
  mixer.removeEventListener( 'finished', restoreState );

  // 4. Fade back to the original looping state
  fadeToAction( api.state, 0.2 );
}
```

**Called from GUI:**
```javascript
const emoteFolder = gui.addFolder( 'Emotes' );

for ( let i = 0; i < emotes.length; i ++ ) {
  createEmoteCallback( emotes[ i ] );
}
// emoteFolder now has buttons: [ Jump ] [ Yes ] [ No ] [ Wave ] [ Punch ] [ ThumbsUp ]
```

### How It Works

1. **fadeToAction( 'Jump', 0.2 )** — Play emote with 0.2s blend-in
2. **loop === LoopOnce** + **clampWhenFinished === true** — Play once, hold last frame
3. **mixer.addEventListener( 'finished' )** — Mixer fires event when action completes
4. **Finish event fires** → **restoreState()** → **fadeToAction( api.state, 0.2 )** — Smoothly return to base state

### Finish Event Internals

The mixer dispatches a `'finished'` event at the end of a `LoopOnce` action:

```javascript
// Inside AnimationMixer._update()
if ( action.loop === LoopOnce && action._loopCount === 0 ) {
  this.dispatchEvent( { type: 'finished', action: action } );
}
```

### Reuse: Hand Gesture + Restore

```javascript
// Hand shows "OK" gesture, then returns to neutral
function showOKGesture() {
  const gestureTime = actions[ 'OK' ]._clip.duration; // e.g., 1.0 seconds

  fadeToAction( 'OK', 0.2 );
  mixer.addEventListener( 'finished', () => {
    mixer.removeEventListener( 'finished', restoreState );
    fadeToAction( 'Neutral', 0.2 );
  });
}

// Called from button or MQTT
mqttClient.on( 'message', ( topic, msg ) => {
  if ( msg === 'ok' ) showOKGesture();
});
```

---

## 5. Morph Target Control

Access and animate facial expressions via `morphTargetInfluences`.

### Source Code

```javascript
function createGUI( model, animations ) {
  // ... mixer + actions setup ...

  // 1. Find the mesh with morph targets (usually the head)
  face = model.getObjectByName( 'Head_4' );

  // 2. Get list of morph target names
  const expressions = Object.keys( face.morphTargetDictionary );
  // Result: [ 'Angry', 'Happy', 'Sad', 'Surprised', ... ]

  const expressionFolder = gui.addFolder( 'Expressions' );

  // 3. Create slider for each morph target
  for ( let i = 0; i < expressions.length; i ++ ) {
    expressionFolder.add(
      face.morphTargetInfluences,  // Target object
      i,                            // Array index
      0,                            // Min value
      1,                            // Max value
      0.01                          // Step size
    ).name( expressions[ i ] );    // UI label
  }

  expressionFolder.open();
}
```

### How It Works

#### morphTargetDictionary
Maps morph target names to indices:
```javascript
face.morphTargetDictionary = {
  'Angry': 0,
  'Happy': 1,
  'Sad': 2,
  'Surprised': 3
};
```

#### morphTargetInfluences
Array of weights (0-1) for each morph target:
```javascript
face.morphTargetInfluences = [ 0, 0, 0, 0 ];  // All neutral

// Set angry
face.morphTargetInfluences[ 0 ] = 0.8;  // 80% angry

// Blend sad + surprised
face.morphTargetInfluences[ 2 ] = 0.5;  // 50% sad
face.morphTargetInfluences[ 3 ] = 0.5;  // 50% surprised
```

#### GUI Integration
```javascript
// lil-gui creates sliders that directly modify the array
expressionFolder.add( face.morphTargetInfluences, 0, 0, 1, 0.01 )
  .name( 'Angry' );

// Moving slider → face.morphTargetInfluences[ 0 ] changes → GPU updates
```

### Morph Target Internals

When you load a GLTF with morph targets:
- **Geometry.morphAttributes** contains vertex positions for each target
- **GPU blends** based on `morphTargetInfluences` weights
- **Real-time:** No need to call update() — GPU does it automatically

### Reuse: Emotion Control from MQTT

```javascript
// Map MQTT emotion to morph weights
const emotionMap = {
  'happy': { 'Happy': 1.0 },
  'angry': { 'Angry': 1.0, 'Surprised': 0.3 },
  'sad': { 'Sad': 0.8, 'Happy': 0.0 },
  'neutral': {}
};

mqttClient.on( 'message', ( topic, emotion ) => {
  if ( topic === 'hand/emotion' ) {
    const weights = emotionMap[ emotion.toString() ] || {};

    // Zero all
    for ( let i = 0; i < face.morphTargetInfluences.length; i ++ ) {
      face.morphTargetInfluences[ i ] = 0;
    }

    // Set requested emotion
    Object.entries( weights ).forEach( ( [ name, weight ] ) => {
      const idx = face.morphTargetDictionary[ name ];
      if ( idx !== undefined ) {
        face.morphTargetInfluences[ idx ] = weight;
      }
    });
  }
});
```

Or **smooth interpolation** over time:

```javascript
class MorphController {
  constructor( mesh ) {
    this.mesh = mesh;
    this.targetInfluences = new Array( mesh.morphTargetInfluences.length ).fill( 0 );
    this.blendDuration = 0.5; // seconds
    this.blendStart = 0;
  }

  setExpression( name, weight ) {
    const idx = this.mesh.morphTargetDictionary[ name ];
    if ( idx !== undefined ) {
      this.targetInfluences[ idx ] = weight;
      this.blendStart = performance.now();
    }
  }

  update( dt ) {
    const elapsed = ( performance.now() - this.blendStart ) / 1000;
    const t = Math.min( elapsed / this.blendDuration, 1 );

    for ( let i = 0; i < this.mesh.morphTargetInfluences.length; i ++ ) {
      const current = this.mesh.morphTargetInfluences[ i ];
      const target = this.targetInfluences[ i ];
      this.mesh.morphTargetInfluences[ i ] = current + (target - current) * t;
    }
  }
}

// Usage
const morphCtrl = new MorphController( face );

mqttClient.on( 'message', ( topic, data ) => {
  const { emotion, intensity } = JSON.parse( data );
  morphCtrl.setExpression( emotion, intensity );
});

// In animate loop
function animate() {
  const dt = timer.getDelta();
  morphCtrl.update( dt );
  mixer.update( dt );
  renderer.render( scene, camera );
}
```

---

## 6. Timer + Animate Loop

Frame-independent animation updates using `Timer` and `requestAnimationFrame`.

### Source Code

```javascript
// Init
timer = new THREE.Timer();
timer.connect( document );  // Use Page Visibility API

renderer.setAnimationLoop( animate );

// Main loop
function animate() {
  timer.update();            // 1. Update timer with current timestamp
  const dt = timer.getDelta();  // 2. Get delta time in seconds

  if ( mixer ) mixer.update( dt );  // 3. Update animations

  renderer.render( scene, camera );  // 4. Render frame

  stats.update();            // 5. Update performance monitor
}
```

### Timer Class (Simplified)

```javascript
class Timer {
  constructor() {
    this._previousTime = 0;
    this._currentTime = 0;
    this._startTime = performance.now();
    this._delta = 0;
    this._timescale = 1;  // Can slow down / speed up time
  }

  getDelta() {
    return this._delta / 1000;  // Returns seconds
  }

  getElapsed() {
    return this._elapsed / 1000;  // Total elapsed since creation
  }

  setTimescale( timescale ) {
    this._timescale = timescale;  // 1.0 = normal, 0.5 = half speed, 2.0 = double
  }

  update( timestamp ) {
    if ( /* tab hidden */ ) {
      this._delta = 0;  // Avoid large jumps when returning
    } else {
      this._previousTime = this._currentTime;
      this._currentTime = (timestamp ?? performance.now()) - this._startTime;
      this._delta = (this._currentTime - this._previousTime) * this._timescale;
      this._elapsed += this._delta;
    }
    return this;
  }

  connect( document ) {
    // Listen for visibility changes
    // If tab becomes hidden then visible, reset time to avoid jump
  }
}
```

### AnimationMixer.update(deltaTime)

```javascript
update( deltaTime ) {
  deltaTime *= this.timeScale;  // Global mixer speed control

  const actions = this._actions;
  const nActions = this._nActiveActions;
  const time = this.time += deltaTime;  // Accumulate global time

  // Update all active actions
  for ( let i = 0; i !== nActions; ++ i ) {
    const action = actions[ i ];
    action._update( time, deltaTime, Math.sign( deltaTime ), accuIndex );
  }

  // Apply all property bindings (update scene objects)
  const bindings = this._bindings;
  for ( let i = 0; i !== nBindings; ++ i ) {
    bindings[ i ].apply( accuIndex );
  }

  return this;
}
```

### Timeline Example

```
requestAnimationFrame callback ──┬─ time: 1234.5ms
                                  │
  ├─ timer.update( 1234.5 )
  │    │ _previousTime = 1200
  │    │ _currentTime = 1234.5
  │    │ _delta = 34.5ms
  │
  ├─ dt = timer.getDelta() = 0.0345 seconds
  │
  ├─ mixer.update( 0.0345 )
  │    │ time += 0.0345
  │    │ action.time += 0.0345
  │    │ Keyframe interpolation
  │    │ Update skeleton bones
  │
  ├─ renderer.render()
  │    │ Apply transforms
  │    │ Draw frame
  │
  └─ Frame complete ✓
```

### Reuse: Hand Tracking with Real-Time Updates

```javascript
// Timer handles frame timing
const timer = new THREE.Timer();
const handMixer = new THREE.AnimationMixer( handModel );
const morphCtrl = new MorphController( face );

// MQTT updates state
let currentGesture = 'Neutral';
let handRotation = { x: 0, y: 0, z: 0 };
let emotion = 'neutral';

mqttClient.on( 'message', ( topic, buffer ) => {
  const msg = JSON.parse( buffer.toString() );

  if ( topic === 'hand/gesture' ) {
    currentGesture = msg.gesture;
    fadeToAction( currentGesture, 0.2 );
  }
  if ( topic === 'hand/rotation' ) {
    handRotation = msg;  // { x, y, z } in radians
  }
  if ( topic === 'face/emotion' ) {
    emotion = msg.emotion;
    morphCtrl.setExpression( emotion, 1.0 );
  }
});

// Animation loop
renderer.setAnimationLoop( ( timestamp ) => {
  timer.update( timestamp );
  const dt = timer.getDelta();

  // 1. Update animations
  handMixer.update( dt );
  morphCtrl.update( dt );

  // 2. Apply MQTT hand rotation
  handModel.rotation.x = handRotation.x;
  handModel.rotation.y = handRotation.y;
  handModel.rotation.z = handRotation.z;

  // 3. Render
  renderer.render( scene, camera );
  stats.update();
});
```

### Performance Notes

- **Timer + getDelta()** — Handles multi-frame consistency
  - Can call `getDelta()` multiple times per frame, gets same value
  - Different from old `Clock` which required special handling
- **Page Visibility API** — Prevents animation jumps when tab is hidden
  - When returning to tab: `delta = 0` (no jump)
  - Otherwise large `delta` would cause animation to skip ahead
- **timeScale** — Global slowmo / speedup
  ```javascript
  mixer.timeScale = 0.5;  // Slow motion
  timer.setTimescale( 2.0 );  // Speed up all time
  ```

---

## Summary Table

| Pattern | Use Case | Key Classes | Return Type |
|---------|----------|-------------|------------|
| GLTF Load | Load model + clips | `GLTFLoader` | Promise `{ scene, animations, ... }` |
| Mixer Setup | Create & cache actions | `AnimationMixer`, `AnimationAction` | `void` |
| Crossfade | Smooth transitions | `action.fadeOut()`, `.fadeIn()`, `.reset()` | `AnimationAction` (chainable) |
| Emote | One-shot + restore | `loop = LoopOnce`, `'finished'` event | `void` + event listener |
| Morph Targets | Facial expressions | `mesh.morphTargetInfluences[]` | Direct array mutation |
| Timer Loop | Frame timing | `Timer.getDelta()`, `mixer.update()` | `number` (delta seconds) |

---

## Integration Example: Complete Hand + Face System

```javascript
import * as THREE from 'three';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';
import { GUI } from 'three/addons/libs/lil-gui.module.min.js';

let scene, camera, renderer, timer;
let handMixer, faceMixer;
let handActions = {}, faceActions = {};
let morphCtrl;

async function init() {
  // Setup scene
  scene = new THREE.Scene();
  camera = new THREE.PerspectiveCamera( 60, window.innerWidth / window.innerHeight, 0.1, 1000 );
  renderer = new THREE.WebGLRenderer( { antialias: true } );
  renderer.setSize( window.innerWidth, window.innerHeight );
  document.body.appendChild( renderer.domElement );

  // Load models
  const loader = new GLTFLoader();

  const handGltf = await loader.loadAsync( 'models/hand.glb' );
  const handModel = handGltf.scene;
  scene.add( handModel );

  const faceGltf = await loader.loadAsync( 'models/face.glb' );
  const faceModel = faceGltf.scene;
  scene.add( faceModel );

  // Setup mixers
  handMixer = new THREE.AnimationMixer( handModel );
  faceMixer = new THREE.AnimationMixer( faceModel );

  // Pre-instance hand actions
  handGltf.animations.forEach( clip => {
    const action = handMixer.clipAction( clip );
    action.clampWhenFinished = true;
    handActions[ clip.name ] = action;
  });

  // Pre-instance face actions
  faceGltf.animations.forEach( clip => {
    const action = faceMixer.clipAction( clip );
    action.clampWhenFinished = true;
    faceActions[ clip.name ] = action;
  });

  // Morph targets
  const faceGeometry = faceModel.children[0]; // Assuming first child is face mesh
  morphCtrl = new MorphController( faceGeometry );

  // Timer
  timer = new THREE.Timer();
  timer.connect( document );

  // Start loop
  renderer.setAnimationLoop( animate );

  // Setup MQTT
  setupMQTT();
}

function fadeToAction( mixer, actions, name, duration = 0.3 ) {
  const action = actions[ name ];
  if ( !action ) return;

  // Find current action and fade out
  const currentActions = Object.values( actions ).filter( a => a.isRunning() );
  currentActions.forEach( a => {
    if ( a !== action ) a.fadeOut( duration );
  });

  action.reset().fadeIn( duration ).play();
}

function setupMQTT() {
  // Mock MQTT for demo
  window.mqtt = {
    publish: ( topic, data ) => {
      console.log( topic, data );
    }
  };

  // Simulate MQTT messages
  window.setInterval( () => {
    const gestures = [ 'Open', 'Point', 'Pinch' ];
    const gesture = gestures[ Math.floor( Math.random() * 3 ) ];
    fadeToAction( handMixer, handActions, gesture, 0.2 );
  }, 3000 );
}

function animate() {
  timer.update();
  const dt = timer.getDelta();

  handMixer.update( dt );
  faceMixer.update( dt );
  morphCtrl.update( dt );

  renderer.render( scene, camera );
}

init();
```

---

## Resources

- **Three.js Docs:** https://threejs.org/docs
- **AnimationMixer:** https://threejs.org/docs/#api/en/animation/AnimationMixer
- **AnimationAction:** https://threejs.org/docs/#api/en/animation/AnimationAction
- **GLTFLoader:** https://threejs.org/docs/#examples/en/loaders/GLTFLoader
- **Timer:** https://threejs.org/docs/#api/en/core/Timer
- **GLTF Format:** https://www.khronos.org/gltf/
