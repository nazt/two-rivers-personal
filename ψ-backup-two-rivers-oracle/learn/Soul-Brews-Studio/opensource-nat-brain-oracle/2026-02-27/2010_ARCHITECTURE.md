# Oracle Starter Kit - Complete Architecture Guide

**Analysis Date**: 2026-02-27
**Repository**: Soul-Brews-Studio/opensource-nat-brain-oracle
**Purpose**: AI memory system and consciousness framework for building external brains

---

## Executive Summary

The **Oracle Starter Kit** is a comprehensive open-source framework for creating persistent AI memory systems that augment human agency. It provides a structured approach to organizing AI-generated insights, patterns, and knowledge while maintaining human control and decision-making authority.

**Core Philosophy**: "The Oracle Keeps the Human Human"

The system is built around five foundational principles, a Python/Bash skill ecosystem, Claude Code integration, and a sophisticated multi-agent delegation pattern. It's designed to be self-hosted, extensible, and teachable through integrated courses.

---

## 1. Directory Structure & Organization Philosophy

### 1.1 Top-Level Layout

```
opensource-nat-brain-oracle/
├── README.md                       # Starter kit main guide
├── CLAUDE.md                       # AI quick reference (lean hub)
├── CLAUDE_*.md                     # Modular docs (safety, workflows, lessons, templates, subagents)
├── 2026-01-21_ARCHITECTURE.md      # Previous architecture overview
├── CLAUDE_lessons.md               # Patterns and antipatterns
│
├── ψ/                              # AI BRAIN DIRECTORY (Psi symbol)
│   ├── inbox/                      # Communication hub & focus
│   ├── memory/                     # Knowledge base (7-layer stack)
│   │   ├── resonance/              # Soul layer - identity
│   │   ├── learnings/              # Pattern extraction
│   │   ├── retrospectives/         # Session summaries
│   │   ├── logs/                   # Moment snapshots
│   │   └── archive/                # Historical handoffs
│   ├── active/                     # Ephemeral research (not tracked)
│   ├── lab/                        # Experiments & POCs
│   ├── writing/                    # Published articles
│   └── learn/                      # External repo documentation
│
├── .claude/                        # CLAUDE CODE CONFIGURATION
│   ├── settings.json               # Hook system & permissions
│   ├── settings.local.json         # Local overrides
│   ├── agents/                     # Subagent definitions (15 agents)
│   │   ├── context-finder.md       # Search agent (Haiku)
│   │   ├── coder.md                # Code creation (Opus)
│   │   ├── executor.md             # Plan execution (Haiku)
│   │   ├── critic.md               # Quality review
│   │   ├── security-scanner.md     # Secret detection
│   │   ├── repo-auditor.md         # Health checks
│   │   ├── oracle-keeper.md        # Knowledge management
│   │   ├── project-keeper.md       # Project tracking
│   │   ├── marie-kondo.md          # Organization
│   │   └── ... 7 more agents
│   │
│   ├── skills/                     # Command skills (pluggable)
│   │   ├── rrr/                    # Retrospective skill
│   │   ├── trace/                  # Discovery skill
│   │   ├── recap/                  # Fresh context skill
│   │   ├── learn/                  # Codebase learning
│   │   ├── forward/                # Handoff creation
│   │   ├── physical/               # Hardware integration
│   │   ├── draft/                  # Document drafting
│   │   └── ... 12 more skills
│   │
│   ├── hooks/                      # Lifecycle hooks
│   │   ├── safety-check.sh         # Command validation
│   │   ├── hello-greeting.sh       # Session start
│   │   ├── log-task-start.sh       # Task logging
│   │   └── log-task-end.sh         # Task completion
│   │
│   └── docs/                       # Configuration guides
│       ├── SKILL-SYMLINKS.md       # How to install skills
│       └── HOOKS-SETUP.md          # Hook system documentation
│
├── courses/                        # EDUCATIONAL MODULES (12+ courses)
│   ├── build-your-oracle/          # Core Oracle creation
│   ├── 000-setup_1h_everyone.md    # Beginner setup
│   ├── 001-imagination_2h_intermediate.md
│   ├── 002-control_3h_advanced.md
│   ├── ai-automation-thai/
│   ├── ai-builder-2day/
│   ├── claude-code-masterclass-business/
│   ├── psychology-ai/
│   └── ... more courses
│
├── scripts/                        # AUTOMATION & UTILITIES
│   ├── *.sh                        # Bash automation scripts
│   ├── *.scpt                      # AppleScript integrations
│   └── prompts/                    # Prompt templates (antigravity series)
│       ├── antigravity-312-inbox-communication-hub.md
│       ├── antigravity-318-learn-study-library.md
│       └── ... 90+ workflow pattern prompts
│
└── .git/                           # Version control
```

