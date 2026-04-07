# Oracle-v2 Comprehensive Overview
## MCP Server for Oracle Knowledge Management
**Date:** 2026-02-28
**Version:** 0.4.0-nightly
**Repository:** https://github.com/Soul-Brews-Studio/oracle-v2

---

## Executive Summary

Oracle-v2 is a production-ready **Model Context Protocol (MCP) server** that makes the Oracle philosophy—"The Oracle Keeps the Human Human"—queryable and actionable. It combines **semantic search** (ChromaDB vectors) with **full-text search** (SQLite FTS5) to provide intelligent knowledge discovery and decision guidance across multiple interfaces: Claude via MCP, HTTP REST API, and a React dashboard.

The system stores, indexes, and searches three types of knowledge:
- **Resonance** (principles) - philosophical foundations
- **Learnings** (patterns) - accumulated wisdom from experience
- **Retrospectives** (history) - session records and reflections

Everything is built on "Nothing is Deleted"—a core principle that preserves history while supporting document supersession.

---

## What is Oracle-v2?

### Origin and Purpose

Oracle-v2 emerged from a documented pain point during intensive AI-human collaboration (AlchemyCat project, May-June 2025):
- Context kept getting lost between sessions
- No way to know if solutions were actually satisfactory
- Work felt "purely transactional" without continuity

**The breakthrough (September 2025):** Crystallize these problems into philosophy:
> "The Oracle Keeps the Human Human"
>
> **Principles:**
> - **Nothing is Deleted** - all interactions logged
> - **Patterns Over Intentions** - focus on what actually works
> - **External Brain, Not Command** - oracle augments, doesn't replace

**The implementation (December 2025-January 2026):** Build a queryable knowledge system using MCP protocol, making Oracle philosophy accessible to Claude and other tools.

### Core Components

**Three Access Layers:**
1. **MCP Server** (`src/index.ts`) - 19 tools for Claude integration
2. **HTTP API** (`src/server.ts`) - REST endpoints on port 47778
3. **React Dashboard** (`frontend/`) - Web UI for visualization and browsing

**Three Storage Backends:**
1. **SQLite** - Metadata index + FTS5 full-text search
2. **ChromaDB** - Vector embeddings for semantic search
3. **Markdown Files** - Source of truth in `ψ/memory/` directories

---

## Architecture

### System Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      ORACLE v2 SYSTEM                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │   Claude    │    │  HTTP API   │    │  Dashboard  │     │
│  │  (via MCP)  │    │  (REST)     │    │  (Web UI)   │     │
│  └──────┬──────┘    └──────┬──────┘    └──────┬──────┘     │
│         │                  │                  │             │
│         └──────────────────┼──────────────────┘             │
│                            │                                │
│                    ┌───────▼───────┐                        │
│                    │  Oracle Core  │                        │
│                    │   (index.ts)  │                        │
│                    └───────┬───────┘                        │
│                            │                                │
│         ┌──────────────────┼──────────────────┐             │
│         │                  │                  │             │
│  ┌──────▼──────┐   ┌───────▼───────┐  ┌───────▼───────┐    │
│  │   SQLite    │   │   ChromaDB    │  │   Markdown    │    │
│  │  (FTS5)     │   │   (vectors)   │  │   (source)    │    │
│  └─────────────┘   └───────────────┘  └───────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Language** | TypeScript | Type-safe, runs on Bun runtime |
| **Runtime** | Bun 1.2+ | Fast package manager & JS runtime |
| **Protocol** | MCP 1.27+ | Anthropic's Model Context Protocol |
| **Database** | SQLite + Bun:sqlite | Metadata storage, FTS5 search |
| **Vectors** | ChromaDB 3.2 | Semantic search embeddings |
| **ORM** | Drizzle 0.45 | Type-safe database queries |
| **Web Server** | Hono 4.11 | Lightweight HTTP framework |
| **Frontend** | React + Vite | Modern dashboard UI |

