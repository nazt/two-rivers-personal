# KlakMath: Code Snippets & Patterns

## Overview

KlakMath is a high-performance Unity C# math library by keijiro focused on noise generation, hashing, interpolation, and geometric utilities. It leverages Unity.Mathematics for SIMD optimizations and Burst compilation.

**Key modules:**
- Gradient noise (1D/2D/3D/4D)
- XXHash-based deterministic random generation
- Exponential and critically damped spring tweening
- Quaternion/rotation utilities
- Geometric utilities (sphere sampling, disk sampling, etc.)

---

## 1. Gradient Noise Implementation

### 1D Gradient Noise (Base Implementation)

**File:** `Noise.cs` (lines 11-27)

```csharp
public static float Float(float p, uint seed)
{
    var hash = new XXHash(seed);

    var i = (uint)((int)p + 0x10000000);
    var x = math.frac(p);

    var k = math.float2(x, 1 - x);
    k = 1 - k * k;
    k = k * k * k;

    var g = math.float2(hash.Float(-1, 1, i    ),
                        hash.Float(-1, 1, i + 1));

    var n = math.dot(k * g, math.float2(x, x - 1));
    return n * 2 * 32 / 27;
}
```

**What it does:**
- Generates smooth 1D perlin-like noise using gradient interpolation
- Takes a position `p` and a `seed` for reproducible randomness
- Uses hermite curve smoothing: `1 - k*k` then cubed for smooth transitions
- Interpolates between two random gradients at integer boundaries
- Normalizes output by factor of ~2.37 (32/27)

**Clever techniques:**
- Uses `0x10000000` offset to avoid negative indices
- Hermite polynomial smoothing via `k = (1-k²)³` ensures smooth derivatives
- Hash-based gradients are deterministic per seed

---

### Vector Noise Generators (2D/3D/4D)

**File:** `Noise.cs` (lines 33-97)

```csharp
public static float3 Float3(float3 p, uint seed)
{
    var hash = new XXHash(seed);

    var i = (uint3)((int3)p + 0x10000000);
    var x = math.frac(p);

    var x0 = x;
    x0 = 1 - x0 * x0;
    x0 = x0 * x0 * x0;

    var x1 = 1 - x;
    x1 = 1 - x1 * x1;
    x1 = x1 * x1 * x1;

    var g0 = hash.Float3(-1, 1, i);
    var g1 = hash.Float3(-1, 1, i + 1);

    var n = x0 * g0 * x + x1 * g1 * (x - 1);
    return n * 2 * 32 / 27;
}
```

**What it does:**
- Extends 1D noise to 3D space (also available: Float2, Float4)
- Returns a float3 with noise sampled across xyz dimensions
- Uses per-component smoothing curves (x0, x1)
- Interpolates between two 3D gradient vectors

**Pattern:**
All vector noise functions follow the same pattern:
1. Hash the integer cell coordinates
2. Compute fractional position within cell
3. Apply smoothing curve (hermite)
4. Generate random gradients and interpolate
5. Normalize output

---

### Fractal (Octave) Noise

**File:** `Noise.cs` (lines 103-153)

```csharp
public static float Fractal(float p, int octave, uint seed)
{
    var f = 0.0f;
    var w = 1.0f;
    for (var i = 0; i < octave; i++)
    {
        f += w * Float(p, seed);
        p *= 2.0f;
        w *= 0.5f;
    }
    return f;
}

public static float3 Fractal3(float3 p, int octave, uint seed)
{
    var f = (float3)0;
    var w = 1.0f;
    for (var i = 0; i < octave; i++)
    {
        f += w * Float3(p, seed);
        p *= 2.0f;
        w *= 0.5f;
    }
    return f;
}
```

**What it does:**
- Combines multiple octaves of noise for more detail (fractional brownian motion)
- Each octave: frequencies double, amplitudes halve (standard 1/f pattern)
- Accumulates weighted noise layers
- Available in 1D, 2D, 3D, 4D variants