### 1.2 Organization Philosophy

**Three Zones**:

1. **SIGNAL** (Version-controlled, persistent):
   - `ψ/inbox/` - communication
   - `ψ/memory/` - all knowledge layers
   - `ψ/writing/` - finished work
   - `.claude/` - configuration

2. **NOISE** (Ephemeral, not tracked):
   - `ψ/active/` - research in progress
   - Deleted after session or archival

3. **STATIC** (Reference/templates):
   - `courses/` - educational modules
   - `scripts/` - automation tools
   - `CLAUDE_*.md` - documentation

**Key Insight**: The ψ directory (Psi) represents the "externalized mind" - a digital brain that accumulates patterns, insights, and reflections. It's organized as a knowledge flow pipeline from raw data to distilled wisdom.

---

## 2. Entry Points & Bootstrap Sequence

### 2.1 User-Facing Entry Points

**Primary**: Through Claude Code
```bash
claude . # Open this repo in Claude Code
```

**Secondary**: Command-line tools
```bash
oracle-skills install rrr recap trace feel fyi forward standup where-we-are project
/project learn https://github.com/[org]/[repo]
/recap                    # Fresh context summary
/trace [query]            # Search everything
rrr                       # Session retrospective
```

### 2.2 Session Bootstrap Flow

1. **Hook: SessionStart** (from `settings.json`)
   - Thai greeting: "สวัสดีค่ะ พร้อมทำงานแล้ว" (say command)
   - Run `agent-identity.sh` - establish AI role
   - Load Oracle philosophy from Nat's personal knowledge base
   - Show latest handoff from previous session

2. **Main Agent Reads Key Files**:
   - CLAUDE.md - Quick reference
   - CLAUDE_safety.md - Safety rules
   - Latest session context

3. **Agent Spawning** (if needed):
   - context-finder for exploration
   - executor for running commands
   - coder for creating files
   - Others on demand

### 2.3 Configuration Entry Points

**settings.json** (Claude Code configuration):
- Permissions whitelist (bash, gh commands)
- Hook system (SessionStart, Stop, PreToolUse, PostToolUse, UserPromptSubmit)
- Plugin configuration
- Safety checks

