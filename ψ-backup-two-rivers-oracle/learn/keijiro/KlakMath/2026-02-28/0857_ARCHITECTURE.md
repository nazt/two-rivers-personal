# KlakMath Architecture Document

**Project:** KlakMath
**Author:** Keijiro Takahashi
**Version:** 2.1.1 (latest)
**Minimum Unity:** 2022.3
**License:** Unlicense
**Last Updated:** 2025-12-05

---

## Overview

KlakMath is a lightweight, high-performance extension library for the Unity Mathematics package. It provides essential utilities for game and real-time graphics development, focusing on interpolation, noise generation, pseudo-random number generation, and rotation helpers. The library is designed for use in both MonoBehaviour-based gameplay and high-performance job-based systems.

**Core Philosophy:** Fast, stateless, deterministic mathematical utilities using Unity.Mathematics primitives.

---

## Directory Structure

```
KlakMath/
├── Packages/
│   └── jp.keijiro.klak.math/          # UPM Package (primary distributable)
│       ├── package.json               # Package metadata & dependencies
│       ├── Runtime/                   # Core implementation
│       │   ├── Klak.Math.asmdef       # Assembly definition
│       │   ├── CdsTween.cs            # Critically damped spring tween
│       │   ├── ExpTween.cs            # Exponential tween
│       │   ├── Noise.cs               # Gradient noise generator
│       │   ├── XXHash.cs              # Hash-based PRNG
│       │   ├── Rotation.cs            # Rotation utilities
│       │   └── RandomExtensions.cs    # Extensions for Unity.Mathematics.Random
│       ├── CHANGELOG.md               # Version history
│       └── README.md                  # User documentation
├── Assets/                            # Example scenes and test scripts
│   ├── Noise/                         # Noise visualization & examples
│   │   ├── NoiseGraph1D.cs            # 1D noise visualization
│   │   ├── NoiseGraph2D.cs            # 2D noise visualization
│   │   ├── NoiseMotion.cs             # Game object motion using noise
│   │   └── *.unity                    # Corresponding scenes
│   ├── Tween/                         # Tween examples
│   │   ├── TweenTest.cs               # Exp & CDS tween comparison
│   │   ├── FromToRotationTest.cs      # Rotation interpolation
│   │   └── Tween.unity
│   ├── Random/                        # Random utility tests
│   │   ├── RandomInSphereTest.cs
│   │   ├── RandomOnDiskTest.cs
│   │   └── Random.unity
│   ├── XXHash/                        # Hash function tests
│   │   ├── HashInSphereTest.cs
│   │   ├── HashOnSphereTest.cs
│   │   ├── HashRotationTest.cs
│   │   └── (visualization scenes)
│   └── Misc/                          # Materials for visualization
├── ProjectSettings/                   # Unity project configuration
├── Packages/                          # Package manifests
│   ├── manifest.json
│   └── packages-lock.json
└── README.md                          # Root documentation
```

### Key Observations
- **UPM Structure:** Follows standard Unity Package Manager layout with `Runtime/` containing implementation
- **Assembly Definition:** Single `Klak.Math.asmdef` for the entire runtime (no Editor or Test assemblies in package)
- **Minimal Surface:** Only 6 core files in Runtime - highly focused library
- **Example-Driven:** Assets folder contains practical usage examples for each feature

---

## Package Metadata

### package.json Details

```json
{
  "name": "jp.keijiro.klak.math",
  "version": "2.1.1",
  "displayName": "KlakMath",
  "description": "Extension library for Unity Mathematics.",
  "unity": "2022.3",
  "author": "Keijiro Takahashi",
  "dependencies": { "com.unity.mathematics": "1.2.6" },
  "changelogUrl": "https://github.com/keijiro/KlakMath/blob/master/CHANGELOG.md",
  "documentationUrl": "https://github.com/keijiro/KlakMath",
  "licensesUrl": "https://github.com/keijiro/KlakMath/blob/master/LICENSE",
  "license": "Unlicense"
}
```

### Dependencies
- **com.unity.mathematics**: 1.2.6 (required)
- **NO** additional external dependencies
- **NO** deprecated APIs

### Assembly Definition (Klak.Math.asmdef)
- References: `com.unity.mathematics` (GUID: d8b63aba1907145bea998dd612889d6b)
- Unsafe Code: `false`
- Auto-referenced: `true`

---

## Core Abstractions & Patterns

### 1. Tween Systems (Interpolation)

KlakMath provides two complementary interpolation strategies:

#### CdsTween - Critically Damped Spring Model
**File:** `/Packages/jp.keijiro.klak.math/Runtime/CdsTween.cs`

