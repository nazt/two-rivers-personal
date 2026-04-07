# Lesson: Real GIS Data via Overpass API for Teaching

**Date**: 2026-02-28
**Source**: PSRU Workshop follow-up
**Tags**: gis, overpass, openstreetmap, leaflet, teaching, thailand

## Pattern

When building map visualizations for workshops, use the Overpass API to load real geographic data (rivers, railways, boundaries) directly in the browser. No backend needed.

## Key Queries

### Rivers by name (Thai or English)
```
[out:json][timeout:30];
way["waterway"="river"]["name"~"น่าน|Nan"](bbox);
out geom;
```

### Railway lines in bbox
```
[out:json][timeout:30];
way["railway"="rail"](bbox);
out geom;
```

### Convert to Leaflet
```javascript
element.geometry.map(p => [p.lat, p.lon])
// → L.polyline(latlngs, { color, weight }).addTo(map)
```

## Province Boundaries

- `apisit/thailand.json` — lightweight GeoJSON for Thailand
- `geoBoundaries` ADM1 simplified — official boundaries
- Filter route provinces by name matching

## Why This Matters

- Data grounds metaphors — "สองแคว" becomes visible when you see the actual Nan and Kwae Noi rivers
- Students learn GIS concepts alongside web development
- Free, open data — no API keys needed
- Overpass POST requests work client-side (CORS allowed)
