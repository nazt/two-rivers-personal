# Lesson: Camera-Relative 3D Hand Mapping

**Date**: 2026-02-28
**Context**: Hand IK integration — webcam hand tracking controlling Three.js IK character
**Source**: rrr: two-rivers-oracle

## Problem

Mapping 2D webcam hand coordinates to 3D world space for IK control.
Naive approach (webcam X → world X, webcam Y → world Y) fails because:
1. IK target `.position` is in parent bone's **local space**, not world space
2. Camera views from oblique angle — world X isn't "left/right" on screen

## Solution

```javascript
// Extract camera's actual screen axes
const camRight = new THREE.Vector3();
const camUp = new THREE.Vector3();
const camFwd = new THREE.Vector3();
camera.matrixWorld.extractBasis(camRight, camUp, camFwd);

// Project hand position onto camera-aligned plane
const armCenter = new THREE.Vector3(0.2, 0.9, 0.2);
const worldPos = armCenter.clone()
  .addScaledVector(camRight, handX)
  .addScaledVector(camUp, handY);

// Convert world → bone local space
target.parent.updateWorldMatrix(true, false);
const localPos = target.parent.worldToLocal(worldPos);
target.position.lerp(localPos, 0.15);
```

## Key Insight

`camera.matrixWorld.extractBasis()` gives the **exact screen axes** in world space:
- Column 0 = camera right (screen left→right)
- Column 1 = camera up (screen bottom→top)
- Column 2 = camera forward (into screen)

This survives OrbitControls rotation — always maps correctly regardless of camera angle.

## Related

- Three.js CCDIKSolver — bone positions are in parent local space
- MediaPipe Hands — landmarks are 0-1 normalized in image space
- hand-tracker-mqtt (Jan 2026) — previous integration used camera rotation, not IK
