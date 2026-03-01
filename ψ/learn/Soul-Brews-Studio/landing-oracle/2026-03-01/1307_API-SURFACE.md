# Landing Oracle — API Surface

## Architecture: Fully Static (No Backend API)

Landing-oracle is a **zero-backend** static site. All "APIs" are compile-time abstractions over markdown data.

---

## Data Source: Markdown Files

### Oracle Profiles Collection
**Location:** `src/data/oracles/*.md`

**Access Method:** Astro Content Collections
```astro
import { getCollection } from "astro:content";

// Returns array of validated oracle objects
const oracles = await getCollection("oracles");

// Each oracle is typed as:
// {
//   id: string;
//   data: {
//     name: string;
//     screenshot?: string;
//     status: "live" | "known";
//     primary: string;
//     secondary: string;
//     background: string;
//   }
//   body: string;  // markdown content
// }
```

**"API" Endpoints (Build-Time Only):**
```astro
// Get all oracles
const all = await getCollection("oracles");

// Filter by status
const live = all.filter(o => o.data.status === "live");
const known = all.filter(o => o.data.status === "known");

// Find by name
const found = all.find(o => o.data.name === "Two Rivers");

// Get oracles with screenshots
const withScreenshots = all.filter(o => o.data.screenshot);
```

**Key Property:** All queries execute at build time. No runtime fetching.

---

## Astro Content Collections: The "API Layer"

### Collection Definition
**File:** `src/content/config.ts`

```typescript
import { defineCollection } from "astro:content";
import { OracleSchema } from "../schemas";

const oracles = defineCollection({
  loader: glob({
    pattern: "**/*.md",
    base: "./src/data/oracles"
  }),
  schema: OracleSchema,
});

export const collections = { oracles };
```

**What Happens:**
1. Glob finds all `.md` files in `src/data/oracles/`
2. Each file parsed as markdown + YAML frontmatter
3. Data validated against `OracleSchema` (Zod)
4. Collection exposed as `getCollection("oracles")`
5. Available in all `.astro` pages and components

### Schema Definition
**File:** `src/schemas.ts` (conceptual — exact location may vary)

```typescript
import { z } from "astro/zod";

export const OracleSchema = z.object({
  name: z.string(),
  screenshot: z.string().optional(),
  status: z.enum(["live", "known"]),
  primary: z.string(),    // hex color
  secondary: z.string(),  // hex color
  background: z.string(), // hex color
});
```

**Validation Timing:** Build time (before site generation)
**Failure:** Build stops, clear error message with file path

---

## Usage Patterns in Templates

### Main Gallery Page
**File:** `src/pages/index.astro`

```astro
---
import { getCollection } from "astro:content";
import GalleryCard from "../components/GalleryCard.astro";

// Query the "API"
const allOracles = await getCollection("oracles");

// Filter (business logic)
const displayedOracles = allOracles
  .filter(o => o.data.status === "live")
  .sort((a, b) => a.data.name.localeCompare(b.data.name));
---

<main>
  <div class="gallery">
    {displayedOracles.map(oracle => (
      <GalleryCard oracle={oracle.data} />
    ))}
  </div>
</main>
```

### Component Usage
**File:** `src/components/GalleryCard.astro`

```astro
---
import type { CollectionEntry } from "astro:content";

interface Props {
  oracle: CollectionEntry<"oracles">["data"];
}

const { oracle } = Astro.props;
---

<div
  class="card"
  style={{
    '--primary': oracle.primary,
    '--secondary': oracle.secondary,
    '--background': oracle.background,
  }}
>
  {oracle.screenshot && (
    <img src={oracle.screenshot} alt={oracle.name} loading="lazy" />
  )}
  <h2>{oracle.name}</h2>
</div>
```

---

## Static Generation Pipeline

```
src/data/oracles/*.md
    ↓
getCollection("oracles")
    ↓
Zod validation
    ↓
Filter/sort/transform
    ↓
Pass to components
    ↓
Astro renders → static HTML
    ↓
dist/{index}.html (pre-rendered)
    ↓
Cloudflare Workers serves dist/
    ↓
Browser receives static HTML + CSS + JS
```

**Key:** No runtime API calls. No client-side data fetching. All resolved at build.

---

## Public Static Assets

### Screenshot Images
**Location:** `public/screenshots/*.png`

**Access:** Via static path reference
```
src={oracle.screenshot}  // e.g., "/screenshots/two-rivers.png"
```

**Resolution:**
```
/screenshots/two-rivers.png
    ↓ (during build)
public/screenshots/two-rivers.png
    ↓ (copied to)
dist/screenshots/two-rivers.png
    ↓ (served by CF Workers)
https://gallery.buildwithoracle.com/screenshots/two-rivers.png
```

### Static HTML Output
**Location:** `dist/`

After build:
```
dist/
├── index.html          (pre-rendered)
├── screenshots/
│   ├── two-rivers.png
│   ├── arthur.png
│   └── ...
├── _astro/
│   ├── index.*.css     (bundled styles)
│   └── index.*.js      (bundled JavaScript)
└── ...
```

---

## Cloudflare Workers Deployment