Implements spring-based tweening with critical damping to eliminate overshoot while maintaining smooth acceleration.

**Pattern:** Static utility class with overloaded methods supporting multiple types.

**Supported Types:**
- `float` → `(float x, float v)` state tuple
- `float2` → `(float2 x, float2 v)` state tuple
- `float3` → `(float3 x, float3 v)` state tuple
- `float4` → `(float4 x, float4 v)` state tuple
- `quaternion` → `(quaternion x, float4 v)` state tuple (special handling for shortest path)

**Core Algorithm:**
```csharp
// Spring dynamics with critical damping
var n1 = state.v - (state.x - target) * (speed * speed * dt);
var n2 = 1 + speed * dt;
var nv = n1 / (n2 * n2);
return (state.x + nv * dt, nv);
```

**Key Features:**
- State-based: caller manages position + velocity tuple
- No overshoot with proper speed parameter
- Time-delta aware (defaults to `Time.deltaTime`)
- Quaternion special case: selects shortest rotation path using dot product sign check

**Example Usage:**
```csharp
(float3 p, float3 v) state = (startPos, float3.zero);
state = CdsTween.Step(state, targetPos, speed: 4f);
transform.position = state.x;
```

#### ExpTween - Exponential Decay Interpolation
**File:** `/Packages/jp.keijiro.klak.math/Runtime/ExpTween.cs`

Implements exponential interpolation: `lerp(target, current, exp(-speed * dt))`. Simpler and faster than spring model.

**Supported Types:**
- `float`, `float2`, `float3`, `float4` (direct lerp)
- `quaternion` (uses `nlerp` - normalized lerp for rotation stability)

**Core Algorithm:**
```csharp
float step = math.exp(-speed * dt);
return math.lerp(target, current, step);  // Asymptotically approaches target
```

**Trade-offs:**
- Simpler (one operation vs spring dynamics)
- No overshoot, but slower initial convergence than optimized spring
- Good for smooth camera movement, value smoothing

---

### 2. Noise Generation

**File:** `/Packages/jp.keijiro.klak.math/Runtime/Noise.cs`

Implements 1D gradient noise (Perlin-like) with fractal composition. Uses XXHash internally for deterministic pseudo-random gradients.

**Pattern:** Static utility class organized by dimensionality and fractal type.

#### Base Gradient Noise

Implements Perlin-style gradient noise for 1D, 2D, 3D, and 4D.

**Method Signatures:**
```csharp
// Scalar noise
public static float Float(float p, uint seed)      // 1D noise
public static float2 Float2(float2 p, uint seed)   // 2D noise
public static float3 Float3(float3 p, uint seed)   // 3D noise
public static float4 Float4(float4 p, uint seed)   // 4D noise
```

**Algorithm Overview:**
1. Hash integer coordinates using XXHash to get pseudo-random gradients
2. Compute fractional part for interpolation
3. Fade curve: `k = 1 - (1 - x)^3 * (1 - (1 - x)^3)` (Hermite-like smoothstep)
4. Dot product between gradient vectors and distance vectors
5. Interpolate between adjacent cell values

**Example:** For 1D noise:
```csharp
var hash = new XXHash(seed);
var i = (uint)((int)p + 0x10000000);  // Integer part
var x = math.frac(p);                  // Fractional part [0, 1)

var k = math.float2(x, 1 - x);        // Distance weights
k = 1 - k * k;                         // Fade curve: (1 - x^2)^3
k = k * k * k;

var g0 = hash.Float(-1, 1, i);        // Gradient at i
var g1 = hash.Float(-1, 1, i + 1);    // Gradient at i+1

var n = math.dot(k * g0, float2(x, x - 1));  // Interpolate
return n * 2 * 32 / 27;  // Normalization constant
```

#### Fractal Noise

Combines multiple octaves of noise for natural-looking variation.

**Method Signatures:**
```csharp
public static float Fractal(float p, int octave, uint seed)
public static float2 Fractal2(float2 p, int octave, uint seed)
public static float3 Fractal3(float3 p, int octave, uint seed)
public static float4 Fractal4(float4 p, int octave, uint seed)
```

**Algorithm:**
```csharp
var f = 0.0f;
var w = 1.0f;
for (var i = 0; i < octave; i++)
{
    f += w * Float(p, seed);
    p *= 2.0f;      // Frequency doubles per octave
    w *= 0.5f;      // Amplitude halves per octave
    seed++;         // Varying seed per octave
}
return f;
```