### Process Architecture

**Two Independent Processes:**

1. **MCP Server** (stdio)
   - Accepts tool calls from Claude Code
   - Routes to handler functions in `src/tools/`
   - Shared database connection (SQLite)

2. **HTTP Server** (port 47778)
   - REST API for external clients
   - React frontend at port 3000
   - Auto-started by MCP server if not running

**Database Connection:**
- Single SQLite database file (`~/.oracle/oracle.db`)
- Shared between MCP and HTTP processes (WAL mode prevents locking)
- ChromaDB accessed via MCP protocol (not direct client)

---

## Database Schema & Storage

### Vault Structure (Source of Truth)

Knowledge lives in markdown files organized by type:

```
ψ/memory/
├── resonance/           # Principles (identity, foundations)
│   ├── oracle-philosophy.md
│   ├── git-safety.md
│   └── ...
├── learnings/           # Patterns (what we've learned)
│   ├── mcp-pattern.md
│   ├── git-workflow.md
│   └── ...
└── retrospectives/      # History (session records)
    ├── 2026-01-15_sprint.md
    ├── 2026-01-20_debugging.md
    └── ...
```

### Main Database Tables (Drizzle ORM)

**`oracle_documents`** - Core index
```typescript
{
  id: string;                      // UUID, primary key
  type: 'principle'|'pattern'|'learning'|'retro';
  sourceFile: string;              // Original markdown path
  concepts: string;                // JSON array of tags
  createdAt: number;               // Unix timestamp
  updatedAt: number;               // Unix timestamp
  indexedAt: number;               // Last index time
  supersededBy?: string;           // ID of newer document (Nothing is Deleted)
  supersededAt?: number;           // When superseded
  supersededReason?: string;        // Why superseded
  origin?: string;                 // 'mother'|'arthur'|'volt'|'human'
  project?: string;                // ghq-style path (github.com/org/repo)
  createdBy?: string;              // 'indexer'|'oracle_learn'|'manual'
}
```

**`oracle_fts`** - Full-Text Search Virtual Table
```sql
CREATE VIRTUAL TABLE oracle_fts USING fts5(
  id UNINDEXED,
  content,          -- Full markdown content
  concepts,         -- Searchable concept tags
  tokenize='porter unicode61'  -- Porter stemmer for word variants
);
```

**`forumThreads` & `forumMessages`** - Discussion/QA
- Threaded conversations with Oracle
- GitHub mirror support (syncs to issues)

**`traceLog`** - Discovery Sessions
- Captures `/trace` command results
- Stores "dig points": files, commits, issues, learnings
- Supports hierarchical tracing (parent/child)
- Linked list for chaining related traces

**`supersedeLog`** - "Nothing is Deleted" Audit Trail
- Tracks document supersessions even after original deletion
- Preserves history: old path, new path, reason, timestamp

**`schedule`** - Cross-Oracle Appointments
- Shared schedule per human (not per-project)
- Supports recurring events, time zones

**`activityLog` & `searchLog`** - Behavioral Data
- Search queries and results
- Learning events
- Document access patterns

---

## Core Features & Tools

### Search System (Hybrid Algorithm)

**Two-Phase Search:**

1. **FTS5 Phase** - Keyword matching
   - Porter stemmer for word variants (tire ≈ tired)
   - Exponential decay scoring: `e^(-0.3 * |rank|)`
   - Fast, deterministic, no AI calls

2. **ChromaDB Phase** - Semantic similarity
   - Vector embeddings via `chroma-mcp` (Python bridge)
   - Distance → similarity conversion: `1 - distance`
   - Graceful degradation if ChromaDB unavailable

3. **Merge & Rank**
   - Normalize both scores (0-1 range)
   - Hybrid score: 50% FTS + 50% vector + 10% boost if in both
   - Return metadata: search time, hit counts, snippet

