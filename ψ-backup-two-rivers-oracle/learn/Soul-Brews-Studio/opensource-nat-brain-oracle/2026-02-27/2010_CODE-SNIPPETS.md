# Code Snippets: opensource-nat-brain-oracle

**Project**: Soul-Brews-Studio/opensource-nat-brain-oracle
**Date**: 2026-02-27
**Focus**: Core Oracle memory system, configuration patterns, and CLI implementations

---

## Table of Contents

1. [Main Entry Points](#main-entry-points)
2. [Database Schema & FTS5 Patterns](#database-schema--fts5-patterns)
3. [CLI Command Structure](#cli-command-structure)
4. [Core Implementations](#core-implementations)
5. [Vector Search Integration](#vector-search-integration)
6. [Error Handling & Configuration](#error-handling--configuration)
7. [Interesting Patterns & Idioms](#interesting-patterns--idioms)

---

## Main Entry Points

### 1. Database Initialization (`init_db.py`)

**File**: `/Users/nat/Code/github.com/Soul-Brews-Studio/opensource-nat-brain-oracle/courses/build-your-oracle/starter-kit/init_db.py`

```python
#!/usr/bin/env python3
"""
Build Your Oracle - Database Initialization
Run this first to set up your Oracle database.
"""

import sqlite3
from pathlib import Path

DB_PATH = "oracle.db"
SCHEMA_PATH = Path(__file__).parent / "schema.sql"

def init_db():
    """Initialize the Oracle database with schema."""
    print("Initializing Oracle database...")

    # Read schema
    with open(SCHEMA_PATH) as f:
        schema = f.read()

    # Create database
    conn = sqlite3.connect(DB_PATH)
    conn.executescript(schema)
    conn.commit()
    conn.close()

    print(f"Database created: {DB_PATH}")
    print("Ready to use: python oracle.py search 'test'")

if __name__ == "__main__":
    init_db()
```

**Why It Matters**: This is the bootstrap entry point. It reads a SQL schema file and initializes a SQLite database. The pattern of reading schema from file + executing as script is clean and maintainable.

**Dependencies**: Requires `schema.sql` file in same directory with full DDL.

---

### 2. Basic Oracle CLI (`oracle.py`) - Main Entry Point

**File**: `/Users/nat/Code/github.com/Soul-Brews-Studio/opensource-nat-brain-oracle/courses/build-your-oracle/starter-kit/oracle.py`

```python
#!/usr/bin/env python3
"""
Build Your Oracle - CLI Tool
Day 1-2: Memory + Context-Finder
"""

import click
import sqlite3
import os
from pathlib import Path
from datetime import datetime

DB_PATH = "oracle.db"

def get_db():
    """Get database connection."""
    return sqlite3.connect(DB_PATH)

def init_db():
    """Initialize database with schema."""
    schema_path = Path(__file__).parent / "schema.sql"
    with open(schema_path) as f:
        schema = f.read()

    conn = get_db()
    conn.executescript(schema)
    conn.commit()
    conn.close()
    print("Database initialized.")

@click.group()
def cli():
    """Oracle - Your AI Knowledge System"""
    pass

@cli.command()
def init():
    """Initialize the Oracle database."""
    init_db()

@cli.command()
@click.argument('query')
def search(query):
    """Search your knowledge base."""
    conn = get_db()
    cursor = conn.execute("""
        SELECT o.id, o.content, o.source_file, o.created_at
        FROM observations_fts fts
        JOIN observations o ON fts.rowid = o.id
        WHERE observations_fts MATCH ?
        ORDER BY rank
        LIMIT 10
    """, [query])

    results = cursor.fetchall()

    if not results:
        print(f"No results for: {query}")
        return

    print(f"Found {len(results)} results:\n")
    for id, content, source, created in results:
        print(f"[{id}] {source or 'direct'} ({created[:10]})")
        # Show first 200 chars
        preview = content[:200] + "..." if len(content) > 200 else content
        print(f"    {preview}\n")

    conn.close()
```

**Why It Matters**: This is the Day 1-2 CLI implementation. Uses Click for command groups, demonstrates FTS5 search pattern with JOIN to original table (critical for preserving metadata while searching).

**Key Pattern**: `observations_fts` is a virtual table for search, but actual data lives in `observations`. Query joins them back to get all fields.

---

## Database Schema & FTS5 Patterns

### 3. Database Schema with Full-Text Search

**File**: `/Users/nat/Code/github.com/Soul-Brews-Studio/opensource-nat-brain-oracle/courses/build-your-oracle/starter-kit/schema.sql`

```sql
-- Build Your Oracle - Database Schema
-- Day 1: Basic storage + FTS5

-- Main observations table
CREATE TABLE IF NOT EXISTS observations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    content TEXT NOT NULL,
    type TEXT DEFAULT 'observation',  -- 'learning', 'retro', 'log', 'observation'
    source_file TEXT,
    concepts TEXT,  -- JSON array of concepts (Day 3)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Full-text search index
CREATE VIRTUAL TABLE IF NOT EXISTS observations_fts
USING fts5(
    content,
    source_file,
    content=observations,
    content_rowid=id
);

-- Triggers to keep FTS in sync
CREATE TRIGGER IF NOT EXISTS observations_ai AFTER INSERT ON observations BEGIN
    INSERT INTO observations_fts(rowid, content, source_file)
    VALUES (new.id, new.content, new.source_file);
END;

CREATE TRIGGER IF NOT EXISTS observations_ad AFTER DELETE ON observations BEGIN
    INSERT INTO observations_fts(observations_fts, rowid, content, source_file)
    VALUES('delete', old.id, old.content, old.source_file);
END;

CREATE TRIGGER IF NOT EXISTS observations_au AFTER UPDATE ON observations BEGIN
    INSERT INTO observations_fts(observations_fts, rowid, content, source_file)
    VALUES('delete', old.id, old.content, old.source_file);
    INSERT INTO observations_fts(rowid, content, source_file)
    VALUES (new.id, new.content, new.source_file);
END;

-- Day 3: Concepts table for pattern recognition
CREATE TABLE IF NOT EXISTS concepts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    observation_id INTEGER NOT NULL,
    concept TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (observation_id) REFERENCES observations(id)
);

-- Index for concept lookups
CREATE INDEX IF NOT EXISTS idx_concepts_concept ON concepts(concept);
CREATE INDEX IF NOT EXISTS idx_concepts_observation ON concepts(observation_id);

-- Useful views
CREATE VIEW IF NOT EXISTS learnings AS
    SELECT * FROM observations WHERE type = 'learning';

CREATE VIEW IF NOT EXISTS retrospectives AS
    SELECT * FROM observations WHERE type = 'retro';
```

**Why It Matters**:
- Shows the dual-table pattern: `observations` (real data) + `observations_fts` (virtual FTS5 table)
- Triggers keep FTS5 synchronized automatically
- `content=observations` and `content_rowid=id` tell FTS5 to shadow the main table
- Type categorization builds the "Nothing is Deleted" philosophy into the schema
- Concepts table enables pattern discovery by co-occurrence

**Critical Pattern**: FTS5 virtual tables with triggers create the illusion of a single queryable table while preserving all metadata in the real table.

---

## CLI Command Structure

### 4. Search Command with FTS5 Ranking

**File**: `/Users/nat/Code/github.com/Soul-Brews-Studio/opensource-nat-brain-oracle/courses/build-your-oracle/starter-kit/oracle.py`

```python
@cli.command()
@click.argument('query')
def search(query):
    """Search your knowledge base."""
    conn = get_db()
    cursor = conn.execute("""
        SELECT o.id, o.content, o.source_file, o.created_at
        FROM observations_fts fts
        JOIN observations o ON fts.rowid = o.id
        WHERE observations_fts MATCH ?
        ORDER BY rank
        LIMIT 10
    """, [query])

    results = cursor.fetchall()

    if not results:
        print(f"No results for: {query}")
        return

    print(f"Found {len(results)} results:\n")
    for id, content, source, created in results:
        print(f"[{id}] {source or 'direct'} ({created[:10]})")
        # Show first 200 chars
        preview = content[:200] + "..." if len(content) > 200 else content
        print(f"    {preview}\n")

    conn.close()
```

**Why It Matters**:
- FTS5 `MATCH` operator for full-text search
- `ORDER BY rank` uses FTS5's built-in ranking algorithm
- `LIMIT 10` prevents output explosion
- Joins back to main table to show metadata
- Graceful handling of empty results

---

### 5. Index Command - Batch Markdown Processing

**File**: `/Users/nat/Code/github.com/Soul-Brews-Studio/opensource-nat-brain-oracle/courses/build-your-oracle/starter-kit/oracle.py`

```python
@cli.command()
@click.argument('path')
def index(path):
    """Index markdown files from a directory."""
    path = Path(path)

    if not path.exists():
        print(f"Path not found: {path}")
        return

    conn = get_db()
    count = 0

    for md_file in path.rglob("*.md"):
        content = md_file.read_text()

        # Check if already indexed
        existing = conn.execute(
            "SELECT id FROM observations WHERE source_file = ?",
            [str(md_file)]
        ).fetchone()

        if existing:
            # Update
            conn.execute("""
                UPDATE observations
                SET content = ?, updated_at = CURRENT_TIMESTAMP
                WHERE source_file = ?
            """, [content, str(md_file)])
        else:
            # Insert
            conn.execute("""
                INSERT INTO observations (content, source_file, type)
                VALUES (?, ?, 'indexed')
            """, [content, str(md_file)])

        count += 1

    conn.commit()
    conn.close()
    print(f"Indexed {count} files from {path}")
```

**Why It Matters**:
- Idempotent operation: checks if file already exists before inserting
- `rglob("*.md")` recursively finds all markdown files
- Updates existing records while inserting new ones (no duplicates)
- Batch commit at end is efficient
- Sets `type='indexed'` to distinguish between manual vs. file-sourced observations

---

### 6. Add Command - Manual Observation Entry

**File**: `/Users/nat/Code/github.com/Soul-Brews-Studio/opensource-nat-brain-oracle/courses/build-your-oracle/starter-kit/oracle.py`

```python
@cli.command()
@click.argument('content')
@click.option('--type', '-t', default='observation', help='Type: learning, retro, log')
def add(content, type):
    """Add a new observation."""
    conn = get_db()
    conn.execute("""
        INSERT INTO observations (content, type)
        VALUES (?, ?)
    """, [content, type])
    conn.commit()
    conn.close()
    print(f"Added {type}: {content[:50]}...")
```

**Why It Matters**:
- Simple INSERT pattern for direct user input
- `--type` option with sensible default creates flexible categorization
- Shows how Click options map to function parameters

---

### 7. Stats Command - Metadata Query

**File**: `/Users/nat/Code/github.com/Soul-Brews-Studio/opensource-nat-brain-oracle/courses/build-your-oracle/starter-kit/oracle.py`

```python
@cli.command()
def stats():
    """Show database statistics."""
    conn = get_db()

    total = conn.execute("SELECT COUNT(*) FROM observations").fetchone()[0]
    by_type = conn.execute("""
        SELECT type, COUNT(*) FROM observations GROUP BY type
    """).fetchall()

    print(f"Total observations: {total}\n")
    print("By type:")
    for type, count in by_type:
        print(f"  {type}: {count}")

    conn.close()
```

**Why It Matters**: Simple aggregation pattern to surface database health. Good diagnostic tool.

---

## Core Implementations

### 8. Smart Search with Context-Finder Pattern (Day 2)

**File**: `/Users/nat/Code/github.com/Soul-Brews-Studio/opensource-nat-brain-oracle/courses/build-your-oracle/starter-kit/oracle.py`

```python
# Day 2: Context-finder pattern (placeholder)
@cli.command()
@click.argument('query')
def smart_search(query):
    """Search with context-finder pattern (Day 2)."""
    print("Context-finder search:")
    print("1. FTS5 finds candidates...")

    # Phase 1: FTS5
    conn = get_db()
    candidates = conn.execute("""
        SELECT o.id, o.content, o.source_file
        FROM observations_fts fts
        JOIN observations o ON fts.rowid = o.id
        WHERE observations_fts MATCH ?
        LIMIT 50
    """, [query]).fetchall()

    print(f"   Found {len(candidates)} candidates")

    # Phase 2: Would use Haiku here
    print("2. Haiku would summarize candidates...")
    print("   (Implement with your API key)")

    # Phase 3: Would use Opus here
    print("3. Opus would analyze top results...")
    print("   (Implement with your API key)")

    # For now, just show candidates
    print(f"\nCandidate files:")
    for id, content, source in candidates[:10]:
        print(f"  - {source or f'observation {id}'}")

    conn.close()
```

**Why It Matters**: Documents the 3-phase search pattern that solves the "Oracle dies from success" problem:
1. **Phase 1 (FTS5)**: Free, finds 50 candidates
2. **Phase 2 (Haiku)**: Cheap summarization of candidates
3. **Phase 3 (Opus)**: Focused analysis of top 10

Cost: $0.23 instead of $1.50 for 1,000 files.

---

## Vector Search Integration

### 9. Hybrid Search Implementation (`oracle_smart.py`)

**File**: `/Users/nat/Code/github.com/Soul-Brews-Studio/opensource-nat-brain-oracle/courses/build-your-oracle/starter-kit/oracle_smart.py`

```python
#!/usr/bin/env python3
"""
Build Your Oracle - Day 3: Intelligence
Adds vector search, consult, reflect, learn, supersede commands.

Requires: pip install chromadb anthropic
"""

import click
import sqlite3
from pathlib import Path
from datetime import datetime

# Optional: Vector search with ChromaDB
try:
    import chromadb
    VECTORS_AVAILABLE = True
except ImportError:
    VECTORS_AVAILABLE = False
    print("ChromaDB not installed. Run: pip install chromadb")

# Optional: AI synthesis with Anthropic
try:
    import anthropic
    AI_AVAILABLE = True
except ImportError:
    AI_AVAILABLE = False

DB_PATH = "oracle.db"

def get_db():
    return sqlite3.connect(DB_PATH)

def get_collection():
    """Get or create ChromaDB collection."""
    if not VECTORS_AVAILABLE:
        return None
    client = chromadb.Client()
    return client.get_or_create_collection("oracle")

@click.group()
def cli():
    """Oracle Smart - AI Knowledge System with Intelligence"""
    pass

@cli.command()
@click.argument('query')
def search(query):
    """Hybrid search: keywords + vectors."""
    print(f"Hybrid search for: {query}\n")

    # Phase 1: FTS5 keyword search
    conn = get_db()
    keyword_results = conn.execute("""
        SELECT o.id, o.content, o.source_file
        FROM observations_fts fts
        JOIN observations o ON fts.rowid = o.id
        WHERE observations_fts MATCH ?
        LIMIT 20
    """, [query]).fetchall()
    print(f"Keyword matches: {len(keyword_results)}")

    # Phase 2: Vector search (if available)
    collection = get_collection()
    if collection and collection.count() > 0:
        vector_results = collection.query(
            query_texts=[query],
            n_results=10
        )
        print(f"Semantic matches: {len(vector_results['ids'][0])}")

    # Show results
    print("\nTop results:")
    for id, content, source in keyword_results[:5]:
        preview = content[:150] + "..." if len(content) > 150 else content
        print(f"  [{id}] {source or 'direct'}")
        print(f"      {preview}\n")

    conn.close()
```

**Why It Matters**:
- Combines keyword (FTS5) + semantic (vector) search
- Graceful degradation: works even without ChromaDB
- Shows the hybrid approach that catches both exact and conceptual matches

---

### 10. Consult Command - AI Advice Generation

**File**: `/Users/nat/Code/github.com/Soul-Brews-Studio/opensource-nat-brain-oracle/courses/build-your-oracle/starter-kit/oracle_smart.py`

```python
@cli.command()
@click.argument('question')
def consult(question):
    """Get advice based on your knowledge."""
    print(f"Consulting Oracle about: {question}\n")

    # Find relevant knowledge
    conn = get_db()
    results = conn.execute("""
        SELECT content FROM observations_fts
        WHERE observations_fts MATCH ?
        LIMIT 5
    """, [question]).fetchall()

    if not results:
        print("No relevant knowledge found.")
        return

    context = "\n---\n".join([r[0][:500] for r in results])

    if AI_AVAILABLE:
        # Use Claude to synthesize
        client = anthropic.Anthropic()
        response = client.messages.create(
            model="claude-3-haiku-20240307",
            max_tokens=500,
            messages=[{
                "role": "user",
                "content": f"""Based on this knowledge, advise on: {question}

Knowledge:
{context}

Provide concise, actionable advice."""
            }]
        )
        print("Oracle says:")
        print(response.content[0].text)
    else:
        print("Relevant knowledge found:")
        for r in results:
            print(f"  - {r[0][:200]}...")
        print("\n(Install anthropic for AI synthesis: pip install anthropic)")

    conn.close()
```

**Why It Matters**:
- Demonstrates AI synthesis pattern: search → context extraction → Claude analysis
- Graceful fallback when Anthropic library not available
- Uses Haiku (cheap) for real-time advice
- Shows the "external brain" pattern: human knowledge → AI synthesis → advice

---

### 11. Reflect Command - Random Wisdom Surfacing

**File**: `/Users/nat/Code/github.com/Soul-Brews-Studio/opensource-nat-brain-oracle/courses/build-your-oracle/starter-kit/oracle_smart.py`

```python
@cli.command()
def reflect():
    """Get random wisdom from your knowledge."""
    conn = get_db()
    result = conn.execute("""
        SELECT content, source_file, created_at
        FROM observations
        WHERE type = 'learning'
        ORDER BY RANDOM()
        LIMIT 1
    """).fetchone()

    if result:
        content, source, created = result
        print("Today's reflection:\n")
        print(f"  {content}")
        print(f"\n  — from {source or 'direct input'} ({created[:10]})")
    else:
        print("No learnings yet. Add some with: oracle_smart.py learn 'pattern'")

    conn.close()
```

**Why It Matters**:
- `ORDER BY RANDOM()` pattern for serendipitous discovery
- Surfaces learnings without requiring search
- Implements the "patterns over intentions" philosophy - what you learned by doing, not what you planned

---

### 12. Learn Command - Knowledge Capture with Vectors

**File**: `/Users/nat/Code/github.com/Soul-Brews-Studio/opensource-nat-brain-oracle/courses/build-your-oracle/starter-kit/oracle_smart.py`

```python
@cli.command()
@click.argument('pattern')
def learn(pattern):
    """Add a new learning to Oracle."""
    conn = get_db()

    # Store in SQLite
    conn.execute("""
        INSERT INTO observations (content, type)
        VALUES (?, 'learning')
    """, [pattern])
    conn.commit()

    # Index in vectors (if available)
    collection = get_collection()
    if collection:
        doc_id = f"learning_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        collection.add(
            documents=[pattern],
            ids=[doc_id]
        )
        print(f"Learned (with vectors): {pattern[:50]}...")
    else:
        print(f"Learned: {pattern[:50]}...")

    conn.close()
```

**Why It Matters**:
- Dual-index pattern: SQLite (structured) + ChromaDB (semantic)
- Timestamp in vector doc_id maintains temporal ordering
- Optional vector storage (works without it)
- Embodies "continuous learning" philosophy

---

### 13. Supersede Command - Evolution Without Deletion

**File**: `/Users/nat/Code/github.com/Soul-Brews-Studio/opensource-nat-brain-oracle/courses/build-your-oracle/starter-kit/oracle_smart.py`

```python
@cli.command()
@click.argument('old_id')
@click.argument('new_id')
@click.option('--reason', '-r', default='Updated understanding')
def supersede(old_id, new_id, reason):
    """Mark old knowledge as superseded by new.

    Philosophy: "Nothing is Deleted" - old stays, but marked outdated.
    """
    conn = get_db()

    # Check if superseded_by column exists
    try:
        conn.execute("""
            UPDATE observations
            SET superseded_by = ?, supersede_reason = ?
            WHERE id = ?
        """, [new_id, reason, old_id])
        conn.commit()
        print(f"Superseded: {old_id} -> {new_id}")
        print(f"Reason: {reason}")
    except sqlite3.OperationalError:
        print("Note: Run schema migration to add supersede columns")
        print("ALTER TABLE observations ADD COLUMN superseded_by TEXT;")
        print("ALTER TABLE observations ADD COLUMN supersede_reason TEXT;")

    conn.close()
```

**Why It Matters**:
- Implements "Nothing is Deleted" philosophy as a code pattern
- Links old to new while keeping both searchable
- Preserves evolution history
- Shows graceful handling of schema changes (column may not exist)

---

## Error Handling & Configuration

### 14. Graceful Optional Dependencies

**File**: `/Users/nat/Code/github.com/Soul-Brews-Studio/opensource-nat-brain-oracle/courses/build-your-oracle/starter-kit/oracle_smart.py`

```python
# Optional: Vector search with ChromaDB
try:
    import chromadb
    VECTORS_AVAILABLE = True
except ImportError:
    VECTORS_AVAILABLE = False
    print("ChromaDB not installed. Run: pip install chromadb")

# Optional: AI synthesis with Anthropic
try:
    import anthropic
    AI_AVAILABLE = True
except ImportError:
    AI_AVAILABLE = False
```

**Why It Matters**:
- Allows core functionality to work even without advanced features
- Fails gracefully with helpful messages
- Enables incremental adoption (Day 1 → Day 2 → Day 3)

---

### 15. Database Connection Pattern

**File**: `/Users/nat/Code/github.com/Soul-Brews-Studio/opensource-nat-brain-oracle/courses/build-your-oracle/starter-kit/oracle.py`

```python
DB_PATH = "oracle.db"

def get_db():
    """Get database connection."""
    return sqlite3.connect(DB_PATH)
```

**Why It Matters**:
- Single source of truth for database location
- Called fresh in each command (no persistent connections)
- Simplifies testing and reconfiguration
- Each command gets a clean connection

---

### 16. Schema Execution Pattern

**File**: `/Users/nat/Code/github.com/Soul-Brews-Studio/opensource-nat-brain-oracle/courses/build-your-oracle/starter-kit/oracle.py`

```python
def init_db():
    """Initialize database with schema."""
    schema_path = Path(__file__).parent / "schema.sql"
    with open(schema_path) as f:
        schema = f.read()

    conn = get_db()
    conn.executescript(schema)
    conn.commit()
    conn.close()
    print("Database initialized.")
```

**Why It Matters**:
- Reads schema from file (maintainable, version-controlled)
- `executescript()` handles multiple statements
- Uses `Path(__file__).parent` for relative paths (works from any directory)
- Explicit commit + close

---

## Interesting Patterns & Idioms

### 17. FTS5 Virtual Table Pattern (Critical)

**Pattern**: Shadow table with triggers for automatic synchronization

```sql
-- Real table with all data
CREATE TABLE observations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    content TEXT NOT NULL,
    type TEXT DEFAULT 'observation',
    source_file TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Virtual table for searching
CREATE VIRTUAL TABLE observations_fts
USING fts5(
    content,
    source_file,
    content=observations,  -- Link to real table
    content_rowid=id       -- Link rowid mapping
);

-- Automatic sync on insert
CREATE TRIGGER observations_ai AFTER INSERT ON observations BEGIN
    INSERT INTO observations_fts(rowid, content, source_file)
    VALUES (new.id, new.content, new.source_file);
END;
```

**Why This Works**:
- FTS5 is for search only, doesn't store all metadata
- Real table stores everything
- Triggers keep them synchronized automatically
- Queries can `JOIN` to get all data back
- This is the foundational pattern for the entire system

---

### 18. CLI Command Grouping with Click

**Pattern**: Using `@click.group()` for organized commands

```python
@click.group()
def cli():
    """Oracle - Your AI Knowledge System"""
    pass

@cli.command()
def init():
    """Initialize the Oracle database."""
    init_db()

@cli.command()
@click.argument('query')
def search(query):
    """Search your knowledge base."""
    # implementation

# Invocation: python oracle.py search "query"
```

**Why This Works**:
- All commands under one `cli()` group
- Each gets docstring that appears in help
- Click handles argument parsing + validation
- Scales to many commands naturally

---

### 19. Hybrid Search Pattern (FTS5 + Vectors)

**Pattern**: Try both keyword and semantic search

```python
# Phase 1: Fast keyword search
keyword_results = conn.execute("""
    SELECT o.id, o.content, o.source_file
    FROM observations_fts fts
    JOIN observations o ON fts.rowid = o.id
    WHERE observations_fts MATCH ?
    LIMIT 20
""", [query]).fetchall()

# Phase 2: Semantic search (if available)
collection = get_collection()
if collection and collection.count() > 0:
    vector_results = collection.query(
        query_texts=[query],
        n_results=10
    )
```

**Why This Works**:
- FTS5 catches exact phrase matches (very fast)
- Vectors catch conceptual matches ("git safety" finds "force push danger")
- Combined result set is richer than either alone
- Optional vectors don't break core functionality

---

### 20. Type-Based Organization

**Pattern**: Use `type` field to categorize observations

```sql
-- Schema
content TEXT NOT NULL,
type TEXT DEFAULT 'observation',  -- 'learning', 'retro', 'log'

-- Specific queries
SELECT * FROM observations WHERE type = 'learning';
SELECT * FROM observations WHERE type = 'retro';
```

**Why This Works**:
- Single table stores all knowledge types
- Queries filter by type when needed
- Views provide convenient shortcuts
- Enables "Nothing is Deleted" - all types stay, nothing purged
- Supports discovery queries (e.g., "find patterns that appeared in retrospectives")

---

### 21. Markdown File Indexing Pattern

**Pattern**: Batch import + update idempotency

```python
for md_file in path.rglob("*.md"):
    content = md_file.read_text()

    # Check if already indexed
    existing = conn.execute(
        "SELECT id FROM observations WHERE source_file = ?",
        [str(md_file)]
    ).fetchone()

    if existing:
        # Update
        conn.execute("""
            UPDATE observations
            SET content = ?, updated_at = CURRENT_TIMESTAMP
            WHERE source_file = ?
        """, [content, str(md_file)])
    else:
        # Insert
        conn.execute("""
            INSERT INTO observations (content, source_file, type)
            VALUES (?, ?, 'indexed')
        """, [content, str(md_file)])

conn.commit()
```

**Why This Works**:
- Can run multiple times without duplication
- Updates preserve creation time but update timestamp
- `rglob()` finds nested markdown
- Batch commit at end is efficient
- `source_file` field enables file-to-observation tracing

---

### 22. Configuration Philosophy Pattern

**From CLAUDE.md**: Git-based configuration with safety as first-class concern

```python
# Pattern: All configuration in tracked files
# CLAUDE.md, CLAUDE_safety.md, CLAUDE_workflows.md
# Configuration as documentation
# Documentation as configuration
```

**Key Patterns Observed**:
1. **Configuration as Documentation**: Rules live in markdown, enforced by automation
2. **Safety First**: Multiple explicit checks before destructive operations
3. **Nothing is Deleted**: Append-only logs, marked-as-superseded instead of deleted
4. **Subagent Delegation**: Cheap models for data gathering, expensive for decisions

---

### 23. Hook System Architecture

**From settings.json**: Lifecycle hooks for monitoring and enforcement

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {"type": "command", "command": "say -v 'Kanya' -r 280 'สวัสดีค่ะ' &"},
          {"type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR\"/.claude/scripts/agent-identity.sh"}
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {"type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/safety-check.sh"}
        ]
      }
    ]
  }
}
```

**Why This Works**:
- Configuration in JSON, easily parseable
- Environment variables for dynamic paths
- Matcher system for selective hook application
- Enables automation of safety checks, token counting, logging

---

### 24. Markdown-Based Knowledge Structure

**Pattern**: Knowledge organized in ψ/ (Psi) directory with clear pillar system

```
ψ/
├── active/         # Research in progress (ephemeral)
├── inbox/          # Communication & focus (tracked)
├── writing/        # Articles & projects (tracked)
├── lab/            # Experiments & POCs (tracked)
├── incubate/       # Cloned repos for development (gitignored)
├── learn/          # Cloned repos for study (gitignored)
└── memory/         # Knowledge base (mixed tracking)
    ├── resonance/      # WHO I am (soul)
    ├── learnings/      # PATTERNS I found
    ├── retrospectives/ # SESSIONS I had
    └── logs/           # MOMENTS captured
```

**Why This Works**:
- Clear separation of signal (tracked) vs. noise (ephemeral)
- Five pillars provide organizational structure
- Two incubation zones for development work
- Knowledge flow: active → logs → retrospectives → learnings → resonance

---

### 25. Slugify Pattern for Filename Generation

**File**: `/Users/nat/Code/github.com/Soul-Brews-Studio/opensource-nat-brain-oracle/scripts/organize_prompts.py`

```python
def slugify(text):
    """Convert title to URL-safe slug"""
    slug = text.lower().strip()
    slug = re.sub(r'[^a-z0-9\s\-]', '', slug)  # Remove special chars
    slug = re.sub(r'\s+', '-', slug)             # Space to dash
    slug = re.sub(r'-+', '-', slug).strip('-')   # Collapse dashes
    return slug

# Usage: "Force Push Danger!" → "force-push-danger"
```

**Why This Works**:
- Deterministic transformation (same input = same output)
- Creates filesystem-safe filenames
- Readable in URLs and file listings
- Used for organizing visual prompts into numbered files

---

### 26. Prompt Extraction from Markdown

**File**: `/Users/nat/Code/github.com/Soul-Brews-Studio/opensource-nat-brain-oracle/scripts/organize_prompts.py`

```python
def extract_consolidated(file_path, start_num, end_num):
    """Extract prompts from consolidated markdown file"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    prompts = {}

    for num in range(start_num, end_num + 1):
        # Try multiple header patterns
        patterns = [
            rf'^##\s+Prompt\s+{num}:\s+([^#\n]+)',  # ## Prompt NNN: Title
            rf'^##\s+{num}:\s+["\']?([^#"\'\n]+)["\']?',  # ## NNN: "Title"
        ]

        match = None
        for pattern in patterns:
            match = re.search(pattern, content, re.MULTILINE)
            if match:
                break

        if not match:
            continue

        title = match.group(1).strip().rstrip(':').strip()

        # Get full section content (from match to next ## or end)
        start_pos = match.start()
        next_section = re.search(r'^##\s', content[match.end():], re.MULTILINE)

        if next_section:
            end_pos = match.end() + next_section.start()
        else:
            end_pos = len(content)

        section_content = content[start_pos:end_pos].strip()

        slug = slugify(title)

        prompts[num] = {
            'title': title,
            'slug': slug,
            'full_content': section_content
        }

    return prompts
```

**Why This Works**:
- Multiple regex patterns handle different markdown formats
- Finds section boundaries by looking for next `##`
- Preserves all content (headers + body)
- Returns dict keyed by prompt number for easy lookup
- Fault-tolerant: continues if pattern doesn't match

---

## Philosophy & Principles Embedded in Code

### 27. "Nothing is Deleted" Implementation

This philosophy is implemented through:

1. **Append-only database**: Uses `created_at` and `updated_at` timestamps
2. **Supersede instead of delete**: Old knowledge marked as `superseded_by` instead of deleted
3. **Type-based filtering**: All types stay in database, queries filter what to show
4. **Git tracking**: All markdown changes tracked in version control
5. **Temporal queries**: `ORDER BY created_at` preserves history

---

### 28. "Patterns Over Intentions" Implementation

This philosophy surfaces through:

1. **Type tracking**: What you actually recorded (not what you planned)
2. **Frequency analysis**: What appears most often is what matters
3. **Random reflection**: `ORDER BY RANDOM()` surfaces what you've learned, not what you think you know
4. **Concepts table**: Discovers co-occurring patterns through database queries

---

### 29. "External Brain, Not Command" Pattern

The system implements this through:

1. **Consult not execute**: Oracle advises, human decides
2. **Mirrors knowledge**: Database is a mirror of your thinking, not a replacement
3. **Reversible learning**: `supersede` links old to new, shows evolution
4. **Search not recall**: You search your memory, Oracle doesn't tell you what to do

---

## Summary

The opensource-nat-brain-oracle is built on these core patterns:

| Component | Pattern | Purpose |
|-----------|---------|---------|
| Schema | FTS5 + Triggers | Searchable knowledge storage |
| CLI | Click command groups | User-friendly interface |
| Search | Hybrid FTS5+Vector | Keyword + semantic matching |
| Intelligence | Haiku+Opus | Cheap summarization + focused analysis |
| Philosophy | Type + Timestamp | Nothing deleted, patterns over intentions |
| Configuration | JSON hooks + Shell scripts | Safety automation |
| Organization | ψ/ Psi structure | Signal vs. noise separation |

The system solves the "Oracle dies from success" problem through context-finder (3-phase search), enabling indefinite knowledge growth without exponential cost increases.