**Properties:**
- Standard Fourier composition (persistent noise)
- Amplitude: 0.5 + 0.25 + 0.125 + ... → sum approaches 1.0
- Deterministic with seed parameter

#### Rotation Generators

Combines fractal noise with rotation to create continuous, natural-looking rotational motion.

```csharp
public static quaternion Rotation(float3 p, float3 angles, uint seed)
public static quaternion FractalRotation(float3 p, int octave, float3 angles, uint seed)
```

Creates Euler angles by multiplying noise output with angle scale, then converts to quaternion.

---

### 3. XXHash - Deterministic PRNG

**File:** `/Packages/jp.keijiro.klak.math/Runtime/XXHash.cs`

Implements XXHash (fast non-cryptographic hash) as a deterministic pseudo-random number generator. Key difference: stateless, repeatable, and compatible with Burst compilation.

**Pattern:** Read-only struct with stateless methods. Seed-based seeding for determinism.

#### Core Interface
```csharp
public readonly struct XXHash
{
    public uint Seed { get; }
    public XXHash(uint seed) => Seed = seed;
}
```

#### Hash Calculation
Uses XXHash prime constants and bitwise operations:
```csharp
static uint CalculateHash(uint data, uint seed)
{
    const uint PRIME32_1 = 2654435761U;
    const uint PRIME32_2 = 2246822519U;
    const uint PRIME32_3 = 3266489917U;
    const uint PRIME32_4 = 668265263U;
    const uint PRIME32_5 = 374761393U;

    var h32 = seed + PRIME32_5;
    h32 += 4U;
    h32 += data * PRIME32_3;
    h32 = rotl32(h32, 17) * PRIME32_4;
    h32 ^= h32 >> 15;
    h32 *= PRIME32_2;
    h32 ^= h32 >> 13;
    h32 *= PRIME32_3;
    h32 ^= h32 >> 16;
    return h32;
}
```

#### Output Methods

The class provides three categories of methods:

**1. Raw UInt Range**
```csharp
public uint  UInt (uint  data)       // Full uint range
public uint2 UInt2(uint2 data)       // Component-wise
public uint3 UInt3(uint3 data)
public uint4 UInt4(uint4 data)
```

**2. Bounded Range (0 to Max)**
```csharp
public uint UInt(uint max, uint data)       // [0, max)
public float Float(float max, uint data)    // [0.0, max)
```

**3. Min-Max Range**
```csharp
public uint UInt(uint min, uint max, uint data)      // [min, max)
public float Float(float min, float max, uint data)  // [min, max)
```

#### Geometric Utilities

Pre-built functions for common spatial distributions:

**Circle & Disk:**
```csharp
public float2 OnCircle(uint data)   // Unit circle
public float2 InCircle(uint data)   // Unit disk (uniformly distributed)
```

**Sphere:**
```csharp
public float3 OnSphere(uint data)   // Unit sphere surface
public float3 InSphere(uint data)   // Unit sphere interior (cube root weighting)
```

**Rotation:**
```csharp
public quaternion Rotation(uint data)  // Uniform random quaternion
```

**Algorithm Detail:** InSphere uses `pow(Float(), 1/3)` to correct for cubic volume distribution.

---

### 4. RandomExtensions

**File:** `/Packages/jp.keijiro.klak.math/Runtime/RandomExtensions.cs`

Extension methods for `Unity.Mathematics.Random` struct. Provides commonly-needed spatial distributions.

```csharp
public static class RandomExtensions
{
    // Inside unit disk with uniform distribution
    public static float2 NextFloat2OnDisk(ref this Random self)
      => self.NextFloat2Direction() * math.sqrt(self.NextFloat());

    // Inside unit sphere with uniform distribution
    public static float3 NextFloat3InSphere(ref this Random self)
      => self.NextFloat3Direction() * math.pow(self.NextFloat(), 1.0f / 3);
}
```

**Note:** These wrap existing `Random` methods and apply proper weighting (square root for disk, cube root for sphere) to achieve uniform distribution.

---

### 5. Rotation Utilities

**File:** `/Packages/jp.keijiro.klak.math/Runtime/Rotation.cs`

Provides rotation between two vectors (solving the "from" → "to" problem).

```csharp
public static quaternion FromTo(float3 v1, float3 v2)
{
    var a = math.cross(v1, v2);           // Rotation axis
    var v1v2 = math.dot(v1, v1) * math.dot(v2, v2);  // For magnitude
    var w = math.sqrt(v1v2) + math.dot(v1, v2);      // Scalar component
    return math.normalizesafe(math.quaternion(math.float4(a, w)));
}
```

