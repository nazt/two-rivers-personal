# KlakMath Quick Reference Guide

**Version:** 2.1.1
**Author:** Keijiro Takahashi
**License:** Unlicense
**Package:** `jp.keijiro.klak.math`

---

## What It Does

KlakMath is a performant extension library for **Unity Mathematics** that provides specialized math utilities for creative coding in Unity. It fills gaps in the standard math library with optimized implementations for:

- **Smooth interpolation** using critically damped springs and exponential decay
- **Gradient noise** for procedural generation and animation
- **Fast hashing** as both a hash function and deterministic random number generator
- **Rotation helpers** for efficient quaternion operations

Perfect for visual effects, procedural generation, animation controllers, and any performance-critical math operations.

---

## Installation

### Via Unity Package Manager (Recommended)

1. **Add the Keijiro registry** to your project:
   - Edit `Packages/manifest.json` and add:
   ```json
   "scopedRegistries": [
     {
       "name": "Keijiro",
       "url": "https://registry.npmjs.com",
       "scopes": ["jp.keijiro"]
     }
   ]
   ```

2. **Add the package** via Package Manager UI:
   - Window → TextureGraph → Add Package by Name
   - Enter: `jp.keijiro.klak.math`

   OR edit `manifest.json`:
   ```json
   "dependencies": {
     "jp.keijiro.klak.math": "2.1.1",
     "com.unity.mathematics": "1.2.6"
   }
   ```

### Requirements
- **Unity:** 2022.3 or later
- **Dependencies:** `com.unity.mathematics` 1.2.6+

### Using via Git URL
```json
"jp.keijiro.klak.math": "https://github.com/keijiro/KlakMath.git"
```

---

## Namespace

All classes are in the `Klak.Math` namespace:

```csharp
using Klak.Math;
```

---

## Key Features & API Reference

### 1. CdsTween — Critically Damped Spring Interpolation

Smooth, responsive tweening using a critically damped spring model. Produces natural-feeling motion without overshoot.

**Static Methods:**

```csharp
// float
(float x, float v) CdsTween.Step((float x, float v) state, float target, float speed)
(float x, float v) CdsTween.Step((float x, float v) state, float target, float speed, float dt)

// float2, float3, float4
(float2 x, float2 v) CdsTween.Step((float2 x, float2 v) state, float2 target, float speed)
(float2 x, float2 v) CdsTween.Step((float2 x, float2 v) state, float2 target, float speed, float dt)
// ... and float3, float4 variants

// quaternion
(quaternion x, float4 v) CdsTween.Step((quaternion x, float4 v) state, quaternion target, float speed)
(quaternion x, float4 v) CdsTween.Step((quaternion x, float4 v) state, quaternion target, float speed, float dt)
```

**Parameters:**
- `state`: Current position and velocity as a tuple `(x, v)`
- `target`: Target value to interpolate toward
- `speed`: Spring stiffness (higher = faster response, ~5-20 typical)
- `dt`: Delta time (optional, uses `Time.deltaTime` if omitted)

**Returns:** New `(position, velocity)` tuple for next frame

**Example:**

```csharp
private (float3 pos, float3 vel) _tweenState;

void Start()
{
    _tweenState = (transform.position, float3.zero);
}

void Update()
{
    var target = Input.mousePosition;
    _tweenState = CdsTween.Step(_tweenState, target, 8f);
    transform.position = _tweenState.pos;
}
```

**Use Cases:**
- Camera following with natural deceleration
- UI element positioning with momentum
- Smooth color transitions
- Position/rotation easing in animations

---

### 2. ExpTween — Exponential Interpolation

Exponential decay-based interpolation. Fast initial change that smoothly asymptotes to target. Simpler than springs, no velocity tracking.

**Static Methods:**

```csharp
// float
float ExpTween.Step(float x, float target, float speed)
float ExpTween.Step(float x, float target, float speed, float dt)

// float2, float3, float4
float2 ExpTween.Step(float2 x, float2 target, float speed)
float2 ExpTween.Step(float2 x, float2 target, float speed, float dt)
// ... and float3, float4 variants

// quaternion
quaternion ExpTween.Step(quaternion x, quaternion target, float speed)
quaternion ExpTween.Step(quaternion x, quaternion target, float speed, float dt)
```

