# Lesson: Parallel Agent Teams for Bulk Page Generation

**Date**: 2026-02-28
**Context**: Building 14 PSRU student project simulator pages
**Source**: rrr: two-rivers-oracle

## Pattern

When generating many similar-but-distinct pages (simulators, dashboards, demos):

1. **Group by tech stack**, not by complexity or project number
   - Agents sharing CDN deps (p5.js, Three.js, Leaflet) produce more consistent output
   - Shared interaction patterns emerge naturally within groups

2. **Provide a concrete template file** (floodboy.html) + specific content brief per page
   - Template = structure, theme, MQTT pattern, responsive grid
   - Brief = unique content, Thai text, project-specific features

3. **Use worktree isolation** for zero merge conflicts
   - 6 agents writing to the same `docs/` directory simultaneously
   - No coordination needed between agents

4. **Block the integration task** on all generation tasks
   - index.html update waits until all pages exist
   - Lead agent handles the integration, not a worker agent

## Numbers

- 6 agents, 14 pages, ~11K lines, ~20 min wall clock
- Average ~1,800 lines per agent, ~750 lines per page
- Each page: 22-34KB self-contained HTML

## Anti-pattern

Don't let worker agents pick up integration tasks (like updating index.html) — the lead has the full picture and should do it.
