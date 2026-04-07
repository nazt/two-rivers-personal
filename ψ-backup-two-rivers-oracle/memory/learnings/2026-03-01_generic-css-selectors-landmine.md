# Generic CSS Selectors Are Landmines

**Date**: 2026-03-01
**Source**: rrr: two-rivers-oracle
**Context**: Added `<nav class="dot-nav">` for right-side dot navigation, but generic `nav {}` CSS rule applied position, background, blur, padding to it — breaking layout completely.

## Pattern

When a codebase uses generic element selectors like `nav {}`, `a {}`, `section {}`, adding a new element of the same type inherits ALL those styles. This is invisible until deployed.

## Fix

1. **Check first**: Before adding a new element, grep for generic selectors targeting that element type
2. **Scope with classes**: Use `.top-nav` instead of `nav`, or change new element to `<div>` to avoid conflicts
3. **Override explicitly**: If you must use the same element, override every conflicting property

## In this case

Changed `<nav class="dot-nav">` to `<div class="dot-nav">` — eliminated all conflicts instantly. The 10 lines of CSS overrides were replaced by 0.

## Also learned

- `IntersectionObserver` + `boundingClientRect.top < 0` distinguishes "scrolled past element" from "element below viewport" — essential for scroll-triggered UI that shouldn't show on page load
- `inline-flex` with `align-items: center` is the correct way to vertically center text in inline button elements, not `line-height` or `text-align`