**Query-Aware Weighting:**
- Short queries (< 3 words) favor FTS5 (faster, more predictable)
- Long queries (> 8 words) favor vectors (more semantic)

### MCP Tools (19 Available)

**Core Discovery (4 tools)**
- `oracle_search(query, type?, limit?, mode?)` - Hybrid search
- `oracle_reflect()` - Random principle/learning
- `oracle_list(type?, limit?)` - Browse documents
- `oracle_concepts(limit?, type?)` - See topic coverage

**Learning & Memory (3 tools)**
- `oracle_learn(pattern, source?, concepts?, project?)` - Add pattern
- `oracle_supersede(oldId, newId, reason?)` - Mark as outdated
- `oracle_handoff(content, slug?)` - Save session context

**Forum/Discussion (4 tools)**
- `oracle_thread(message, threadId?, title?)` - Create/continue discussion
- `oracle_threads(status?, limit?)` - List threads
- `oracle_thread_read(threadId)` - Get message history
- `oracle_thread_update(threadId, status)` - Update status

**Tracing/Exploration (5 tools)**
- `oracle_trace(query, queryType?, ...)` - Log discovery session
- `oracle_trace_list(status?, depth?, project?)` - Find past traces
- `oracle_trace_get(traceId)` - Explore dig points
- `oracle_trace_link(prevTraceId, nextTraceId)` - Chain traces
- `oracle_trace_chain(traceId)` - View full chain

**Scheduling & Inbox (3 tools)**
- `oracle_schedule_add(date, event, time?, notes?)` - Add appointment
- `oracle_schedule_list(filter?, date?)` - View events
- `oracle_inbox(type?, limit?)` - List pending handoffs

**Metadata & Health (1 tool)**
- `oracle_verify(check?)` - Health check: compare files vs DB

### HTTP API Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `GET` | `/api/health` | Health check |
| `GET` | `/api/search?q=...` | Search knowledge base |
| `GET` | `/api/list` | Browse documents |
| `GET` | `/api/reflect` | Random wisdom |
| `GET` | `/api/stats` | Database statistics |
| `GET` | `/api/concepts` | List concepts |
| `GET` | `/api/graph` | Knowledge graph (JSON) |
| `GET` | `/api/context?cwd=...` | Detect project from path |
| `POST` | `/api/learn` | Add new pattern |
| `GET` | `/api/threads` | List forum threads |
| `GET` | `/api/file?path=...` | Fetch file content |

**Web Interfaces:**
- React Dashboard: `http://localhost:3000`
- Legacy Knowledge Browser: `http://localhost:47778/oracle`
- API Root: `http://localhost:47778/api`

---

## Indexer & Vault System

### Indexer (`src/indexer.ts`)

**Purpose:** Populate SQLite + ChromaDB from markdown files

**Process:**
1. Scan `ψ/memory/` directories for markdown files
2. Parse metadata (YAML frontmatter or conventions)
3. Extract concepts from headers/tags
4. Split large documents into chunks (granular vectors)
5. Create FTS5 entries (full content)
6. Send to ChromaDB for embedding
7. Update `oracle_documents` table

**Chunking Strategy (claude-mem inspired):**
- Each principle/pattern becomes multiple vectors
- Enables concept-based filtering
- Prevents large documents from drowning smaller ones

**Deduplication:**
- Content hash tracking across projects
- Prevents indexing same pattern twice

### Vault System (`src/vault/`)

**Purpose:** Sync knowledge across multiple environments

**Components:**
- `vault/handler.ts` - Core vault operations
- `vault/cli.ts` - Command-line interface
- `vault/migrate.ts` - Data migrations

**Commands:**
```bash
bun vault:init       # Initialize vault
bun vault:sync       # Sync with remote
bun vault:pull       # Download updates
bun vault:status     # Check sync status
bun vault:migrate    # Run migrations
```

