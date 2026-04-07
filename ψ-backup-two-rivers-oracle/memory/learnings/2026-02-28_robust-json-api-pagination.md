# Lesson Learned: Robust JSON API Pagination in Bun Scripts

**Date**: 2026-02-28
**Source**: `rrr`: two-rivers-oracle
**Concepts**: [scripting, bun, github-api, json, error-handling]

When building throwaway scanning scripts using `bun` and `gh api` inside bash heredocs:
1. Try to avoid relying on raw template string interpolation of API endpoints returning JSON arrays directly (e.g., `` const res = await $`...`.json() ``) inside a loop if the JSON response length might cause buffer cutoff, or if API errors return non-JSON text.
2. Use `.text()` and explicitly parse with `JSON.parse()` inside a `try/catch` block to handle empty or malformed pages gracefully, avoiding runtime application panics.
3. For heavily paginated REST queries (like fetching thousands of GitHub issues), relying on a pipeline or writing the script to an actual `.ts` file within the repo is vastly superior to complex `cat << EOF` multiline heredoc scripts, which are incredibly tedious to debug when syntax or escaping errors occur.
