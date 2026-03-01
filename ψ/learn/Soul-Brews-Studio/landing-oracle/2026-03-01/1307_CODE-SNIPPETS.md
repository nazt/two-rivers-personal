# Landing Oracle — Code Patterns & Snippets

## Gallery Card Component

### Image Rendering with Lazy Load
```astro
<img
  src={oracle.screenshot}
  loading="lazy"
  decoding="async"
  class="object-cover object-top"
  alt={`${oracle.name} screenshot`}
/>
```

**Key Properties:**
- `loading="lazy"` — Browser-native lazy loading (viewport detection)
- `decoding="async"` — Non-blocking image decode (prevents layout jank)
- `object-cover object-top` — CSS for fitting: cover entire container, anchor to top
- Aspect ratio maintained by parent container (16:10)

### Hover Overlay Effect
```astro
<div class="group relative">
  <img src={oracle.screenshot} ... />
  <div class="absolute inset-0 bg-black/20 backdrop-blur-sm opacity-0 group-hover:opacity-100 group-hover:scale-105 transition-all duration-300">
    <!-- overlay content -->
  </div>
</div>
```

## Content Schema (Zod)

### Oracle Data Validation
```typescript
const OracleSchema = z.object({
  name: z.string(),
  screenshot: z.string().optional(),
  status: z.enum(["live", "known"]),
  primary: z.string(),      // hex color #RRGGBB
  secondary: z.string(),    // hex color #RRGGBB
  background: z.string(),   // hex color #RRGGBB
});

type Oracle = z.infer<typeof OracleSchema>;
```

**Validation Timing:** Build time via Content Collections glob loader
**Failure Behavior:** Build fails with clear schema error messages

### Markdown Frontmatter Example
```yaml
---
name: "Two Rivers"
screenshot: "/screenshots/two-rivers.png"
status: "live"
primary: "#0F4C75"
secondary: "#3282B8"
background: "#E8F4F8"
---
Oracle description text here...
```

## Theme System (Nanostores)

### Palette Atom
```typescript
import { atom } from "nanostores";

export const $palette = atom<"clarity" | "royal" | "nature">("clarity");
export const $rotating = atom<boolean>(true);

// Subscribe to changes
$palette.subscribe((value) => {
  document.documentElement.style.setProperty("--theme-primary", value);
});
```

### Auto-Rotation Logic
```typescript
setInterval(() => {
  if ($rotating.get()) {
    const current = $palette.get();
    const themes = ["clarity", "royal", "nature"];
    const next = themes[(themes.indexOf(current) + 1) % 3];
    $palette.set(next);
  }
}, 6000);  // 6 second rotation
```

### Persistence
```typescript
// Save to localStorage
localStorage.setItem("oracle-theme", $palette.get());

// Restore on page load
const saved = localStorage.getItem("oracle-theme");
if (saved) $palette.set(saved);
```

## Dot Grid Preview System

### CSS Custom Properties
```css
/* Set per oracle in template */
--preview-img: url(/screenshots/two-rivers.png);

/* Applied on hover */
.dot:hover {
  background-image: var(--preview-img);
  background-size: cover;
  background-position: center;
  width: 180px;
  height: 120px;
  z-index: 50;
}
```

### Dynamic Grid Generation
```astro
{oracles.map(oracle => (
  <div
    class="dot group relative"
    style={{
      '--preview-img': `url(${oracle.screenshot})`,
    }}
    title={oracle.name}
  >
    <div class="hidden group-hover:block absolute pointer-events-none">
      {/* preview tooltip */}
    </div>
  </div>
))}
```

## Content Collection Setup

### astro.config.ts
```typescript
import { defineConfig } from "astro/config";
import { getCollection } from "astro:content";

export default defineConfig({
  integrations: [
    // ... other integrations
  ],
});
```

### Content Collections Entry Point
```typescript
// src/content/config.ts
import { defineCollection } from "astro:content";
import { OracleSchema } from "../schemas";

const oracles = defineCollection({
  loader: glob({ pattern: "**/*.md", base: "./src/data/oracles" }),
  schema: OracleSchema,
});

export const collections = { oracles };
```

### Usage in Templates
```astro
---
import { getCollection } from "astro:content";

const allOracles = await getCollection("oracles");
const liveOracles = allOracles.filter(o => o.data.status === "live");
---

{liveOracles.map(oracle => (
  <GalleryCard oracle={oracle.data} />
))}
```

## Path References

### Screenshot Path Pattern
All screenshot paths are relative to `public/`:
```
screenshot: "/screenshots/{oracle-name}.png"
```

Resolves to disk path:
```
public/screenshots/{oracle-name}.png
```

In HTML output:
```html
<img src="/screenshots/two-rivers.png" />
```

Cloudflare serves from `dist/screenshots/` (copied during build).

## Build-Time Processing

### Image Optimization (Implicit)
```
src/pages/index.astro
  → getCollection("oracles")
  → filter by status
  → pass to GalleryCard
  → astro build → dist/
  → wrangler deploy → CF Workers
```

**No runtime image processing.** Static images served as-is from CF edge.

## Type Safety Throughout

```typescript
// Component receives fully-typed data
interface Props {
  oracle: Oracle;  // Zod-validated
}

const { oracle }: Props = Astro.props;
// oracle.name is string
// oracle.screenshot is string | undefined
// oracle.primary is string
```

All type checking happens at build time. Runtime is fully type-safe.