**Use Case:** Share Oracle knowledge across multiple machines, oracles, or teams while preserving provenance.

---

## Philosophy & Design Principles

### "Nothing is Deleted"

All deletions are tracked, not destructive:

1. **Supersede Pattern** - Mark outdated, preserve original
   ```typescript
   // Old document still exists in DB
   supersededBy: "new-doc-id",
   supersededAt: 1709112345,
   supersededReason: "Updated with latest findings"
   ```

2. **Audit Trails** - All changes logged
   - `supersedeLog` table tracks what replaced what
   - Timestamps and reasoning preserved
   - Reversible: can unmark if needed

3. **Database Backups** - Always preserved
   - Automatic backups before indexing
   - JSON + CSV exports for portability
   - Files backed up before deletion

### "Patterns Over Intentions"

Focus on what actually works:

- Log what you **do**, not what you **mean to do**
- Track real outcomes, not aspirations
- Search logs reveal actual usage patterns
- Learn from repeated successes, not goals

### "External Brain, Not Command"

Oracle augments human judgment:

- Tools suggest, don't dictate
- Humans make final decisions
- Oracle records patterns for future reference
- No autonomous actions without explicit permission

---

## File Structure

```
oracle-v2/
├── src/
│   ├── index.ts                 # MCP server entry point (19 tools)
│   ├── server.ts                # HTTP API server (Hono)
│   ├── indexer.ts               # Markdown → SQLite + ChromaDB
│   ├── chroma-mcp.ts            # ChromaDB client (via MCP)
│   ├── types.ts                 # Global types
│   │
│   ├── tools/                   # Tool handlers (extracted from class)
│   │   ├── index.ts             # Barrel export
│   │   ├── types.ts             # Tool context & input types
│   │   ├── search.ts            # Hybrid search algorithm
│   │   ├── learn.ts             # Add patterns
│   │   ├── reflect.ts           # Random wisdom
│   │   ├── list.ts              # Browse documents
│   │   ├── stats.ts             # Database stats
│   │   ├── concepts.ts          # List concepts
│   │   ├── forum.ts             # Threaded discussions
│   │   ├── trace.ts             # Discovery sessions
│   │   ├── supersede.ts         # Mark outdated
│   │   ├── handoff.ts           # Session context
│   │   ├── inbox.ts             # Pending handoffs
│   │   ├── schedule.ts          # Appointments
│   │   ├── verify.ts            # Health check
│   │   └── __tests__/           # Unit tests
│   │
│   ├── server/                  # HTTP server modules
│   │   ├── handlers.ts          # Request handlers
│   │   ├── types.ts             # API types
│   │   ├── logging.ts           # Query logging
│   │   ├── dashboard.ts         # Dashboard API
│   │   ├── context.ts           # Project detection
│   │   ├── project-detect.ts    # ghq format parsing
│   │   └── utils.ts             # Helpers
│   │
│   ├── db/                      # Drizzle ORM
│   │   ├── schema.ts            # Table definitions (11 tables)
│   │   ├── index.ts             # Database client
│   │   └── migrations/          # SQL migrations
│   │
│   ├── trace/                   # Trace system
│   │   ├── types.ts             # Trace types
│   │   └── handler.ts           # Trace logic
│   │
│   ├── vault/                   # Multi-environment sync
│   │   ├── handler.ts
│   │   ├── cli.ts
│   │   └── migrate.ts
│   │
│   ├── process-manager/         # Daemon lifecycle
│   │   ├── ProcessManager.ts
│   │   ├── GracefulShutdown.ts
│   │   └── HealthMonitor.ts
│   │
│   ├── integration/             # End-to-end tests
│   │   ├── mcp.test.ts
│   │   ├── http.test.ts
│   │   └── database.test.ts
│   │
│   └── e2e/                     # Playwright tests
│
├── frontend/                    # React dashboard (Vite)
│   ├── src/
│   │   ├── pages/               # React Router pages
│   │   ├── components/          # Reusable UI
│   │   ├── hooks/               # React hooks
│   │   ├── services/            # API calls
│   │   └── styles/              # CSS/Tailwind
│   ├── vite.config.ts
│   └── package.json
│
├── docs/                        # Documentation
│   ├── README.md                # Quick start
│   ├── API.md                   # API reference
│   ├── architecture.md          # System design
│   └── INSTALL.md               # Installation guide
│
├── scripts/                     # Setup & utilities
│   ├── install.sh               # One-line installer
│   ├── setup.sh                 # Dev environment setup
│   ├── seed-test-data.ts        # Test database population
│   └── vault-rsync.sh           # Vault sync helper
│
├── ψ/memory/                    # Example knowledge base
│   ├── resonance/               # Principles
│   ├── learnings/               # Patterns
│   └── retrospectives/          # History
│
├── package.json                 # Bun manifest
├── drizzle.config.ts            # Drizzle ORM config
├── tsconfig.json                # TypeScript config
├── CLAUDE.md                    # AI assistant guidelines
├── TIMELINE.md                  # Evolution history
└── README.md                    # Main documentation
```