**Algorithm:**
- Cross product gives rotation axis (xyz components)
- Combined magnitude and dot product yields w (scalar)
- Normalizes to unit quaternion
- `normalizesafe` prevents division by zero for parallel vectors

**Use Case:** Camera facing directions, AI rotation toward target, etc.

---

## Design Patterns

### 1. Static Utility Class Pattern
All core classes are `static` with no instance state:
- **CdsTween, ExpTween, Noise, Rotation**
- Advantages: No allocation overhead, familiar usage
- Works well with Burst compilation

### 2. Method Overloading by Type
KlakMath extensively uses C# method overloading to support multiple math types:
```csharp
// Same method name, different signatures
public static float Step(float x, float target, float speed, float dt)
public static float2 Step(float2 x, float2 target, float speed, float dt)
public static float3 Step(float3 x, float3 target, float speed, float dt)
public static float4 Step(float4 x, float4 target, float speed, float dt)
```

This avoids generic boilerplate while maintaining type safety.

### 3. Readonly Struct for PRNG
`XXHash` is a readonly struct with no mutable state:
```csharp
public readonly struct XXHash { ... }
```
- Immutable (thread-safe)
- Stack-allocated (no GC)
- Burst-compatible
- Deterministic given seed + data

### 4. State Tuple for Tweening
CdsTween returns state as tuples to avoid heap allocation:
```csharp
(float3 position, float3 velocity) state = (startPos, float3.zero);
state = CdsTween.Step(state, target, speed, dt);
```

Caller manages memory; enables use in jobs and high-performance contexts.

### 5. Seed-Based Determinism
All randomization methods accept `uint seed` parameter:
- Enables reproducible behavior
- Works in burst-compiled jobs
- No global state

---

## Dependency Graph

```
┌─────────────────────────────────────────┐
│   User Code (MonoBehaviour/Jobs)        │
└────────────────┬────────────────────────┘
                 │
        ┌────────┴─────────┐
        │                  │
        ▼                  ▼
   ┌─────────┐      ┌────────────┐
   │  Tween  │      │  Noise     │
   │ (Exp,   │      │ (Gradient) │
   │  CDS)   │      └──────┬─────┘
   └────┬────┘             │
        │                  │
        │          ┌───────┴────────┐
        │          │                │
        │          ▼                ▼
        │      ┌────────┐      ┌───────────┐
        │      │ XXHash │      │ Rotation  │
        │      │ (PRNG) │      │ (FromTo)  │
        │      └────────┘      └───────────┘
        │          │
        │          ▼
        │     ┌──────────────────┐
        │     │ RandomExtensions │
        │     │ (Unity.Math.Rnd) │
        │     └──────────────────┘
        │
        └─────────────────┬──────────────────┐
                          │                  │
                          ▼                  ▼
                  ┌────────────────┐  ┌────────────┐
                  │ Unity.Math     │  │ UnityEngine│
                  │ (float, float3,│  │ (Time,     │
                  │  quaternion)   │  │  Transform)│
                  └────────────────┘  └────────────┘
```

**Key Insights:**
- Noise depends on XXHash for gradient generation
- Tween is independent (can be used alone)
- RandomExtensions wraps Unity.Mathematics.Random
- Rotation is a pure utility (no dependencies)
- No circular dependencies

---

## Feature Summary

| Feature | Module | Classes/Methods | Use Cases |
|---------|--------|-----------------|-----------|
| **Spring Tweening** | CdsTween | `Step(state, target, speed)` | Smooth object movement, camera follow, spring effects |
| **Exponential Tweening** | ExpTween | `Step(x, target, speed)` | Fast lerp, camera smoothing, value easing |
| **1D-4D Gradient Noise** | Noise | `Float/Float2/Float3/Float4()` | Terrain generation, procedural animation, value variation |
| **Fractal Noise** | Noise | `Fractal/Fractal2/Fractal3/Fractal4()` | Natural-looking patterns, Perlin noise effect |
| **Noise Rotations** | Noise | `Rotation/FractalRotation()` | Procedural object spinning, camera wobble |
| **Deterministic PRNG** | XXHash | `UInt/Float/Bool/etc()` | Seeded randomization, reproducible behavior |
| **Geometric Distributions** | XXHash | `OnCircle/InSphere/Rotation()` | Point clouds, particle spawning, random rotations |
| **Random Utilities** | RandomExtensions | `NextFloat2OnDisk/NextFloat3InSphere()` | Uniform disk/sphere sampling |
| **Rotation Between Vectors** | Rotation | `FromTo()` | Orientation calculations, look-at rotations |

---

## Performance Characteristics

