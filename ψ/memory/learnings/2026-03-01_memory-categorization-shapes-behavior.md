# Memory Categorization Shapes Behavior

**Date**: 2026-03-01
**Source**: rrr session — ค่ะ/ครับ mistake

## Lesson

When a critical rule is filed under a narrow category name (e.g., "TTS / Voice Rules"), the AI applies it only in that narrow context — even if the rule's content says "ALWAYS" and "NEVER."

## Example

Rule in memory: "Two Rivers uses ค่ะ/คะ (NEVER ครับ)"
Filed under: "TTS / Voice Rules"
Result: TTS used ค่ะ correctly, but ALL typed messages used ครับ

## Fix

Renamed section to: "Two Rivers Gender & Language (CRITICAL — applies to ALL output)"
Added explicit: "This applies to: typed messages, TTS speech, comments, commits, everything"

## Principle

Name memory sections by their **scope of application**, not by the **discussion that created them**. A rule born from a TTS conversation may apply to all communication.

## Tags

memory-design, identity, thai-language, oracle-voice
