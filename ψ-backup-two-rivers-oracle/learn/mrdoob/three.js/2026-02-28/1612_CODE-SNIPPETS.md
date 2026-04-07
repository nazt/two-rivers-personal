# Three.js `webgl_animation_skinning_morph` — Code Snippets

**Example**: [webgl_animation_skinning_morph](https://threejs.org/examples/?q=skinning#webgl_animation_skinning_morph)
**Pattern Focus**: GLTF model loading, skeletal animation, morph targets, expression control
**Documented**: 2026-02-28

---

## 1. GLTF Loading + Animation Setup

### The Pattern

```javascript
const loader = new GLTFLoader();
loader.load('models/gltf/RobotExpressive/RobotExpressive.glb', function(gltf) {
  model = gltf.scene;
  scene.add(model);

  // Extract animation clips from the loaded model
  const animations = gltf.animations;
  mixer = new THREE.AnimationMixer(model);

  // Store clip data for later reference
  clipControls = {};
  for (let clip of animations) {
    clipControls[clip.name] = clip;
  }
});
```

### What It Does

- Uses `GLTFLoader` to load a 3D model with embedded animations from a `.glb` file
- Extracts all `AnimationClip` objects from the loaded model (`gltf.animations`)
- Adds the model to the scene
- Creates an `AnimationMixer` to manage playback of multiple animations on the same model

### Why It's Useful

- **Standardized format**: GLTF is the web standard for 3D models with animations, materials, and embeddings
- **Baked animations**: All animations are included in the file — no separate JSON files to manage
- **Mixer attachment**: One mixer per model enables complex, multi-animation control (crossfading, blending)

### How to Reuse It

**Basic loading**:
```javascript
const loader = new GLTFLoader();
loader.load('path/to/your-model.glb', onLoadSuccess, onProgress, onError);

function onLoadSuccess(gltf) {
  const model = gltf.scene;
  scene.add(model);
  return gltf.animations;
}
```

**Adapt for different models**:
- Change `'models/gltf/RobotExpressive/RobotExpressive.glb'` to your model path
- If model is in `.gltf` + separate `.bin`, loader handles it automatically
- Use `gltf.scene.scale.set(1, 1, 1)` to adjust size if needed

**For hand-tracking or MQTT-driven control**:
```javascript
// Load once at init, store animations globally
let globalAnimations = {};
loader.load(modelPath, (gltf) => {
  globalAnimations = gltf.animations.reduce((acc, clip) => {
    acc[clip.name] = clip;
    return acc;
  }, {});
});

// Later: trigger from external event (MQTT, hand pose, etc)
function handleExternalEvent(animationName) {
  if (globalAnimations[animationName]) {
    mixer.clipAction(globalAnimations[animationName]).play();
  }
}
```

---

## 2. AnimationMixer + Actions Map

### The Pattern

```javascript
mixer = new THREE.AnimationMixer(model);
actions = {};

const animations = gltf.animations;
for (let i = 0; i < animations.length; i++) {
  const clip = animations[i];
  const action = mixer.clipAction(clip);
  actions[clip.name] = action;

  // Configure one-shot animations (like facial expressions)
  if (emotes.indexOf(clip.name) >= 0) {
    action.clampWhenFinished = true;  // Stop at final frame
    action.loop = THREE.LoopOnce;     // Don't loop
  }

  // Configure looping animations (like idle/walk)
  if (walks.indexOf(clip.name) >= 0) {
    action.loop = THREE.LoopRepeat;   // Loop forever
  }
}
```

### What It Does

- Creates a **mixer** (the central controller for all animations on this model)
- **Pre-instantiates all actions** by creating an `Action` for each `AnimationClip`
- Stores actions in a dictionary (`actions[clip.name]`) for fast lookup
- Sets loop behavior based on animation type:
  - `LoopOnce` + `clampWhenFinished` = animation plays once, holds final frame
  - `LoopRepeat` = animation loops forever

### Why It's Useful

- **Pre-baked actions**: Creating actions on-demand (in response to events) causes stutters; pre-baking eliminates jank
- **Dictionary lookup**: Instead of searching for actions, `actions['WaveHand']` is instant
- **Unified control**: One mixer manages all animations, enabling smooth crossfades and blending
- **Type-based config**: Different animations have different needs (loops vs. one-shots); setting up front prevents bugs

### How to Reuse It

**Basic setup**:
```javascript
const mixer = new THREE.AnimationMixer(model);
const actions = {};

gltf.animations.forEach(clip => {
  actions[clip.name] = mixer.clipAction(clip);
});
```

**With categorization**:
```javascript
const mixer = new THREE.AnimationMixer(model);
const actions = {};
const loopingAnims = ['Idle', 'Walk', 'Run'];
const oneTimeAnims = ['Jump', 'Wave', 'Bow'];

gltf.animations.forEach(clip => {
  const action = mixer.clipAction(clip);

  if (oneTimeAnims.includes(clip.name)) {
    action.clampWhenFinished = true;
    action.loop = THREE.LoopOnce;
  } else if (loopingAnims.includes(clip.name)) {
    action.loop = THREE.LoopRepeat;
  }

  actions[clip.name] = action;
});
```

**For MQTT or sensor-driven animations**:
```javascript
// Store loop config externally
const animConfig = {
  'Gesture_Wave': { loop: THREE.LoopOnce, clampWhenFinished: true },
  'Gesture_Point': { loop: THREE.LoopOnce, clampWhenFinished: true },
  'Idle': { loop: THREE.LoopRepeat },
};

gltf.animations.forEach(clip => {
  const action = mixer.clipAction(clip);
  const config = animConfig[clip.name];
  if (config) {
    action.loop = config.loop;
    action.clampWhenFinished = config.clampWhenFinished;
  }
  actions[clip.name] = action;
});
```

---

## 3. Crossfade Between Actions

### The Pattern

```javascript
let previousAction = null;
let activeAction = null;

function fadeToAction(name, duration) {
  // Store the old action
  previousAction = activeAction;

  // Get the new action from the map
  activeAction = actions[name];

  // Only fade if switching to a different action
  if (previousAction !== activeAction) {
    previousAction.fadeOut(duration);
  }

  // Reset timing, set volume to full, fade in, and play
  activeAction.reset()
    .setEffectiveTimeScale(1)      // Normal speed
    .setEffectiveWeight(1)          // Full volume
    .fadeIn(duration)
    .play();
}
```

### What It Does

- **Stops** the previous animation (with fade-out for smoothness)
- **Resets** timing so the new animation starts from frame 0
- **Fades in** over `duration` seconds to avoid jarring transitions
- **Plays** the new animation

### Why It's Useful

- **Smooth transitions**: Blending out the old animation while fading in the new one creates fluid motion
- **No double-playing**: Check `previousAction !== activeAction` prevents an animation from fading into itself
- **Reusable**: Works for any animation by name; no hardcoding
- **Parameter control**: `duration` lets you vary transition speed (0.2s for quick, 0.5s for slow)

### How to Reuse It

**Basic crossfade**:
```javascript
function fadeToAction(name, duration) {
  const prev = activeAction;
  activeAction = actions[name];

  if (prev !== activeAction && prev) {
    prev.fadeOut(duration);
  }

  activeAction.reset().fadeIn(duration).play();
}

// Use it:
fadeToAction('Walk', 0.3);
```

**With speed and weight control**:
```javascript
function fadeToAction(name, duration, speed = 1, weight = 1) {
  const prev = activeAction;
  activeAction = actions[name];

  if (prev !== activeAction && prev) {
    prev.fadeOut(duration);
  }

  activeAction
    .reset()
    .setEffectiveTimeScale(speed)   // Run faster or slower
    .setEffectiveWeight(weight)     // Partial blending with other animations
    .fadeIn(duration)
    .play();
}

// Slow walk, full weight:
fadeToAction('Walk', 0.3, 0.5, 1.0);
```

**For gesture/event-driven control**:
```javascript
// Gesture detected from hand-tracking or MQTT
function onGestureDetected(gestureName, probability) {
  // Only play if confidence is high
  if (probability > 0.7 && actions[gestureName]) {
    fadeToAction(gestureName, 0.2);  // Quick crossfade for snappy response
  }
}

// Track gesture over time
let currentGesture = 'Idle';
function updateGesture(newGesture) {
  if (newGesture !== currentGesture) {
    fadeToAction(newGesture, 0.3);
    currentGesture = newGesture;
  }
}
```

---

## 4. Emote → Restore State Pattern

### The Pattern

```javascript
const emotes = ['Happy', 'Sad', 'Angry', 'Surprised'];
api = {};

// Create a button for each emote
emotes.forEach(name => {
  api[name] = function() {
    fadeToAction(name, 0.2);
    mixer.addEventListener('finished', restoreState);
  };
});

// When emote finishes, restore the previous idle/movement state
function restoreState() {
  mixer.removeEventListener('finished', restoreState);
  fadeToAction(api.state, 0.2);  // Return to idle or walk
}
```

### What It Does

- **One-time animation** (emote) plays when triggered
- **Listener** waits for the animation to finish (`LoopOnce` means it ends)
- **Automatic restore** transitions back to the base state (idle/walk) smoothly

### Why It's Useful

- **Gesture interruption**: Emotes interrupt what you're doing, then resume naturally
- **Listener cleanup**: Removing the listener prevents stacking multiple listeners (which would cause memory leaks)
- **Decoupled control**: Emotes don't need to know about the base state; the pattern handles the switch

### How to Reuse It

**Basic emote system**:
```javascript
const emotionAnims = ['Happy', 'Sad', 'Confused'];
let baseState = 'Idle';

emotionAnims.forEach(emotion => {
  api[emotion] = () => {
    fadeToAction(emotion, 0.2);
    mixer.addEventListener('finished', () => {
      mixer.removeEventListener('finished', arguments.callee);
      fadeToAction(baseState, 0.2);
    });
  };
});
```

**For hand-tracking with gesture recognition**:
```javascript
const gestureHandlers = {
  'thumbs_up': 'GestureThumbsUp',
  'point': 'GesturePoint',
  'wave': 'GestureWave',
};

function onHandPose(pose, confidence) {
  if (confidence > 0.8 && gestureHandlers[pose]) {
    const animName = gestureHandlers[pose];
    fadeToAction(animName, 0.2);

    // Set a timer in case 'finished' event doesn't fire
    setTimeout(() => {
      fadeToAction(baseState, 0.2);
    }, 3000);  // 3 second max

    mixer.addEventListener('finished', restoreState);
  }
}

function restoreState() {
  mixer.removeEventListener('finished', restoreState);
  fadeToAction(baseState, 0.2);
}
```

**For MQTT-driven emotions**:
```javascript
const mqtt = new MqttClient({ url: 'ws://broker:8080' });
mqtt.subscribe('robot/emotion');

mqtt.on('message', (topic, message) => {
  const emotion = JSON.parse(message).emotion;
  if (api[emotion]) {
    api[emotion]();  // Trigger emote, auto-restore after
  }
});
```

---

## 5. Morph Target Expressions

### The Pattern

```javascript
// Get the "Face" geometry from the model
const face = model.getObjectByName('Head_4');

// Morph targets are stored as a dictionary mapping names to indices
const expressions = Object.keys(face.morphTargetDictionary);

// For each expression, create a UI slider
expressions.forEach((name, i) => {
  // morphTargetInfluences[i] controls the strength of this morph (0-1)
  folder.add(face.morphTargetInfluences, i, 0, 1, 0.01)
    .name(name)
    .onChange(() => {
      // Slider updates real-time
    });
});
```

### What It Does

- **Finds the face mesh** in the model hierarchy by name
- **Reads all morph target names** from the geometry's `morphTargetDictionary`
- **Creates sliders** for each expression (each slider is 0-1 strength)
- **Real-time blending**: Moving a slider immediately blends the expression onto the face

### Why It's Useful

- **No separate geometry**: Morph targets are baked into the model; no swapping meshes
- **Smooth blending**: Expressions blend together (happy + surprised = confused look)
- **Low performance cost**: GPU handles the blending; CPU doesn't interpolate vertices
- **Expression library**: One model can have dozens of expressions without duplication

### How to Reuse It

**Basic setup**:
```javascript
const face = model.getObjectByName('HeadName');

if (face && face.morphTargetDictionary) {
  Object.entries(face.morphTargetDictionary).forEach(([name, index]) => {
    face.morphTargetInfluences[index] = 0;  // Initialize to off
  });
}
```

**Programmatic control (no UI)**:
```javascript
function setExpression(name, strength) {
  const face = model.getObjectByName('Head_4');
  if (face.morphTargetDictionary[name] !== undefined) {
    const index = face.morphTargetDictionary[name];
    face.morphTargetInfluences[index] = strength;
  }
}

// Use it:
setExpression('happy', 0.8);
setExpression('blink', 0.5);  // Blend two expressions
```

**Animated transitions between expressions**:
```javascript
function animateExpression(name, targetStrength, duration) {
  const face = model.getObjectByName('Head_4');
  const index = face.morphTargetDictionary[name];

  if (index === undefined) return;

  const startStrength = face.morphTargetInfluences[index];
  const startTime = performance.now();

  function blend(currentTime) {
    const elapsed = currentTime - startTime;
    const progress = Math.min(elapsed / duration, 1);

    face.morphTargetInfluences[index] = startStrength +
      (targetStrength - startStrength) * progress;

    if (progress < 1) {
      requestAnimationFrame(blend);
    }
  }

  requestAnimationFrame(blend);
}

// Use it:
animateExpression('happy', 1, 500);  // Fade happy in over 500ms
```

**For emotion synthesis from sensors**:
```javascript
// Map sensor values to expressions
function updateExpressionFromSensor(sensorData) {
  const face = model.getObjectByName('Head_4');

  // Arousal → eye size (blink)
  const blink = face.morphTargetDictionary['blink'];
  if (blink !== undefined) {
    face.morphTargetInfluences[blink] = sensorData.arousal;
  }

  // Valence → mouth (smile vs. frown)
  const smile = face.morphTargetDictionary['smile'];
  if (smile !== undefined) {
    face.morphTargetInfluences[smile] = Math.max(0, sensorData.valence);
  }

  const frown = face.morphTargetDictionary['frown'];
  if (frown !== undefined) {
    face.morphTargetInfluences[frown] = Math.max(0, -sensorData.valence);
  }
}
```

---

## 6. Timer + Animation Loop

### The Pattern

```javascript
// Initialize timer at setup
const timer = new THREE.Timer();
timer.connect(document);  // Listen to document for pause/resume

// In the animation loop
function animate() {
  requestAnimationFrame(animate);

  // Update timer and get delta time since last frame
  timer.update();
  const dt = timer.getDelta();

  // Advance all animations by dt
  if (mixer) {
    mixer.update(dt);
  }

  renderer.render(scene, camera);
}

animate();
```

### What It Does

- **Timer** tracks elapsed time frame-by-frame
- **getDelta()** returns time since last frame (e.g., 0.016 for 60 FPS)
- **mixer.update(dt)** advances all playing animations by that delta
- **Synchronized**: All animations stay in sync because they share the same mixer and timer

### Why It's Useful

- **Automatic timing**: No manual frame counting; just pass `dt` to mixer
- **Frame-rate agnostic**: Works at 30 FPS or 120 FPS; animations scale automatically
- **Pause/resume**: `timer.connect(document)` handles browser tab visibility (stops timer when tab is hidden)
- **Multiple animations**: One timer/mixer drives all animations in perfect sync

### How to Reuse It

**Basic timer setup**:
```javascript
const timer = new THREE.Timer();

function animate() {
  requestAnimationFrame(animate);
  timer.update();

  const dt = timer.getDelta();
  mixer?.update(dt);

  renderer.render(scene, camera);
}
```

**Manual time control (for testing/debugging)**:
```javascript
let manualTime = 0;
const timer = new THREE.Timer();

function animate() {
  requestAnimationFrame(animate);

  // Step manually for debug
  // manualTime += 0.016;
  // mixer.update(0.016);

  // Or use real timer
  timer.update();
  mixer?.update(timer.getDelta());

  renderer.render(scene, camera);
}
```

**Multiple mixers (multiple models)**:
```javascript
const timer = new THREE.Timer();
const mixers = [];

function animate() {
  requestAnimationFrame(animate);

  timer.update();
  const dt = timer.getDelta();

  // Update all mixers with same dt
  mixers.forEach(mixer => mixer.update(dt));

  renderer.render(scene, camera);
}

// Add new model:
GLTFLoader.load(path, (gltf) => {
  const mixer = new THREE.AnimationMixer(gltf.scene);
  mixers.push(mixer);
  scene.add(gltf.scene);
});
```

**For slow-motion or fast-forward**:
```javascript
let timeScale = 1;  // 1 = normal, 0.5 = half-speed, 2 = double-speed

function animate() {
  requestAnimationFrame(animate);
  timer.update();

  const dt = timer.getDelta() * timeScale;
  mixer?.update(dt);

  renderer.render(scene, camera);
}

// UI control:
gui.add({ timeScale }, 'timeScale', 0, 2).onChange(v => {
  timeScale = v;
});
```

---

## Integration Pattern: Complete Example

Here's how all six patterns work together:

```javascript
let model, mixer, actions, activeAction;

const loader = new GLTFLoader();
const timer = new THREE.Timer();
const scene = new THREE.Scene();
const renderer = new THREE.WebGLRenderer();

// 1. Load model
loader.load('model.glb', (gltf) => {
  model = gltf.scene;
  scene.add(model);

  // 2. Setup mixer and actions
  mixer = new THREE.AnimationMixer(model);
  actions = {};

  gltf.animations.forEach(clip => {
    const action = mixer.clipAction(clip);
    if (clip.name.includes('Emote')) {
      action.clampWhenFinished = true;
      action.loop = THREE.LoopOnce;
    }
    actions[clip.name] = action;
  });

  // 3. Setup crossfade function
  window.fadeToAction = (name, duration) => {
    const prev = activeAction;
    activeAction = actions[name];
    if (prev !== activeAction && prev) prev.fadeOut(duration);
    activeAction.reset().fadeIn(duration).play();
  };

  // 4. Setup emotes with auto-restore
  const emotes = gltf.animations
    .filter(c => c.name.includes('Emote'))
    .map(c => c.name);

  emotes.forEach(name => {
    window[`trigger${name}`] = () => {
      fadeToAction(name, 0.2);
      mixer.addEventListener('finished', () => {
        mixer.removeEventListener('finished', arguments.callee);
        fadeToAction('Idle', 0.2);
      });
    };
  });

  // 5. Setup morph targets
  const face = model.getObjectByName('Head');
  if (face?.morphTargetDictionary) {
    Object.entries(face.morphTargetDictionary).forEach(([name, idx]) => {
      face.morphTargetInfluences[idx] = 0;
    });
  }
});

// 6. Animation loop
timer.connect(document);

function animate() {
  requestAnimationFrame(animate);
  timer.update();

  if (mixer) {
    mixer.update(timer.getDelta());
  }

  renderer.render(scene, camera);
}

animate();
```

---

## Adaptation Notes

### For Hand-Tracking Integration
- Store gesture names mapped to animation names
- Call `fadeToAction(animName, 0.2)` on hand pose detection
- Use confidence thresholds to avoid jitter
- Combine with morph targets for subtle expression changes

### For MQTT-Driven Remote Control
- Subscribe to topics like `robot/animation`, `robot/expression`
- Parse JSON payload for animation name and parameters
- Queue animations if needed (one-shot gestures should not interrupt each other)
- Log animation events to a database for learning

### For Custom Models
- Export from Blender/Maya with armature (bones) for skeletal animation
- Embed AnimationClips in the GLTF file (Blender: export → animations)
- Name objects consistently (`Head_4` → match with `model.getObjectByName()`)
- Test morph target names with `face.morphTargetDictionary` before using

### Performance Tips
- Pre-instantiate all actions (as shown in snippet #2)
- Cache `mixer`, `actions`, `face` at module level
- Limit morph targets on mobile (blend only the active ones)
- Use `setEffectiveWeight()` to layer animations instead of stopping/starting

---

## Resources

- [Three.js AnimationMixer docs](https://threejs.org/docs/#api/en/animation/AnimationMixer)
- [Three.js AnimationAction docs](https://threejs.org/docs/#api/en/animation/AnimationAction)
- [Three.js GLTFLoader docs](https://threejs.org/docs/#examples/en/loaders/GLTFLoader)
- [Exporting GLTF with animations from Blender](https://docs.blender.org/manual/en/latest/addons/io_scene_gltf2/index.html)
- [Morph targets / shape keys](https://threejs.org/docs/#api/en/core/BufferGeometry#morphAttributes)