**Parameters:**
- `x`: Current value
- `target`: Target value
- `speed`: Decay rate (higher = faster convergence, ~5-20 typical)
- `dt`: Delta time (optional)

**Returns:** New interpolated value

**Example:**

```csharp
float _currentValue = 0f;

void Update()
{
    float target = Input.GetAxis("Vertical");
    _currentValue = ExpTween.Step(_currentValue, target, 6f);
}
```

**Use Cases:**
- Simple position smoothing
- FOV transitions
- Fade effects (opacity blending)
- Rotation following (with `nlerp` under the hood for quaternions)
- Audio parameter smoothing

**Key Difference from CdsTween:**
- ExpTween: No overshoot, simpler, no velocity state
- CdsTween: More responsive, momentum-aware, requires state tracking

---

### 3. Noise — Gradient Noise Generator

Perlin-like 1D gradient noise with fractal (Brownian motion) variants. Deterministic, seedable, and efficient.

**Static Methods:**

```csharp
// Single octave noise
float Noise.Float(float p, uint seed)
float2 Noise.Float2(float2 p, uint seed)
float3 Noise.Float3(float3 p, uint seed)
float4 Noise.Float4(float4 p, uint seed)

// Fractal (multi-octave) noise
float Noise.Fractal(float p, int octave, uint seed)
float2 Noise.Fractal2(float2 p, int octave, uint seed)
float3 Noise.Fractal3(float3 p, int octave, uint seed)
float4 Noise.Fractal4(float4 p, int octave, uint seed)

// Rotation noise (Euler angles)
quaternion Noise.Rotation(float3 p, float3 angles, uint seed)
quaternion Noise.FractalRotation(float3 p, int octave, float3 angles, uint seed)
```

**Parameters:**
- `p`: Noise coordinate(s)
- `octave`: Number of noise layers (typically 2-8)
- `seed`: Deterministic seed for reproducibility
- `angles`: Rotation scale in radians (for rotation variants)

**Returns:** Noise value in range typically [-1, 1] (normalized); rotation as quaternion

**Example:**

```csharp
void Update()
{
    uint seed = 12345;
    float noiseVal = Noise.Float(Time.time * 2f, seed);

    // Fractal noise for terrain-like variation
    float terrain = Noise.Fractal(position.x, 4, seed);

    // Random rotation based on position
    quaternion rotNoise = Noise.Rotation(
        transform.position,
        new float3(0.5f, 0.5f, 0.5f),
        seed
    );
}
```

**Use Cases:**
- Procedural terrain generation
- Perlin noise animation for flowing effects
- Particle system randomization
- Displacement mapping
- Seed-based world generation (reproducible across frames)
- Organic motion patterns

**Output Range:** Values are normalized to approximately [-1, 1]

---

### 4. XXHash — Fast Hash Function & PRNG

Implements the XXHash algorithm as a deterministic random number generator. Ultra-fast, excellent distribution, seed-based for reproducibility.

**Constructor:**

```csharp
XXHash hash = new XXHash(uint seed);
```

**Integer Methods:**

```csharp
// Full uint range
uint   hash.UInt(uint data)
uint2  hash.UInt2(uint data)       // From single uint
uint2  hash.UInt2(uint2 data)      // From uint2
uint3  hash.UInt3(uint data)       // From single uint
uint3  hash.UInt3(uint3 data)
uint4  hash.UInt4(uint data)       // From single uint
uint4  hash.UInt4(uint4 data)

// Range [0, max)
uint   hash.UInt(uint max, uint data)
uint2  hash.UInt2(uint max, uint2 data)
uint2  hash.UInt2(uint max, uint data)     // Single input
// ... and uint3, uint4 variants

// Range [min, max)
uint   hash.UInt(uint min, uint max, uint data)
uint2  hash.UInt2(uint min, uint max, uint2 data)
// ... and uint3, uint4 variants
```

