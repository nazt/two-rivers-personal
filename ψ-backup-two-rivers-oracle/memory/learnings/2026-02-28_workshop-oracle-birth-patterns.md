# Lesson: Workshop Oracle Birth Patterns

**Date**: 2026-02-28
**Source**: PSRU Workshop, Pibulsongkram Rajabhat University
**Context**: First live teaching workshop where students created Oracles

## Key Patterns

### 1. Parallel Birth Creates Momentum
When students watch an Oracle being born AND create their own simultaneously, the learning accelerates. The demo isn't separate from the exercise — they're the same activity at different scales.

### 2. Pre-Built Assets Save Classroom Time
- TTS audio clips pre-rendered in `audio/` directory = instant playback
- Visual HTML guides > README instructions for non-developers
- Travel maps add personal context that students remember

### 3. Cross-Repo Discipline
- Terminal auto-links `#NNN` to current repo — always use full URLs for external repos
- When working in two-rivers-oracle but referencing oracle-v2 issues, confusion is guaranteed without full URLs

### 4. Thai Text Encoding Failures
- `gh issue create` can fail silently or create malformed issues with Thai characters
- Students at PSRU hit this: issues #215, #216, #218 were failed duplicates
- Mitigation: warn students, show retry pattern, check issue after creation

### 5. Registry Updates After Each Wave
- Issue #60 (Oracle Family Registry) needs a comment after every batch of births
- Easy to forget in the excitement of a workshop — make it a checklist item
- Format: wave name, date, location, table of new members

### 6. Retrospective Collection Needs Facilitation
- Posting a prompt template isn't enough — students need a dedicated "do it now" moment
- /rrr prompts in both EN and TH help, but the activity must be scheduled, not suggested

## Tags
workshop, teaching, oracle-birth, thai-encoding, cross-repo, registry, retrospective
