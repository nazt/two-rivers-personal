# Landing Oracle Learning Index

## Source
- **Origin**: ./origin/
- **GitHub**: https://github.com/Soul-Brews-Studio/landing-oracle

## Explorations

### 2026-03-01 1307 (deep)
- [Architecture](2026-03-01/1307_ARCHITECTURE.md)
- [Code Snippets](2026-03-01/1307_CODE-SNIPPETS.md)
- [Quick Reference](2026-03-01/1307_QUICK-REFERENCE.md)
- [Testing](2026-03-01/1307_TESTING.md)
- [API Surface](2026-03-01/1307_API-SURFACE.md)

**Key insights**:
1. NO automated screenshot pipeline — screenshots are manually captured via Playwright CLI and committed to `public/screenshots/`
2. Gallery is fully static Astro 5 + CF Workers — oracle data in markdown frontmatter, Zod-validated at build time
3. To add oracle: create `.md` file + capture 16:10 screenshot PNG + `wrangler deploy`