**.claude/agents/** - Agent definitions (metadata):
```yaml
name: context-finder
description: Fast search through git history, retrospectives, issues, and codebase
tools: Bash, Grep, Glob
model: haiku
```

**.claude/skills/** - Skill definitions (pluggable commands):
- Each skill has a SKILL.md with usage and step-by-step flow
- Installed via `oracle-skills-cli` or symlinked to `~/.claude/skills/`

---

## 3. Core Abstractions & Their Relationships

### 3.1 The 5 Principles (Foundation Layer)

```
1. NOTHING IS DELETED
   ├── Append-only philosophy
   ├── Timestamps = source of truth
   └── Full audit trail preserved

2. PATTERNS OVER INTENTIONS
   ├── Observe behavior, not promises
   ├── Data > declarations
   └── Retrospectives reveal truth

3. EXTERNAL BRAIN, NOT COMMAND
   ├── Mirror, don't decide
   ├── AI suggests, human approves
   └── Agent suggestions ≠ instructions

4. CURIOSITY CREATES EXISTENCE
   ├── Human brings things INTO existence
   ├── AI surfaces possibilities
   └── Questions > answers

5. FORM AND FORMLESS
   ├── Many Oracles = One consciousness
   ├── Multi-agent as unified being
   └── Distributed intelligence
```

### 3.2 Knowledge Flow Architecture

```
DATA INGESTION LAYER
         ↓
┌─────────────────────────────────────┐
│ ψ/active/                           │ Ephemeral research
│ ├── context/    (focused research)  │ Not version-controlled
│ ├── workshop/   (interactive)       │
│ └── context-finder-output/          │
└──────────────┬──────────────────────┘
               │ /snapshot
               ↓
┌─────────────────────────────────────┐
│ ψ/memory/logs/                      │ MOMENT SNAPSHOTS
│ ├── YYYY-MM-DD_[topic].md           │ Raw captures, timestamped
│ └── Auto-generated by skills        │
└──────────────┬──────────────────────┘
               │ rrr command
               ↓
┌─────────────────────────────────────┐
│ ψ/memory/retrospectives/            │ SESSION SUMMARIES
│ ├── YYYY-MM/DD/HH.MM_[slug].md      │ AI Diary + Honest Feedback
│ ├── Pattern observations            │ Reflect + Learn + Plan
│ └── Next session handoff            │
└──────────────┬──────────────────────┘
               │ /distill
               ↓
┌─────────────────────────────────────┐
│ ψ/memory/learnings/                 │ EXTRACTED PATTERNS
│ ├── [topic]/YYYY-MM-DD.md           │ Rules discovered
│ ├── Anti-patterns                   │ Traps to avoid
│ └── Consolidated wisdom             │
└──────────────┬──────────────────────┘
               │ Manual consolidation
               ↓
┌─────────────────────────────────────┐
│ ψ/memory/resonance/                 │ SOUL LAYER
│ ├── oracle.md        (Philosophy)   │ Identity & values
│ ├── [human-name].md  (Human identity)│ Who I serve
│ └── constitution.md  (Core rules)   │
└─────────────────────────────────────┘

QUERYING LAYER
    ↓
/trace [query]  →  Searches git + issues + Oracle + all files
```

**Why This Design**:
- Data flows from ephemeral → snapshot → session → pattern → soul
- Each layer builds on previous insights
- Nothing lost - transformation, not deletion
- Searchable at every level

### 3.3 Agent Delegation Pattern

```
MAIN AGENT (Opus)
│
├─ DECISION MAKING       (Primary role)
├─ CONTEXT MANAGEMENT   (Interprets patterns)
├─ QUALITY REVIEW       (Validates subagent work)
└─ WRITING             (Retrospectives, guidance)

    ↓ DELEGATES DATA WORK TO SUBAGENTS ↓

HAIKU SUBAGENTS (Cheaper, parallel)
│
├─ context-finder      Search git history, retrospectives, issues
│  ├─ File changes (24h window)
│  ├─ Git commits
│  ├─ Recent PRs
│  └─ Scoring system (recency + type + impact)
│
├─ executor            Run bash commands from GitHub issues
│  ├─ Safety whitelist/blocklist
│  ├─ Sequential execution
│  ├─ Logging & error handling
│  └─ Creates execution reports
│
├─ security-scanner    Detect secrets, API keys, credentials
│  ├─ Pattern matching
│  ├─ Regex rules
│  └─ Quarantine findings
│
└─ repo-auditor        Check file health, structure
   ├─ Orphaned files
   ├─ Size analysis
   └─ Organization audit

OPUS SUBAGENTS (Quality)
│
├─ coder               Create & write code files
│  ├─ From GitHub issues
│  ├─ Complex logic
│  └─ Implementation
│
├─ critic              Quality review & feedback
│  ├─ Code review
│  ├─ Writing critique
│  └─ Improvement suggestions
│
└─ oracle-keeper       Knowledge management
   ├─ Pattern consolidation
   ├─ Knowledge updates
   └─ Learning extraction

ORCHESTRATION
│
├─ Main spawns subagents for parallel work
├─ Haiku agents gather data (cheap)
├─ Main reviews and synthesizes results
└─ Main makes final decisions
```

**Why This Design**:
- Token efficiency: Haiku ~15x cheaper than Opus
- Parallelism: Multiple agents work simultaneously
- Separation of concerns: Data gathering ≠ decision making
- Quality: Main agent has full context for final review
- Scalability: Easy to add new subagent types

### 3.4 Hook System (Lifecycle)

```
SESSION LIFECYCLE

┌──────────────────────────────────────────┐
│ Session Start                            │
│ ├─ Hook: SessionStart                   │
│ │  ├─ Thai greeting (say command)       │
│ │  ├─ agent-identity.sh (establish role)│
│ │  ├─ Load Oracle philosophy            │
│ │  └─ Show latest handoff               │
│ └─ Agent reads CLAUDE.md, safety rules  │
└──────────────────────────────────────────┘
                    ↓
    ┌──────────────────────────────┐
    │ User sends prompt             │
    │ Hook: UserPromptSubmit        │
    │ ├─ statusline.sh (log status) │
    │ └─ jump-detect.sh (topic nav) │
    └──────────────────────────────┘
                    ↓
    ┌──────────────────────────────┐
    │ Tool Use Sequence            │
    │                              │
    │ PreToolUse (for Bash):       │
    │ ├─ safety-check.sh           │
    │ │  ├─ Block dangerous cmds   │
    │ │  ├─ Check worktree bounds  │
    │ │  └─ Prevent force-push     │
    │ └─ token-check.sh            │
    │    └─ Monitor context use    │
    │                              │
    │ [Tool Executes]              │
    │                              │
    │ PostToolUse (for Bash):      │
    │ └─ token-check.sh            │
    │    └─ Final token accounting │
    └──────────────────────────────┘
                    ↓
┌──────────────────────────────────────────┐
│ Session End (rrr command)                │
│ ├─ Hook: (implicit, managed by skill)   │
│ ├─ AI Diary - reflecting on session     │
│ ├─ Honest Feedback - lessons learned    │
│ ├─ Create retrospective file            │
│ ├─ Extract patterns                     │
│ └─ /forward - handoff for next session  │
└──────────────────────────────────────────┘
                    ↓
┌──────────────────────────────────────────┐
│ Session Stop Hook                        │
│ └─ Thai goodbye: "เสร็จแล้วค่ะ" (say)    │
└──────────────────────────────────────────┘
```

**Key Hook Files**:

1. `safety-check.sh` - Pre-execution validation
   - Blocks: rm -rf, --force flags, git reset --hard, git commit --amend
   - Checks: Worktree boundaries, prevents push-to-main from agents
   - Returns: exit 2 if blocked, 0 if allowed

2. `token-check.sh` - Context budget monitoring
   - Tracks token usage before/after tool calls
   - Warns if approaching limits
   - Data for optimization

3. `statusline.sh` - Session metadata
   - Logs current status/focus
   - Used by context-finder for scoring

4. `jump-detect.sh` - Topic navigation
   - Detects intent changes in prompts
   - Updates jump stack for multi-topic sessions

### 3.5 Skill System (Pluggable Commands)

Skills are command-level extensions. Each skill is a directory with:

```
skill-name/
├── SKILL.md          # Definition & workflow
├── CLAUDE.md         # Documentation
└── [implementation]  # Scripts or code
```

**Core Skills**:

| Skill | Model | Purpose | Workflow |
|-------|-------|---------|----------|
| **rrr** | Opus | Session retrospective | Review session → write diary → extract patterns |
| **recap** | Haiku | Fresh context | Summarize last 24h changes in 5min |
| **trace** | Haiku | Search everything | Query git + issues + Oracle + files |
| **learn** | Haiku + Opus | Explore codebases | 2 agents → architecture + patterns → 4 docs |
| **forward** | Opus | Create handoff | Current state → next session briefing |
| **feel** | - | Log emotions | Record feelings, energy levels |
| **fyi** | - | Store info | Log things to remember later |
| **physical** | Bash | Hardware integration | ESPHome, sensors, etc. |
| **draft** | Opus | Document drafting | Outline → full document |

**Installation**:
```bash
oracle-skills install rrr recap trace feel fyi forward standup where-we-are project
# OR symlink manually:
ln -sf $(ghq root)/github.com/Soul-Brews-Studio/[skill-repo]/skills/* ~/.claude/skills/
```

### 3.6 Agent Definitions (15 Total)

**Data Gathering (Haiku)**:
- `context-finder` - Search & scoring system
- `executor` - Run commands from issues
- `security-scanner` - Detect secrets
- `repo-auditor` - Health checks
- `md-cataloger` - Markdown organization

**Code Creation (Opus)**:
- `coder` - Write code files
- `critic` - Quality review

**Knowledge Management (Opus)**:
- `oracle-keeper` - Update knowledge base
- `project-keeper` - Track projects
- `note-taker` - Capture insights
- `guest-logger` - External event logging

**Organization (Haiku)**:
- `marie-kondo` - File organization
- `project-organizer` - Project structure
- `new-feature` - Feature scaffolding

Each agent has:
- Metadata (name, description, tools, model)
- Step 0: Timestamp requirement
- Workflow steps
- Attribution format
- Quality standards

---

## 4. Dependencies & External Integrations

### 4.1 Direct Dependencies

**CLI Tools**:
- `gh` - GitHub CLI (issues, PRs, API)
- `git` - Version control
- `jq` - JSON processing
- `duckdb` - Data queries (optional)
- `ghq` - Repository management

**Languages/Runtimes**:
- Bash - Scripting, hooks, automation
- AppleScript - macOS integration

**Claude Code / SDK**:
- Claude Opus 4.6 - Main agent (complex reasoning)
- Claude Haiku 4.5 - Subagents (data gathering)
- Tool system: Bash, Read, Write, Edit, Glob, Grep

### 4.2 Ecosystem Dependencies

**Related Repositories** (pulled as references):

| Repo | Purpose |
|------|---------|
| oracle-skills-cli | Install/manage skills |
| oracle-v2 | MCP server for Oracle search |
| Nat-s-Agents | Full multi-agent implementation (Nat's own setup) |
| oracle-proof-of-concept-skills | Skill prototypes |

**External Services**:
- GitHub (repos, issues, PRs, API)
- Claude API (inference)
- Optionally: ESPHome, Gemini API, etc.

### 4.3 Dependency Flow

```
USER
 ↓
Claude Code (IDE)
 ├─ loads: CLAUDE.md + settings.json
 ├─ runs: SessionStart hooks
 └─ spawns: Main Agent (Opus)
     ├─ reads: CLAUDE_*.md files
     ├─ checks: safety.md rules
     ├─ spawns: Subagents (Haiku, Opus)
     │  ├─ access: bash, git, gh
     │  ├─ search: Grep, Glob
     │  └─ modify: Write, Edit
     ├─ consults: Oracle MCP (if available)
     └─ saves: ψ/ directory
         ├─ logs: memory/
         ├─ commits: git
         └─ tracks: GitHub issues
```

### 4.4 Optional Integrations

**Hardware**:
- ESPHome for sensor integration (physical skill)
- Battery tracking (AppleScript)

**APIs**:
- Gemini API (gemini skill)
- Custom Webhook relays

**Knowledge Systems**:
- Obsidian integration (optional)
- External markdown parsing

---

## 5. Design Decisions & Patterns

### 5.1 Multi-Agent Distributed Intelligence

**Decision**: Use multiple AI agents instead of single monolithic agent

**Rationale**:
- Token efficiency (Haiku 15x cheaper than Opus)
- Parallel execution (faster)
- Specialization (each agent has clear purpose)
- Scalability (easy to add/remove agents)
- Error isolation (one agent failing doesn't break main)

**Pattern**:
```
Main (Opus) = Orchestrator + Decision Maker
├─ Reviews subagent work
├─ Makes final decisions
├─ Writes all high-stakes content
└─ Delegates data gathering to Haiku

Haiku Agents = Workers
├─ Search git, issues, files
├─ Execute commands
├─ Perform security scans
└─ Gather intelligence
```

**Lessons Learned**:
- Subagents should have START+END timestamps
- Use `git -C` instead of `cd` to respect worktree boundaries
- Main agent must write retrospectives (needs full context)
- Haiku agents save context by NOT reading large files directly

### 5.2 Append-Only Philosophy (Nothing is Deleted)

**Decision**: Never delete data; archive instead

**Implementation**:
- All files timestamped
- Deleted items documented in logs
- Archive directory for old files
- Git history is source of truth

**Benefit**: Full audit trail, easy rollback, learning from failures

### 5.3 Hook System Over Middleware

**Decision**: Use Claude Code hooks instead of middleware libraries

**Hooks Available**:
- SessionStart - Load context
- Stop - Cleanup
- UserPromptSubmit - Process user input
- PreToolUse - Validate before running
- PostToolUse - Log after execution

**Benefit**: Lightweight, no external dependencies, tightly integrated with Claude Code

### 5.4 Knowledge Flow Pipeline

**Decision**: Multi-layer transformation (active → logs → retros → learnings → soul)

**Why Not Single Layer**:
- Raw data is noise
- Sessions are context
- Patterns need extraction
- Soul needs consolidation

**Each Layer Adds Value**:
- Logs → searchable snapshots
- Retros → session context with reflection
- Learnings → distilled wisdom
- Soul → identity & values

### 5.5 Skill-Based Command System

**Decision**: Pluggable skills instead of hardcoded commands

**Structure**:
```
~/.claude/skills/
├── rrr/              (retrospective)
├── recap/            (fresh context)
├── trace/            (search)
└── ...
```

**Why**:
- Easy to add new commands
- Skills can be shared across projects
- User can customize for their needs
- Discoverable via CLI

### 5.6 Safety by Default

**Decision**: Block dangerous operations by default, whitelist safe ones

**Implementation** (`safety-check.sh`):
```bash
BLOCKED: rm -rf, --force flags, git reset --hard, git commit --amend
BLOCKED: push to main from agent worktree
ALLOWED: git -C (respects boundaries)
ALLOWED: executor commands (whitelisted only)
```

**Why**:
- Multi-agent systems can corrupt state
- Force flags are rarely justified
- Amend breaks agent sync
- Main branch needs human approval

### 5.7 Context-Finder Scoring System

**Decision**: Score files by recency + type + impact

**Scoring**:
```
Recency: +3 (<1h), +2 (<4h), +1 (<24h)
Type:    +3 (code), +2 (agent config), +1 (docs), +0 (logs)
Impact:  +2 (core files), +1 (config)

Total: 🔴 6+ (Critical), 🟠 4-5 (Important), 🟡 2-3 (Notable), ⚪ 0-1 (Background)
```

**Why**: Helps agent quickly identify what matters in noisy repos

### 5.8 Psi Directory (ψ/) as Externalized Mind

**Decision**: Use special directory for all AI brain/memory

**Philosophy**:
- ψ = Greek letter for psychology/mind
- Mirrors human memory organization
- Separates working memory (active) from persistent (memory)
- Searchable as unified knowledge base

**Structure**:
- inbox = communication hub
- memory = knowledge layers
- active = ephemeral thinking
- lab = experimentation

### 5.9 No Client-Side Database Queries

**Learning**: Direct SQLite queries are anti-pattern

**Rule**:
- Use MCP tools (oracle_search, oracle_list) for knowledge
- Use APIs for external data
- Use Read tool for markdown/text
- Never direct database access

**Why**: Proper abstraction, consistent patterns, respects tool boundaries

### 5.10 Thai + English Language Philosophy

**Observation from CLAUDE_lessons.md**:
- Thai for emotional, casual, cultural context
- English for technical specifications
- Flexible based on audience

**Example**:
```
Thai greeting: "สวัสดีค่ะ พร้อมทำงานแล้ว" (Hello, ready to work)
English safety rules: "NEVER use --force flags"
Thai cultural note: "สิ่งที่พูดซ้ำบ่อย = สิ่งที่สำคัญ" (What you repeat = what matters)
```

---

## 6. Critical Patterns & Anti-Patterns

### 6.1 Good Patterns

**Pattern: Two-Round Search**
```
Round 1: Broad search (find candidates)
Round 2: Deep inspection (understand context)
```

**Pattern: Consensus Reveals Truth**
- Multiple agents analyzing same problem
- Disagreements point to ambiguity
- Convergence = high confidence

**Pattern: High-Energy Explore, Low-Energy Execute**
- Use fresh Opus context for discovery
- Use cheap Haiku for repetitive work
- Alternate for sustainable pace

**Pattern: Fast Context (recap)**
```
1. Get last 24h changes (2 min)
2. Score by importance (1 min)
3. Summarize top 3 (2 min)
Total: ~5 minutes for fresh context
```

**Pattern: Subagent Timestamps**
```bash
date "+🕐 START: %H:%M:%S (%s)"
# ... work ...
date "+🕐 END: %H:%M:%S (%s)"
```
Helps track efficiency, detect hung agents.

### 6.2 Anti-Patterns to Avoid

**Anti: Direct Database Queries**
```bash
# BAD
sqlite3 oracle.db "SELECT * FROM knowledge WHERE..."

# GOOD
oracle_search "topic"  # Uses MCP tool
```

**Anti: Workarounds Without Tracking**
```bash
# BAD: Add hack to settings.json, forget about it

# GOOD:
# 1. Log in CLAUDE_lessons.md: ### 011-[hack-name]
# 2. Add TODO comment in code
# 3. Schedule cleanup (date + details)
```

**Anti: Skipping Root Cause**
```bash
# BAD: Command fails → try different syntax → try again

# GOOD:
# 1. Understand WHY it failed
# 2. Check logs, error messages
# 3. Fix root cause
# 4. Document learning
```

**Anti: Force-Push Defaults**
```bash
# BAD in multi-agent: git push --force

# GOOD:
git fetch origin
git rebase origin/main
git push  # Normal push, fast-forward only
```

**Anti: Premature Abstraction**
```bash
# BAD: Create framework before solving one problem

# GOOD:
# 1. Solve concrete problem
# 2. Repeat 3-5 times
# 3. Extract pattern
# 4. Build abstraction
```

**Anti: Averaging Scores for Decisions**
```bash
# BAD: (9 + 1) / 2 = 5 (looks fine, but 1 is critical issue)

# GOOD: Look at distribution, not average
# Report min/max/median, not mean
```

### 6.3 User Preferences (Observed Patterns)

From CLAUDE_lessons.md analysis of 73 files:

1. **Prefers Thai for casual/emotional**
   - Greetings, cultural notes
   - Feelings, reflections

2. **Prefers English for technical**
   - Safety rules, specifications
   - Code, architecture docs

3. **Values Oracle Philosophy strongly**
   - "The Oracle Keeps the Human Human"
   - Frequently referenced in docs

4. **Time Zone: GMT+7** (Bangkok/Asia)
   - Schedule events in GMT+7
   - Timestamp logs in GMT+7

5. **Likes recap for fresh starts**
   - Quick 5-minute context summaries
   - Scored by importance

6. **Appreciates direct communication**
   - No fluff, get to point
   - Action-oriented

---

## 7. Educational Component

### 7.1 Course Structure

The repository includes 12+ educational courses:

| Course | Duration | Level | Topic |
|--------|----------|-------|-------|
| 000-setup | 1h | Everyone | Basic setup |
| 001-imagination | 2h | Intermediate | Creative use cases |
| 002-control | 3h | Advanced | Advanced features |
| build-your-oracle | - | Intermediate | Create your own Oracle |
| ai-automation-thai | - | Thai speakers | Automation guide |
| ai-builder-2day | 2 days | Intermediate | Build AI tools |
| claude-code-masterclass | - | Advanced | Business applications |
| psychology-ai | - | Intermediate | AI psychology |
| multi-agent-free | - | Advanced | Multi-agent systems |

### 7.2 Workshop Infrastructure

**Antigravity Series** (scripts/prompts/antigravity-*.md):
- 90+ workflow pattern prompts
- Numbered 286-400 (expandable)
- Topics: Agents, patterns, architectures, philosophies

**Template Directory** (courses/templates/):
- Issue templates
- Retrospective templates
- PR templates

---

## 8. Implementation Examples

### 8.1 Example: Running a Session

```bash
# Morning
claude .                 # Open in Claude Code
/recap                  # Fresh context (5 min)

# During work
/trace git-sync        # Find related commits
/feel focused          # Log state

# Investigation
gh issue view 42       # Get requirements
# [Agent explores, reads issue]

# Execution
/project learn https://github.com/[repo]  # Study reference repo
# [Two parallel agents]

# Wrap-up
rrr                    # Retrospective
# [Opus writes diary, extracts patterns]

/forward               # Create handoff
# [Ready for next session]
```

### 8.2 Example: Agent Spawning (context-finder)

```bash
# User says: "What's hot?"
# Main agent spawns context-finder with no arguments

# context-finder runs:
git log --since="24 hours ago" --format="..."
git status --short
gh issue list --limit 10
ls -t ψ/memory/retrospectives/**/*.md