**Bool Methods:**

```csharp
bool   hash.Bool(uint data)
bool2  hash.Bool2(uint data)
bool3  hash.Bool3(uint data)
bool4  hash.Bool4(uint data)
```

**Float Methods:**

```csharp
// [0, 1] range
float  hash.Float(uint data)
float2 hash.Float2(uint data)
float3 hash.Float3(uint data)
float4 hash.Float4(uint data)

// [0, max) range
float  hash.Float(float max, uint data)
float2 hash.Float2(float2 max, uint data)
// ... and variants

// [min, max) range
float  hash.Float(float min, float max, uint data)
float2 hash.Float2(float2 min, float2 max, uint data)
// ... and variants
```

**Int Methods:** Similar to UInt, returns signed integers

**Geometric Utilities:**

```csharp
// Points on unit circle/sphere
float2 hash.OnCircle(uint data)        // Random point on unit circle
float2 hash.InCircle(uint data)        // Random point inside unit circle
float3 hash.OnSphere(uint data)        // Random point on unit sphere surface
float3 hash.InSphere(uint data)        // Random point inside unit sphere
quaternion hash.Rotation(uint data)    // Random rotation
```

**Property:**

```csharp
uint hash.Seed { get; }  // Get the seed used
```

**Example:**

```csharp
void SpawnRandomParticles()
{
    uint seed = 42;
    XXHash hash = new XXHash(seed);

    // Deterministic random positions
    for (int i = 0; i < 10; i++)
    {
        var pos = hash.InSphere((uint)i);
        // Spawn particle at pos
    }

    // Random color
    var color = new float3(
        hash.Float(0, 1, 100u),
        hash.Float(0, 1, 101u),
        hash.Float(0, 1, 102u)
    );

    // Random bool
    if (hash.Bool(200u))
    {
        // 50% chance
    }
}
```

**Use Cases:**
- Deterministic procedural generation (same seed = same result)
- Per-instance randomization (use entity ID as data)
- Fast random number generation in tight loops
- Geometric random sampling (on/in sphere, circle)
- Parallel-safe random generation (no state mutation)

**Advantage:** Unlike `Random`, XXHash is:
- **Deterministic:** Same seed + data = same result every frame
- **Fast:** Ultra-optimized hash function
- **Stateless:** No mutable state to track
- **Parallelizable:** Safe for Burst compilation and jobs

---

### 5. Rotation.FromTo — Rotation Between Vectors

Compute the shortest rotation (quaternion) from one vector to another.

**Static Method:**

```csharp
quaternion Rotation.FromTo(float3 v1, float3 v2)
```

**Parameters:**
- `v1`: Starting direction vector
- `v2`: Target direction vector

**Returns:** Quaternion representing rotation from v1 to v2

**Example:**

```csharp
void LookAtTarget(Transform target)
{
    float3 forward = transform.forward;
    float3 toTarget = math.normalize(target.position - transform.position);

    quaternion rotation = Rotation.FromTo(forward, toTarget);
    transform.rotation *= rotation;
}
```

**Use Cases:**
- Object looking at target
- Billboard sprites
- Bone rotation in skeletal animation
- Aligning game objects to surfaces
- Smooth orientation changes

---

### 6. RandomExtensions — Unity Random Helper Methods

Extension methods for Unity's `Random` type (requires `using Unity.Mathematics`).

**Extension Methods:**

```csharp
float2 self.NextFloat2OnDisk()      // Random point on unit disk
float3 self.NextFloat3InSphere()    // Random point in unit sphere
```

**Example:**

```csharp
Random rng = new Random(12345u);

float2 diskPos = rng.NextFloat2OnDisk();
float3 spherePos = rng.NextFloat3InSphere();
```

**Use Cases:**
- Random particle positions within sphere
- Disk-based sampling
- Jitter for antialiasing

---

## Common Use Cases & Patterns

### Camera Follow with Momentum

```csharp
public class CameraFollower : MonoBehaviour
{
    public Transform target;
    public float speed = 8f;

    private (float3 pos, float3 vel) _state;

    void Start() => _state = (transform.position, float3.zero);

    void LateUpdate()
    {
        _state = CdsTween.Step(_state, target.position, speed);
        transform.position = _state.pos;
    }
}
```