### Compilation Target
- **Burst Compatible:** Yes (all code is compatible with Burst compilation)
- **No Allocation:** All methods are zero-allocation
- **No GC Pressure:** Uses value types (float, struct, tuples)

### Time Complexity
| Operation | Complexity | Notes |
|-----------|-----------|-------|
| CdsTween.Step | O(1) | Few multiplications & divisions |
| ExpTween.Step | O(1) | Single exp() + lerp |
| Noise.Float | O(1) | Fixed gradient lookups |
| Noise.Fractal(N octaves) | O(N) | Loop over octaves |
| XXHash hash | O(1) | Fixed bitwise operations |

### Space Complexity
- All methods are O(1) stack space
- No heap allocation

---

## Examples & Patterns

### Example 1: Spring-Based Object Following
```csharp
using UnityEngine;
using Unity.Mathematics;
using Klak.Math;

public class SpringFollower : MonoBehaviour
{
    public Transform target;
    public float speed = 4f;

    (float3 pos, float3 vel) _tweenState;

    void Start() => _tweenState = (transform.position, float3.zero);

    void Update()
    {
        var targetPos = target.position;
        (_tweenState.pos, _tweenState.vel) =
            CdsTween.Step(_tweenState, targetPos, speed);

        transform.position = _tweenState.pos;
    }
}
```

### Example 2: Procedural Creature Motion
```csharp
using UnityEngine;
using Unity.Mathematics;
using Klak.Math;

public class NoiseMotion : MonoBehaviour
{
    public uint seed = 100;
    public float frequency = 1f;
    public float radius = 1f;
    public int octaves = 3;

    void Update()
    {
        // Combine noise for X/Y/Z positions
        var t = Time.time * frequency;
        var motion = Noise.Fractal3(t, octaves, seed) * radius;

        transform.localPosition = motion;

        // Add rotational variation
        var rot = Noise.FractalRotation(
            t, octaves,
            math.float3(math.PI, math.PI * 0.5f, 0),
            seed + 1
        );
        transform.localRotation = rot;
    }
}
```

### Example 3: Seeded Random Point Spawning
```csharp
using Unity.Mathematics;
using Klak.Math;

public void SpawnParticles(int count, uint baseSeed)
{
    var hash = new XXHash(baseSeed);
    for (uint i = 0; i < count; i++)
    {
        // Spawn uniformly in sphere
        var pos = hash.InSphere(i) * 10f;

        // Random rotation
        var rot = hash.Rotation(i + 0x10000000);

        InstantiateParticle(pos, rot);
    }
}
```

---

## Version History & Evolution

### v2.1.1 (2025-12-05)
- Added signing for Unity 6.3 compatibility

### v2.1.0 (2023-07-17)
- **Added:** Extension methods for `Unity.Mathematics.Random`
- Introduced `NextFloat2OnDisk()` and `NextFloat3InSphere()`

### Earlier Versions
- Core feature set (Tween, Noise, XXHash, Rotation) stable since initial release

---

## Integration Points

### Installation
The package is distributed via UPM with the "Keijiro" scoped registry. Installation requires:
1. Add Keijiro registry to project's `manifest.json`
2. Add dependency: `"jp.keijiro.klak.math": "2.1.1"`

### Assembly Dependencies
Only requires: `com.unity.mathematics` (1.2.6+)

### Runtime Requirements
- **Minimum Unity:** 2022.3
- **Recommended:** 2023.2 LTS or later
- Works with Burst compilation (no unsafe code needed)

---

## Code Quality & Design Notes

### Strengths
1. **Focused Scope:** Library does one thing well (math utilities)
2. **Zero Allocation:** All value types, suitable for high-frequency code
3. **Deterministic:** Seed-based randomization for reproducibility
4. **Burst Compatible:** Maximizes performance in real-time systems
5. **Type Safe:** No boxing, no generics confusion
6. **Documentation:** Clear naming, good examples in Assets

### Constraints & Limitations
1. **No State:** All methods are stateless (caller manages state)
2. **Single Precision:** Uses `float` (32-bit) throughout
3. **Stateless PRNG:** Sequential calls need manual seed increment
4. **No Editor Tools:** Pure runtime library (by design)

---

## Conclusion

KlakMath is a meticulously designed, performance-focused library that solves common mathematical problems in game development through elegant, allocator-friendly APIs. Its emphasis on static methods, value types, and deterministic behavior makes it an ideal foundation for both gameplay logic and data-driven generation systems.

The architecture reflects deep understanding of C# and Unity's Burst compilation constraints, prioritizing predictability and performance over flexibility.