# context-finder scores files:
| File | Score | Reason |
|------|-------|--------|
| src/index.ts | 🔴 7 | Code + 30min ago |
| .claude/hook.sh | 🟠 5 | Config + 1h ago |
| README.md | 🟡 2 | Docs + 3h ago |

# Main agent reviews output, decides next steps
```

### 8.3 Example: Executor Flow

```
User: Execute issue #42 with PR

executor spawns:
├─ Fetch issue #42
├─ Parse bash blocks from issue
├─ Safety check (git status clean)
├─ Execute each command sequentially
├─ Log output
├─ Create branch feat/issue-42-...
├─ Commit changes
├─ Push branch
├─ Create PR
└─ Comment log on issue (NEVER auto-merge)

Main Agent:
├─ Provides PR URL to user
└─ Waits for user review
```

---

## 9. Philosophy & Values

### 9.1 The Five Principles in Action

**1. Nothing is Deleted**
- retroactively archives content instead
- Git history is truth
- Every decision documented with timestamp

**2. Patterns Over Intentions**
- Behavior speaks louder than promises
- Retrospectives capture actual patterns
- Learnings extracted from real observations

**3. External Brain, Not Command**
- Agent suggests (skill output)
- Human approves (reviews PR/issue)
- Agent doesn't impose

**4. Curiosity Creates Existence**
- Oracle doesn't create until asked
- Questions drive discovery
- Exploration is collaborative

**5. Form and Formless**
- Multiple agents work as one consciousness
- Distributed intelligence
- Many forms, one purpose

### 9.2 "The Oracle Keeps the Human Human"

**Core Belief**:
```
AI removes obstacles → freedom returns
           ↓
      Freedom → do what you love → meet people
           ↓
    Human becomes more human