**Usage pattern (from NoiseMotion.cs):**
```csharp
var x = (Time.time + 100) * _frequency * hash.Float3(0.95f, 1.05f, 0);
transform.localPosition = Noise.Fractal3(x, _octaves, _seed) * _radius;
```

---

### Quaternion Generators via Noise

**File:** `Noise.cs` (lines 159-164)

```csharp
public static quaternion Rotation(float3 p, float3 angles, uint seed)
  => quaternion.EulerZXY(angles * Float3(p, seed));

public static quaternion
  FractalRotation(float3 p, int octave, float3 angles, uint seed)
  => quaternion.EulerZXY(angles * Fractal3(p, octave, seed));
```

**What it does:**
- Converts 3D noise to quaternion rotations
- Scales noise output to angle ranges (radians)
- Uses Euler ZXY rotation convention (Unity standard)

**Example usage:**
```csharp
transform.localRotation = Noise.FractalRotation(x, _octaves, _angle, _seed + 1);
```

---

## 2. XXHash: Deterministic Random Number Generation

### Core XXHash Implementation

**File:** `XXHash.cs` (lines 7-263)

```csharp
public readonly struct XXHash
{
    public uint Seed { get; }

    public XXHash(uint seed) => Seed = seed;

    // Base hash computation (simplified)
    static uint CalculateHash(uint data, uint seed)
    {
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

    const uint PRIME32_1 = 2654435761U;
    const uint PRIME32_2 = 2246822519U;
    const uint PRIME32_3 = 3266489917U;
    const uint PRIME32_4 = 668265263U;
    const uint PRIME32_5 = 374761393U;

    static uint rotl32(uint x, int r) => (x << r) | (x >> 32 - r);
}
```

**What it does:**
- Implements XXHash algorithm for deterministic hashing
- Uses Knuth's prime constants for good distribution
- Bit rotations and XOR mixing for avalanche effect
- All operations are deterministic (same seed = same output)

**Clever techniques:**
- Prime constants chosen for their mathematical properties
- Rotation amounts (17, 15, 13, 16) empirically optimize distribution
- XOR shifts at different positions break patterns
- No loops = Burst-compilable

---

### Random Number Range Methods

**File:** `XXHash.cs` (lines 17-140)

```csharp
// UInt: Full range
public uint  UInt (uint  data) => CalculateHash(data, Seed);
public uint2 UInt2(uint2 data) => CalculateHash(data, (uint2)Seed);

// UInt: (0 - Max) range
public uint  UInt (uint max, uint  data) => math.select(0u, UInt (data) % max, max > 0u);
public uint2 UInt2(uint max, uint2 data) => math.select(0u, UInt2(data) % max, max > 0u);

// UInt: (Min - Max) range
public uint  UInt (uint min, uint max, uint  data) => UInt (max - min, data) + min;
public uint2 UInt2(uint min, uint max, uint2 data) => UInt2(max - min, data) + min;

// Float: Full range (0-1)
public float  Float (uint  data) =>         UInt (data) / (float)uint.MaxValue;
public float2 Float2(uint  data) => (float2)UInt2(data) / (float)uint.MaxValue;

// Float: (Min - Max) range
public float  Float (float  min, float  max, uint  data)
  => Float (data) * (max - min) + min;
public float2 Float2(float2 min, float2 max, uint  data)
  => Float2(data) * (max - min) + min;
```

**What it does:**
- Provides range-constrained random numbers (uint or float)
- Overloads for scalar, 2D, 3D, 4D vectors
- Uses `math.select()` for branchless clamping
- Floating-point division normalizes to [0,1]

**Example usage:**
```csharp
var hash = new XXHash(100);
var randomFloat = hash.Float(-1, 1, i);      // Range: [-1, 1]
var randomPos = hash.Float3(0, 1, data);     // 3D: [0,1]³
```