### No Dynamic Routes
```toml
# wrangler.toml
[[env.production.routes]]
pattern = "gallery.buildwithoracle.com/*"
zone_id = "..."

# Serves static dist/ directory as-is
# No server code execution
```

### Serving Model
```
User Request
    ↓
CF Edge (cache check)
    ↓
Static file from dist/
    ↓
Response (with CF caching headers)
```

**No API Routes:** CF Workers acts as static file server only. No `/api/*` endpoints.

---

## Extension Points

### Add New Oracle (Data-Driven)
1. Create `src/data/oracles/{name}.md`
2. Include required YAML frontmatter
3. `npm run build` (Content Collections picks it up)
4. `wrangler deploy`

**No code changes needed.** System is purely data-driven.

### Modify Gallery Layout (Code Change)
1. Edit `src/pages/index.astro`
2. Adjust grid layout, sorting, filtering
3. `npm run build`
4. `wrangler deploy`

**No schema changes needed.** Uses existing oracle data.

### Add New Color Theme
1. Define new theme in `src/stores/theme.ts`
2. Add CSS variables for new theme colors
3. Update theme switching logic
4. `npm run build`
5. `wrangler deploy`

**All oracles automatically support new theme** (via CSS custom properties).

---

## Build-Time Transformations

### What Happens at `npm run build`

```
Input:  src/data/oracles/two-rivers.md
  ---
  name: "Two Rivers"
  screenshot: "/screenshots/two-rivers.png"
  status: "live"
  primary: "#0F4C75"
  secondary: "#3282B8"
  background: "#E8F4F8"
  ---
  Oracle description...

    ↓ (parse + validate)

Output: In-memory object
  {
    id: "two-rivers",
    data: {
      name: "Two Rivers",
      screenshot: "/screenshots/two-rivers.png",
      status: "live",
      primary: "#0F4C75",
      secondary: "#3282B8",
      background: "#E8F4F8"
    },
    body: "Oracle description..."
  }

    ↓ (pass to templates)

Final: dist/index.html contains pre-rendered card with colors inline
  <div style="--primary:#0F4C75;--secondary:#3282B8;...">
    <h2>Two Rivers</h2>
    <img src="/screenshots/two-rivers.png" ...>
  </div>
```

---

## No Runtime Features

### NOT Available
- No database queries
- No API endpoints (no `/api/*`)
- No authentication/authorization
- No form processing (no backend handlers)
- No real-time updates
- No user sessions
- No server-side rendering (SSR)
- No incremental static regeneration (ISR)

### Runtime Features Available
- CSS animations (local)
- JavaScript event handlers (client-side)
- LocalStorage persistence (theme preference)
- Smooth transitions (Tailwind CSS)

---

## Query Language: Astro Template Syntax

All queries written in `.astro` templates at build time:

```astro
---
// getCollection() - query
const all = await getCollection("oracles");

// .filter() - where clause
const live = all.filter(o => o.data.status === "live");

// .find() - single record
const first = all.find(o => o.data.name === "Two Rivers");

// .map() - projection
const names = all.map(o => o.data.name);

// .sort() - ordering
const sorted = all.sort((a, b) =>
  a.data.name.localeCompare(b.data.name)
);

// .length - count
const total = all.length;
---
```

No SQL. No GraphQL. Plain TypeScript/JavaScript.

---

## Type Safety

### Complete Type Information
```typescript
import type { CollectionEntry } from "astro:content";

type Oracle = CollectionEntry<"oracles">;
// {
//   id: string;
//   data: {
//     name: string;
//     screenshot?: string;
//     status: "live" | "known";
//     primary: string;
//     secondary: string;
//     background: string;
//   };
//   body: string;
// }
```

### Component Props
```astro
interface Props {
  oracle: Oracle["data"];  // Fully typed
}
```

**All types inferred from Zod schema.** Zero runtime type checks needed.

---

## Caching Strategy

### Build Output
- `dist/index.html` — immutable (content-hash in filename)
- `dist/screenshots/*.png` — long-lived (static assets)
- `dist/_astro/*.css` — content-addressed (hash-based)
- `dist/_astro/*.js` — content-addressed (hash-based)

### CF Edge Caching
```
Cache-Control: public, max-age=31536000 (1 year)
  for: *.png, *.css, *.js (fingerprinted)

Cache-Control: public, max-age=3600 (1 hour)
  for: /index.html (entry point)
```

**No cache invalidation needed** for oracle data changes (new build = new filenames).

---

## Summary

| Aspect | Implementation |
|--------|-----------------|
| **Data Source** | Markdown files in `src/data/oracles/` |
| **Data Query** | Astro Content Collections + JavaScript |
| **API Type** | Build-time static composition (no runtime API) |
| **Backend** | None (fully static) |
| **Database** | None (markdown files as source of truth) |
| **Authentication** | None (public gallery) |
| **Deployment** | Cloudflare Workers (static file serving) |
| **Type Safety** | Full TypeScript + Zod validation |
| **Extension** | Add `.md` files + optional PNG screenshots |
| **Scalability** | Linear (one `.md` file per oracle) |

**Architecture:** Zero-backend JAMstack static site with build-time data composition.