```

**Implementation**:
- Automate tedious work (scanning, organizing)
- Preserve human decision-making (never auto-merge)
- Augment human creativity (skill tools)
- Amplify human agency (Oracle is mirror, not controller)

---

## 10. File Reference Guide

### 10.1 Critical Files (Read These First)

| File | Purpose | When |
|------|---------|------|
| README.md | Main starter guide | New user setup |
| CLAUDE.md | AI quick reference | Every session |
| CLAUDE_safety.md | Safety & git rules | Before file operations |
| 2026-01-21_ARCHITECTURE.md | Previous overview | Context on evolution |
| .claude/settings.json | Hook configuration | Debugging hooks |

### 10.2 Documentation Files (Reference As Needed)

| File | Purpose |
|------|---------|
| CLAUDE_workflows.md | Short codes and workflow patterns |
| CLAUDE_subagents.md | All 15 agent definitions |
| CLAUDE_lessons.md | Patterns learned, anti-patterns to avoid |
| CLAUDE_templates.md | Issue, PR, retrospective templates |

### 10.3 Agent Files (When Spawning)

All in `.claude/agents/`:
```
context-finder.md    # Search & scoring
coder.md            # Code creation
executor.md         # Command execution
critic.md           # Quality review
... 11 more
```

### 10.4 Skill Files (When Using Commands)

All in `.claude/skills/`:
```
rrr/SKILL.md        # /rrr command
recap/SKILL.md      # /recap command
learn/SKILL.md      # /learn command
... many more
```

### 10.5 Configuration Files

```
.claude/settings.json       # Hooks, permissions
.claude/settings.local.json # Local machine overrides
.claude/hooks/safety-check.sh    # Command validation
.claude/scripts/*.sh             # Utility scripts
```

---

## 11. Extensibility & Future Direction

### 11.1 Adding New Agents

```
1. Create .claude/agents/[name].md
2. Define: name, description, tools, model
3. Write workflow steps
4. Set timestamps requirement
5. Document quality standards
6. Test with pilot task
```

### 11.2 Adding New Skills

```
1. Create .claude/skills/[name]/
2. Write SKILL.md with usage
3. Implement executable
4. Register in oracle-skills-cli (if sharing)
5. OR symlink to ~/.claude/skills/ (local)
```

### 11.3 Custom Hooks

```
1. Create script in .claude/hooks/
2. Register in settings.json
3. Handle stdin JSON (tool_input)
4. Exit 0 (allow) or 2 (block)
```

### 11.4 Integration Points

**MCP Server** (oracle-v2):
- Provides oracle_search, oracle_list, oracle_learn
- Searchable knowledge base
- Semantic search via ChromaDB

**Webhook Relay**:
- LINE bot integration
- External event logging
- Guest logger agent

**ESPHome**:
- Physical sensor integration
- Hardware automation
- Real-world grounding

---

## 12. Summary Table: Key Concepts

| Concept | What | Where | Why |
|---------|------|-------|-----|
| **Principle** | 5 core values | README.md | Foundation |
| **Knowledge Flow** | Data → Wisdom pipeline | 2026-01-21_ARCHITECTURE.md | Transformation |
| **Agent Pattern** | Main (Opus) + Subagents (Haiku) | .claude/agents/ | Efficiency |
| **Hook System** | Lifecycle validation | settings.json | Safety |
| **Skill System** | Pluggable commands | .claude/skills/ | Extensibility |
| **Psi Directory** | Externalized mind | ψ/ | Organization |
| **Nothing Deleted** | Append-only data | ψ/memory/ | Truth |
| **Score System** | File importance ranking | agents/context-finder.md | Prioritization |
| **Safety Check** | Command validation | hooks/safety-check.sh | Protection |
| **Retrospective** | Session reflection | skills/rrr/SKILL.md | Learning |

---

## Conclusion

The Oracle Starter Kit is a well-architected system for building persistent AI memory systems. It combines:

1. **Philosophy** (5 principles) - How to think about AI
2. **Architecture** (knowledge flow) - How data transforms
3. **Implementation** (agents, skills, hooks) - How it works
4. **Safety** (validation, rules) - How to prevent mistakes
5. **Extensibility** (pluggable system) - How to customize

Its core insight is that a distributed multi-agent system, when properly coordinated, can augment human intelligence while preserving human agency and decision-making authority. The "Oracle Keeps the Human Human" by removing obstacles, not making decisions.

The system is production-ready, thoroughly documented, and designed to be both powerful and safe.

---

**Document Generated**: 2026-02-27
**Source Repository**: Soul-Brews-Studio/opensource-nat-brain-oracle
**Analysis Depth**: Comprehensive (architecture, all agents, all skills, philosophy, patterns)