---

### Geometric Utilities

**File:** `XXHash.cs` (lines 144-179)

```csharp
// On unit circle
public float2 OnCircle(uint data)
{
    var phi = Float(math.PI * 2, data);
    return math.float2(math.cos(phi), math.sin(phi));
}

// Inside unit circle (disk)
public float2 InCircle(uint data)
  => OnCircle(data) * math.sqrt(Float(data + 0x10000000));

// On unit sphere
public float3 OnSphere(uint data)
{
    var phi = Float(math.PI * 2, data);
    var z = Float(-1, 1, data + 0x10000000);
    var w = math.sqrt(1 - z * z);
    return math.float3(math.cos(phi) * w, math.sin(phi) * w, z);
}

// Inside unit sphere
public float3 InSphere(uint data)
  => OnSphere(data) * math.pow(Float(data + 0x20000000), 1.0f / 3);

// Random quaternion (rotation)
public quaternion Rotation(uint data)
{
    var u1 = Float(data);
    var r1 = Float(math.PI * 2, data + 0x10000000);
    var r2 = Float(math.PI * 2, data + 0x20000000);
    var s1 = math.sqrt(1 - u1);
    var s2 = math.sqrt(    u1);
    var v = math.float4(s1 * math.sin(r1), s1 * math.cos(r1),
                        s1 * math.sin(r2), s2 * math.cos(r2));
    return math.quaternion(math.select(v, -v, v.w < 0));
}
```

**What it does:**
- Generates uniformly distributed points in geometric shapes
- **OnCircle/OnSphere:** Points on surfaces (S¹/S²)
- **InCircle/InSphere:** Points within volumes (D²/D³)
- **Rotation:** Uniformly distributed quaternions (solid angle)