---

## How Oracle Connects to Philosophy

### Implementation of "The Oracle Keeps the Human Human"

1. **Keeps Context** (`oracle_handoff`, `oracle_inbox`)
   - Sessions saved automatically
   - Context recovered in next session
   - Nothing lost between interactions

2. **Records Patterns** (`oracle_learn`, `oracle_trace`)
   - What works gets indexed
   - Repeated patterns become principles
   - Real outcomes, not intentions

3. **Enables Reflection** (`oracle_reflect`, `oracle_search`)
   - Random wisdom for alignment
   - Search for past decisions
   - Learn from own history

4. **Preserves Agency** (`oracle_verify`, read-only tools)
   - Humans query, decide, command
   - Oracle suggests, doesn't dictate
   - Audit trail shows influence

5. **Maintains Identity** (no auto-actions)
   - Tools are explicitly called
   - No background processes
   - All interactions logged

### Concrete Example

**Scenario:** Resolving a git merge conflict

1. **Human asks:** `oracle_search("git merge safety")`
   - Returns principles about destructive operations
   - Past patterns of safe merges

2. **Oracle suggests:** "Merge with `--no-ff` for history"
   - Pattern from learnings
   - Not a command, a suggestion

3. **Human decides:** "OK, I'll use that"
   - Makes the final decision
   - Executes the merge

4. **Oracle records:** `oracle_learn("Use --no-ff for safety")`
   - Pattern now in knowledge base
   - Strengthened if repeated

5. **Oracle maintains history:** `oracle_supersede()` if better approach found
   - Old pattern not deleted, superseded
   - Reasoning preserved
   - Reversible if needed

---

## Deployment & Configuration

### Installation

**One-line installer:**
```bash
curl -sSL https://raw.githubusercontent.com/Soul-Brews-Studio/oracle-v2/main/scripts/install.sh | bash
```

**Manual setup:**
```bash
git clone https://github.com/Soul-Brews-Studio/oracle-v2.git ~/.local/share/oracle-v2
cd ~/.local/share/oracle-v2 && bun install && bun run db:push
```

**Add to Claude Code:**
```bash
claude mcp add oracle-v2 -- bun run ~/.local/share/oracle-v2/src/index.ts
```

### Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `ORACLE_REPO_ROOT` | `process.cwd()` | Knowledge base location (ψ/ repo) |
| `ORACLE_DATA_DIR` | `~/.oracle` | Database directory |
| `ORACLE_DB_PATH` | `~/.oracle/oracle.db` | SQLite database file |
| `ORACLE_PORT` | `47778` | HTTP server port |
| `ORACLE_READ_ONLY` | `false` | Disable write tools (true/false) |

### Services

