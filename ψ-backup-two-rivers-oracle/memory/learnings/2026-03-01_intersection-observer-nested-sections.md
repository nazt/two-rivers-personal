# IntersectionObserver Fails for Nested Section Scroll Spy

**Date**: 2026-03-01
**Source**: rrr --deep: two-rivers-oracle
**Confidence**: High (verified in production)

## Pattern

When building scroll spy (dot nav, active menu links) for sections that are **nested inside a parent section**, `IntersectionObserver` produces incorrect results.

### Why It Breaks

```
<section id="workshop">        ← parent, always "intersecting" while scrolling through children
  <div id="landings">          ← child
  <div id="student-oracles">   ← child
  <div id="senior-projects">   ← child
</section>
```

- IO fires based on threshold crossings (enter/exit)
- Parent section remains "intersecting" indefinitely while any child is visible
- Scrolling UP between adjacent children produces **no state change** — both already intersecting
- Active state freezes on whichever subsection entered viewport last

### The Fix

Replace IO with synchronous scroll-position math:

```javascript
var rafId;
function updateSpy() {
  var active = 0;
  for (var i = sections.length - 1; i >= 0; i--) {
    if (sections[i] && sections[i].getBoundingClientRect().top <= 120) {
      active = i; break;
    }
  }
  setActive(active);
  rafId = 0;
}
window.addEventListener('scroll', function() {
  if (!rafId) rafId = requestAnimationFrame(updateSpy);
}, { passive: true });
```

- Iterates sections **bottom-to-top** — last past threshold wins
- `requestAnimationFrame` debounce for performance
- `passive: true` never blocks scroll
- Works for all scroll directions and any nesting depth

### Decision Tree

| Use Case | Tool |
|----------|------|
| Element entry/exit detection | IntersectionObserver |
| Scroll reveal (one-shot) | IntersectionObserver |
| Lazy loading | IntersectionObserver |
| Contextual show/hide (Report button) | IntersectionObserver + `boundingClientRect.top < 0` |
| **Which of N sections is active** | **Scroll position math** |
| **Nested/overlapping sections** | **Scroll position math** |

## Related

- `scroll-margin-top: 80px` — correct anchor offset for fixed navbars (CSS spec, no layout side effects)
- `.dot.sub { width: 7px }` — visual hierarchy for subsection dots (3 lines CSS, 0 lines JS)
- Generic CSS selector landmine — use `<div>` not `<nav>` when global `nav {}` rules exist

## Concepts

`scroll-spy`, `IntersectionObserver`, `getBoundingClientRect`, `dot-nav`, `nested-sections`, `rAF-debounce`