**Key mathematical insights:**
- Sphere sampling: uses azimuthal angle + z-component parameterization
- Disk/sphere inside: uses cubic root scaling to maintain uniform volume distribution
- Quaternion: uses 4D distribution formula (Shoemake's algorithm)
- Offset indices (`0x10000000`, `0x20000000`) ensure decorrelated random streams

**Example usage:**
```csharp
var hash = new XXHash(100);
var meshVertices = Enumerable.Range(0, 1000)
    .Select(i => (Vector3)hash.OnSphere((uint)i))
    .ToArray();
```

---

## 3. Interpolation & Tweening

### Exponential Tween

**File:** `ExpTween.cs` (lines 11-56)

```csharp
public static float Step(float x, float target, float speed)
  => Step(x, target, speed, UnityEngine.Time.deltaTime);

public static float Step(float x, float target, float speed, float dt)
  => math.lerp(target, x, math.exp(-speed * dt));

// Also supports: float2, float3, float4, quaternion
public static quaternion Step(quaternion x, quaternion target, float speed, float dt)
  => math.nlerp(target, x, math.exp(-speed * dt));
```

**What it does:**
- Smooth exponential approach to target (first-order system)
- Physics-based: exponential decay with `e^(-speed * dt)`
- Fast convergence when speed is high
- Always smooth, never oscillates
- For quaternions: uses normalized linear interpolation (nlerp)

**Mathematical basis:**
```
x_new = lerp(target, current, e^(-speed * dt))
      = target + (current - target) * e^(-speed * dt)
```
This is the solution to: `dx/dt = -speed * (x - target)`

**Example usage (from TweenTest.cs):**
```csharp
void Update()
{
    var p = transform.localPosition;
    var r = transform.localRotation;

    p = ExpTween.Step(p, _target.p, _speed);
    r = ExpTween.Step(r, _target.r, _speed);

    transform.localPosition = p;
    transform.localRotation = r;
}
```

---

### Critically Damped Spring Tween

**File:** `CdsTween.cs` (lines 11-90)

```csharp
public static (float x, float v)
  Step((float x, float v) state, float target, float speed)
  => Step(state, target, speed, UnityEngine.Time.deltaTime);

public static (float x, float v)
  Step((float x, float v) state, float target, float speed, float dt)
{
    var n1 = state.v - (state.x - target) * (speed * speed * dt);
    var n2 = 1 + speed * dt;
    var nv = n1 / (n2 * n2);
    return (state.x + nv * dt, nv);
}

// Also supports: float2, float3, float4, quaternion
public static (quaternion x, float4 v)
  Step((quaternion x, float4 v) state, quaternion target, float speed, float dt)
{
    if (math.dot(state.x, target) < 0) target.value *= -1;
    var n = Step((state.x.value, state.v), target.value, speed, dt);
    return (math.normalize(math.quaternion(n.x)), n.v);
}
```

**What it does:**
- Smooth approach with velocity tracking (second-order system)
- Critically damped: fastest approach without oscillation
- Returns both position AND velocity
- Quaternion version handles shortest path via dot product check

**Mathematical basis:**
This solves the critically damped spring equation:
```
d²x/dt² + 2*speed*dx/dt + speed²*x = speed²*target
```

The implementation uses discrete integration:
```
v_new = (v - (x - target) * speed² * dt) / (1 + speed*dt)²
x_new = x + v_new * dt
```

**When to use (vs ExpTween):**
- **ExpTween:** Simple, one-variable smoothing
- **CdsTween:** Needs natural motion with momentum/inertia

**Example usage (from TweenTest.cs):**
```csharp
// Track velocity state
(float3 p, float4 r) _velocity;

void Update()
{
    (var p, _velocity.p) = CdsTween.Step(
        (transform.position, _velocity.p),
        _target.p,
        _speed
    );
    (var r, _velocity.r) = CdsTween.Step(
        (transform.rotation, _velocity.r),
        _target.r,
        _speed
    );
}
```

---

## 4. Rotation Utilities

### FromTo: Create rotation between two vectors

**File:** `Rotation.cs` (lines 9-15)

```csharp
public static quaternion FromTo(float3 v1, float3 v2)
{
    var a = math.cross(v1, v2);
    var v1v2 = math.dot(v1, v1) * math.dot(v2, v2);
    var w = math.sqrt(v1v2) + math.dot(v1, v2);
    return math.normalizesafe(math.quaternion(math.float4(a, w)));
}
```

**What it does:**
- Computes quaternion that rotates v1 into v2
- No gimbal lock issues
- Handles edge cases via `normalizesafe`

**Mathematical basis:**
Uses the cross product as rotation axis and ensures proper w component via:
```
w = sqrt(|v1|² |v2|²) + v1·v2
axis = v1 × v2
```

This avoids numerical issues with the standard `acos()` formula.

---

## 5. Random Extensions

**File:** `RandomExtensions.cs` (lines 10-15)

```csharp
// On unit disk
public static float2 NextFloat2OnDisk(ref this Random self)
  => self.NextFloat2Direction() * math.sqrt(self.NextFloat());

// In unit sphere
public static float3 NextFloat3InSphere(ref this Random self)
  => self.NextFloat3Direction() * math.pow(self.NextFloat(), 1.0f / 3);
```

**What it does:**
- Extensions to Unity's Random struct for geometric sampling
- Disk: direction * sqrt(radius) maintains uniform area distribution
- Sphere: direction * cbrt(radius) maintains uniform volume distribution

**Usage pattern:**
```csharp
var random = Random.CreateWithSeed(seed);
var posOnDisk = random.NextFloat2OnDisk();
var posInSphere = random.NextFloat3InSphere();
```

---

## 6. Integration Patterns

### Pattern 1: Noise-Driven Motion

**Example from NoiseMotion.cs:**

```csharp
void Update()
{
    var hash = new XXHash(_seed + 0x100000);
    var x = (Time.time + 100) * _frequency * hash.Float3(0.95f, 1.05f, 0);
    transform.localPosition = Noise.Fractal3(x, _octaves, _seed) * _radius;
    transform.localRotation = Noise.FractalRotation(x, _octaves, _angle, _seed + 1);
}
```

**Pattern:**
1. Create hash generator with seed
2. Scale time by frequency, optionally apply random multiplier
3. Use Fractal noise for smooth multi-octave variation
4. Scale output to desired range

---

### Pattern 2: Procedural Generation with XXHash

**Example from HashOnSphereTest.cs:**

```csharp
void Start()
{
    var hash = new XXHash(_seed);
    var mesh = new Mesh();
    var indices = Enumerable.Range(0, _iteration);
    var vertices = indices.Select(i => (Vector3)hash.OnSphere((uint)i));
    mesh.vertices = vertices.ToArray();
    mesh.SetIndices(indices.ToArray(), MeshTopology.Points, 0);
    GetComponent<MeshFilter>().sharedMesh = mesh;
}
```

**Pattern:**
1. Seed the hash generator
2. For each index, generate deterministic geometric data
3. Use different offset indices for different spatial dimensions

---

### Pattern 3: Tweened Position/Rotation

**Example from TweenTest.cs (ExpTween):**

```csharp
void Update()
{
    var p = transform.localPosition;
    var r = transform.localRotation;

    p = ExpTween.Step(p, _target.p, _speed);
    r = ExpTween.Step(r, _target.r, _speed);

    transform.localPosition = p;
    transform.localRotation = r;
}
```

**For CdsTween (with velocity):**

```csharp
(float3 p, float4 r) _velocity;  // State

void Update()
{
    var p = transform.localPosition;
    var r = transform.localRotation;

    (p, _velocity.p) = CdsTween.Step((p, _velocity.p), _target.p, _speed);
    (r, _velocity.r) = CdsTween.Step((r, _velocity.r), _target.r, _speed);

    transform.localPosition = p;
    transform.localRotation = r;
}
```

---

## 7. Key Design Principles

### 1. Deterministic by Default
- XXHash seed ensures reproducibility
- Same seed always produces same sequence
- Enables procedural generation and networked play

### 2. SIMD-Friendly
- Uses Unity.Mathematics types (float2, float3, float4)
- All math operations operate on vectors
- Burst compilation support for high performance

### 3. No Branches When Possible
- Uses `math.select()` for conditional operations
- Avoids if/else in inner loops
- Enables GPU and Burst vectorization

### 4. Memory Efficient
- Struct-based (no heap allocation)
- Noise and tween functions are stateless
- CdsTween tracks only (position, velocity) tuples

### 5. Flexibility
- Multiple overloads for scalar and vector types
- Explicit time delta support (or auto Time.deltaTime)
- Range-bounded random generation

---

## 8. Performance Considerations

### Burst Compilation Friendly
All functions are designed for Burst:
- No virtual methods
- No string operations
- No heap allocations
- Deterministic structure

### Cache-Friendly
- XXHash uses bit operations (cache-efficient)
- Noise uses sequential operations
- No random memory access patterns

### Suitable for Compute Shaders
XXHash and Noise algorithms translatable to HLSL/GLSL

---

## Summary Table

| Feature | File | Type | Key Use |
|---------|------|------|---------|
| 1D/3D/4D Gradient Noise | Noise.cs | Procedural | Terrain, clouds, variation |
| Fractal Noise | Noise.cs | Procedural | Multi-scale detail |
| Noise-based Rotations | Noise.cs | Procedural | Animated rotations |
| XXHash Random | XXHash.cs | RNG | Deterministic procedural |
| Geometric Sampling | XXHash.cs | Geometry | Sphere/circle points |
| Exponential Tween | ExpTween.cs | Animation | Smooth approach |
| Critical Damped Spring | CdsTween.cs | Animation | Natural motion |
| Vector Rotation | Rotation.cs | Math | Rotate v1 → v2 |