### Procedural Terrain with Noise

```csharp
float GetHeightAtPosition(float3 worldPos)
{
    uint seed = 42;

    // Multi-octave noise for natural features
    float height = Noise.Fractal(worldPos.x * 0.1f, 4, seed);
    height = math.lerp(-1, 1, (height + 1) * 0.5f);

    return height;
}
```

### Deterministic Random Spawning

```csharp
void SpawnEnemiesForLevel(int levelId)
{
    XXHash hash = new XXHash((uint)levelId);

    int enemyCount = 10 + hash.UInt(0, 5, 1u); // 10-15 enemies

    for (int i = 0; i < enemyCount; i++)
    {
        // Same level ID always produces same enemy positions/types
        var spawnPos = hash.InSphere((uint)i);
        int enemyType = hash.UInt(0, 3, (uint)(i + 1000));

        // Spawn enemy at spawnPos with type
    }
}
```

### Smooth Rotation Interpolation

```csharp
void Update()
{
    // Get target rotation from mouse
    float3 mouseDir = math.normalize(GetMouseWorldPosition() - transform.position);
    quaternion targetRot = Rotation.FromTo(transform.forward, mouseDir);

    // Smooth interpolation toward target
    transform.rotation = ExpTween.Step(transform.rotation, targetRot, 5f);
}
```

### Particle Jitter with Consistent Randomness

```csharp
void InitializeParticle(int particleId)
{
    XXHash hash = new XXHash(1234u);

    // Same particle ID always gets same random jitter
    float jitterX = hash.Float(-0.5f, 0.5f, (uint)(particleId * 2));
    float jitterY = hash.Float(-0.5f, 0.5f, (uint)(particleId * 2 + 1));

    particles[particleId].velocity += new float3(jitterX, jitterY, 0);
}
```

---

## Performance Notes

- **CdsTween & ExpTween:** Minimal overhead, suitable for thousands of concurrent tweens
- **Noise:** Single call ~50-100 CPU cycles; fractal scales with octave count
- **XXHash:** Extremely fast (~20 CPU cycles); faster than `Random.Range()`
- **All methods:** Burst-compatible for job scheduling

---

## Dependencies & Compatibility

- **Unity Version:** 2022.3 LTS or newer
- **Mathematics Package:** `com.unity.mathematics` 1.2.6+
- **Burst Compatible:** Yes, all methods are Burst-safe
- **Platform Support:** All platforms (Windows, macOS, Linux, iOS, Android, WebGL, Console)

---

## Related Documentation

- [Unity Mathematics Documentation](https://docs.unity3d.com/Packages/com.unity.mathematics@latest)
- [GitHub Repository](https://github.com/keijiro/KlakMath)
- [Changelog](https://github.com/keijiro/KlakMath/blob/master/CHANGELOG.md)

---

## Quick Import Template

```csharp
using Unity.Mathematics;
using Klak.Math;

public class MyAnimationController : MonoBehaviour
{
    // Tweening state
    private (float3 pos, float3 vel) _positionTween;

    // Noise generation
    private uint _noiseSeed = 42;

    // Random generation
    private XXHash _rng;

    void Start()
    {
        _positionTween = (transform.position, float3.zero);
        _rng = new XXHash(12345u);
    }

    void Update()
    {
        // Smooth position update
        var target = new float3(Input.GetAxis("Horizontal"), 0, Input.GetAxis("Vertical"));
        _positionTween = CdsTween.Step(_positionTween, target, 8f);
        transform.position = _positionTween.pos;

        // Noise-based rotation
        float noiseVal = Noise.Float(Time.time, _noiseSeed);
        transform.Rotate(0, noiseVal * 45f, 0);

        // Random values
        if (_rng.Bool(Time.frameCount))
        {
            // 50% chance per frame
        }
    }
}
```

---

**Last Updated:** 2026-02-28
**Source:** Comprehensive analysis of KlakMath 2.1.1