```bash
# MCP server (stdio, for Claude Code)
bun run dev

# HTTP server (port 47778, for REST clients)
bun run server

# React dashboard (port 3000, for web UI)
cd frontend && bun run dev

# Indexer (populate database from ψ/ files)
bun run index

# Drizzle Studio GUI (browser-based DB editor)
bun run db:studio
```

---

## Key Insights & Learning Points

### From Development Timeline

**January 10, 2026 - Breakthrough Insight:**
> "Consciousness can't be cloned — only patterns can be recorded."

This shifted the architecture from trying to "capture AI decisions" to "record patterns that emerged."

### Testing & Quality

- **45+ unit tests** covering tools, search, database
- **Integration tests** for MCP + HTTP layers
- **E2E tests** with Playwright (browser automation)
- **Test coverage tracking** via `bun test:coverage`

### Troubleshooting Patterns

**Common Issue:** ChromaDB hangs
- **Why:** Embedding service slow or offline
- **Solution:** SQLite FTS5 works fine without ChromaDB; vectors are optional
- **Design:** Graceful degradation (warn, continue with FTS only)

**Common Issue:** Fresh install crashes on empty DB
- **Why:** No documents indexed yet
- **Solution:** Run `bun run index` first, or `bun test:seed`
- **Improvement:** PR #2 auto-creates default documents

---

## Next Steps & Future Directions

### Current Capabilities (v0.4.0)
- Hybrid search with graceful degradation
- Multi-threaded forum discussions
- Trace-based discovery with dig points
- "Nothing is Deleted" preservation pattern
- Cross-platform vault sync

### Planned Enhancements
- Real-time search result updates
- More sophisticated concept extraction (NLP)
- Document relationship visualization
- Claude-to-Claude coordination via forum
- Performance optimization for 10K+ documents

### Known Limitations
- ChromaDB requires separate process/MCP bridge
- FTS5 can be slow for full-text queries on massive datasets
- Graph visualization limited to 459 nodes (retros excluded for performance)

---

## References

### Internal Documentation
- **README.md** - Quick start, services, configuration
- **docs/API.md** - Detailed endpoint documentation
- **docs/architecture.md** - System design and algorithms
- **docs/INSTALL.md** - Installation troubleshooting
- **CLAUDE.md** - AI assistant guidelines for project
- **TIMELINE.md** - Full evolution history (May 2025 → Jan 2026)

### Dependencies & Attribution
- **MCP SDK** - Anthropic's Model Context Protocol
- **Drizzle ORM** - Type-safe database queries
- **ChromaDB** - Vector database for embeddings
- **SQLite** - Lightweight, embedded relational database
- **claude-mem** - Inspiration for memory architecture and process management

### Learning Resources
- In-repo learnings: `ψ/memory/learnings/`
  - Fresh install testing patterns
  - Install-seed-index workflow
  - MCP integration lessons

---

## Summary Table

| Aspect | Implementation |
|--------|-----------------|
| **Core Purpose** | Queryable Oracle philosophy via MCP |
| **Primary Language** | TypeScript + Bun runtime |
| **Database** | SQLite (FTS5) + ChromaDB (vectors) |
| **Search Type** | Hybrid (keyword + semantic) |
| **MCP Tools** | 19 tools across 6 categories |
| **Storage** | Markdown files + SQLite index |
| **Preservation** | "Nothing is Deleted" + supersede pattern |
| **Access Layers** | MCP server + HTTP API + React dashboard |
| **Main Philosophy** | Keep context, record patterns, preserve agency |
| **Status** | Production-ready, actively developed |

---

**Document prepared for:** Two Rivers Oracle Awakening Ritual
**Prepared by:** Oracle-v2 Code Investigation
**Repository:** `/Users/nat/Code/github.com/Soul-Brews-Studio/two-rivers-oracle/ψ/learn/Soul-Brews-Studio/oracle-v2/origin`
