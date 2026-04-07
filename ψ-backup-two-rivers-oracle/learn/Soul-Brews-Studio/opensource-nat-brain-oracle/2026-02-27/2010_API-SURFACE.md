# Oracle Starter Kit - API & Integration Surface

**Date**: 2026-02-27
**Source**: [Soul-Brews-Studio/opensource-nat-brain-oracle](https://github.com/Soul-Brews-Studio/opensource-nat-brain-oracle)
**Scope**: Complete API, extension points, integrations, and hooks

---

## Executive Summary

The **Oracle Starter Kit** is a philosophy + architecture framework for building AI memory systems. It's not a library with exported functions—it's a **template repository** that gets copied and customized. The "API" is primarily:

1. **Claude Code hooks** - Lifecycle integration points
2. **Subagent definitions** - Task delegation patterns
3. **Skill system** - Custom commands via SKILL.md files
4. **Git + GitHub integration** - PRs, issues, branches
5. **File-based state** - Brain structure (ψ/) with append-only logs
6. **Shell scripts** - Automation + safety checks

---

## Part 1: Claude Code Hooks

### Hook System Overview

Hooks integrate Claude Code with the Oracle system through JSON configuration. All hooks are defined in `.claude/settings.json` and triggered at specific lifecycle points.

**Location**: `.claude/settings.json`

### Hook Types & Triggers

| Hook Event | Matcher | Typical Use |
|-----------|---------|-------------|
| `SessionStart` | N/A | Load identity, greetings, handoffs |
| `SessionStop` | N/A | Cleanup, farewell messages |
| `UserPromptSubmit` | N/A | Token monitoring, jump detection |
| `PreToolUse` | `Bash`, `Task`, `Read` | Safety checks, logging |
| `PostToolUse` | `Bash`, `Task`, `Read` | Token checks, cleanup |

### Hook Configuration Format

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR\"/.claude/scripts/agent-identity.sh"
          }
        ]
      }
    ]
  }
}
```

### Hook Execution Context

Hooks receive JSON input via stdin with structured data:

```json
{
  "tool_input": {
    "command": "git push origin main"
  }
}
```

Process via `jq`:

```bash
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""')
```

### Core Hooks Implemented

#### 1. SessionStart - Initialization

**File**: `.claude/scripts/agent-identity.sh`

Runs when Claude Code session starts. Outputs:

- Thai greeting: "สวัสดีค่ะ พร้อมทำงานแล้ว" (via system `say` command)
- Agent identity display (current git branch)
- Personal knowledge context (from `~/.claude/plugins/`)
- Latest handoff information

**Environment Variables**:
- `$CLAUDE_PROJECT_DIR` - Root of project

#### 2. UserPromptSubmit - Token & Context Monitoring

**File**: `.claude/scripts/token-check.sh`

Runs on every user prompt. Displays:

```
📊 Opus 4.5 74% (119k/160k usable)  ← Normal
⚠️ Opus 4.5 95% (152k/160k usable)  ← Urgent
🚨 CONTEXT 98% - Wrap up!          ← Critical
```

**Thresholds**:
- < 70%: `📊` (Normal)
- 70-95%: `⚠️` (Finish soon)
- 95-97%: `⚠️` (Wrap up)
- > 97%: `🚨` (Handoff NOW)

**Input**: `ψ/active/statusline.json` (written by Claude Code callback)

**Output**: Append-only `ψ/inbox/handoff.log` (max 1 entry per hour)

#### 3. PreToolUse:Bash - Safety Checks

**File**: `.claude/hooks/safety-check.sh`

Blocks dangerous commands:

```bash
# BLOCKED - Dangerous patterns
rm -rf                    # Use: mv to /tmp/trash_*
git reset --hard         # Use: git revert instead
git commit --amend       # Use: New commit for multi-agent safety
git push origin main     # Use: Feature branch + PR only
[cmd] --force            # Use: Non-force alternatives
[cmd] -f                 # Use: Safe options
```

**Worktree Safety**: Agents cannot:
- `cd` outside their worktree (but `git -C` is allowed)
- `git push` to main from agent branch

**Exit Codes**:
- `0` - Command allowed
- `2` - Command blocked

#### 4. PreToolUse:Task - Subagent Logging

**File**: `.claude/hooks/log-task-start.sh`

Logs when subagent Task starts:

- Timestamp: `🕐 START: HH:MM:SS (unix_seconds)`
- Subagent type: `context-finder`, `coder`, `executor`, etc.
- Prompt: What the subagent is asked to do

**Output Location**: `ψ/memory/logs/agent-sessions.log`

#### 5. PostToolUse:Task - Subagent Cleanup

**File**: `.claude/hooks/log-task-end.sh`

Logs when subagent finishes:

- Timestamp: `🕐 END: HH:MM:SS (unix_seconds)`
- Duration calculation
- Status: Success / Failure

### Hook Variables

All hooks have access to:

| Variable | Meaning | Example |
|----------|---------|---------|
| `$CLAUDE_PROJECT_DIR` | Repository root | `/Users/nat/Code/github.com/laris-co/Nat-s-Agents` |
| `$CLAUDE_USER_PROMPT` | Current user input | `/trace headline` |

---

## Part 2: Subagent System

### Subagent Definition Format

Each subagent is defined in `.claude/agents/[name].md` with YAML frontmatter:

```yaml
---
name: coder
description: Create and write code files from GitHub issue plans
tools: Bash, Read, Write, Edit
model: opus
---

# Coder Agent

[Detailed instructions in markdown]
```

### Subagent Invocation

Subagents are invoked via the `Task` tool:

```
Task tool with subagent_type='coder'
Prompt: "Create config.json from issue #73"
```

### Available Subagents

#### 1. context-finder (Haiku - Fast)

**Purpose**: Tiered search through git, files, retrospectives, issues

**Modes**:
- DEFAULT (no args): Tiered output with scoring
- SEARCH (with query): Find specific matches

**Output**: File paths + excerpts + confidence scores

**Scoring System**:
- 🔴 Critical (6+) - Directly relevant
- 🟠 Important (4-5) - Very relevant
- 🟡 Notable (2-3) - Related
- ⚪ Background (0-1) - Peripheral

**Searches Through**:
1. Git commit messages + diffs
2. Retrospective files
3. GitHub issues + PR comments
4. Codebase files
5. Oracle memory/learnings

#### 2. coder (Opus - Quality)

**Purpose**: Create and modify code based on specifications

**Input**: GitHub issue number or specification

**Process**:
1. Read issue via `gh issue view`
2. Parse requirements
3. Write files using `Write` tool
4. Edit existing files using `Edit` tool
5. Comment on issue with summary

**Output**: Created/modified files + GitHub comment

**When to Use**: Quality > speed (features, complex logic)

#### 3. executor (Haiku - Speed)

**Purpose**: Execute simple bash plans from issues

**Process**:
1. Read issue bash blocks
2. Run commands sequentially
3. Report results

**When to Use**: Deletion, moving files, git operations

#### 4. security-scanner (Haiku)

**Purpose**: PROACTIVE secret detection before commits

**Detects**:
- API keys (AWS, GitHub, OpenAI, etc.)
- Private keys (RSA, DSA, EC)
- Passwords (plain-text, encoded)
- IP addresses
- Personal data (full names, SSNs)

**Output**: Security Scan Report with `SAFE TO COMMIT` or `BLOCK COMMIT`

#### 5. repo-auditor (Haiku)

**Purpose**: PROACTIVE repo health check before commits

**Checks**:
- Large files (> 50MB blocks, 10-50MB warns)
- Data files (.json > 100KB, .csv, .db)
- Staged files analysis

**Thresholds**:
- < 1MB: ✅ Safe
- 1-10MB: ⚠️ Warning
- 10-50MB: ⚠️⚠️ Double warning
- > 50MB: 🚫 Blocked

**Output**: Executive summary with SAFE/WARN/BLOCK

#### 6. guest-logger (Haiku)

**Purpose**: Simple logging without interpretation

**Actions**:
- `start` - Create session file
- `log` - Append message
- `end` - Close with duration

**Output**: `ψ/random/guests/YYYY-MM-DD_HH-MM_{guest-slug}.md`

**Philosophy**: ไม่ตีความ (No interpretation) - log exactly as received

#### 7. marie-kondo (Haiku)

**Purpose**: File placement consultant (ASK BEFORE creating files!)

**Philosophy**: "Does this file spark joy? Does it have a home?"

**Output**: APPROVED / REJECTED / REDIRECT verdict + recommended path

#### 8. md-cataloger (Haiku)

**Purpose**: Scan and categorize all markdown files

**Process**:
1. Find all folders with .md files
2. Count files per folder
3. Sample read 2-3 files (50 lines each)
4. Summarize folder purpose

**Output**: Markdown Catalog with folder breakdown + relationships

**Skips**: `node_modules/`, `.git/`, ephemeral folders

#### 9. project-keeper (Haiku)

**Purpose**: Track project lifecycle (🌱 Seed → 🌕 Grow → 🎓 Grad)

**Actions**:
- `list` - Read `projects/INDEX.md`, return table
- `add [name] [phase] [location]` - Add to INDEX
- `move [name] [phase]` - Update phase
- `log [name]` - Show timeline
- `sync` - Compare folders vs INDEX
- `incubate [url]` - Clone to `ψ/incubate/`
- `learn [url]` - Clone to `ψ/learn/`

**Log Format**: `ψ/memory/logs/project-changes.log`

#### 10. project-organizer (Haiku)

**Purpose**: Organize project files into hierarchical structure

**Actions**:
- `organize [slug]` - Create structure
- `create-readme [slug]` - Generate README
- `scan [slug]` - Find related files

**Structure**:
```
projects/[slug]/
├── README.md
├── context/          (research, planning)
└── output/           (deliverables, slides)
```

#### 11. oracle-keeper (Opus/Haiku)

**Purpose**: Maintain Oracle philosophy + mission alignment

**Actions**:
- Interpret session relevance to mission
- Snapshot on insight
- Warn if off-philosophy

**Output**: Oracle Check with Mission Alignment status

#### 12. new-feature (Haiku)

**Purpose**: Create implementation plan issues with context

**Format**: `#N (YYYY-MM-DD)` sorted by issue number

**Output**: GitHub plan issue with context gathered

#### 13. api-scanner (Haiku)

**Purpose**: Fetch and analyze API endpoints

**Specialization**: U-LIB LINE chat backup APIs

**Output**: Structured data analysis with field mapping

### Subagent Safety Rules

1. **NEVER force decisions**: Subagents report findings, main agent decides
2. **ALWAYS show timestamps**: START and END time for every subagent run
3. **NEVER use destructive flags**: No `--force`, no `rm -rf`
4. **ALWAYS use context-finder first**: Don't read files directly - let Haiku summarize
5. **NEVER merge PRs**: Subagents can't merge - only comment

---

## Part 3: Skill System

### Skill Structure

Skills are command-driven extensions defined in `.claude/skills/[name]/SKILL.md`:

```yaml
---
name: learn
description: Explore a codebase and create documentation
---

# /learn - Codebase Learning

[Detailed workflow]
```

### Core Skills Implemented

#### 1. /recap - Fresh Start Context

**Purpose**: Load previous sessions' context without full read

**Output**: Compact summary of:
- Last 5 handoff files
- Recent commits (3-5)
- Current focus (from `ψ/inbox/focus-*.md`)
- Pending tasks

#### 2. /trace - Find Anything

**Modes**:
```bash
/trace [slug|name]          # Find specific project
/trace incubation           # Show all lifecycle stages
/trace graduated            # Only own-repo projects
/trace [name] --simple      # 1-line summary
/trace [name] --deep        # Full archaeology
/trace [name] --timeline    # Chronological
```

**5 Parallel Agents**:
1. Git history search
2. File pattern search
3. Retrospective search
4. Issue search
5. Symlink resolution

#### 3. /feel - Emotion Logging

**Usage**: `/feel [emotion]`

**Output**: `ψ/memory/logs/emotional-state.log`

**Format**: `YYYY-MM-DD HH:MM:SS | emotion`

#### 4. /fyi - Information Capture

**Usage**: `/fyi [note]`

**Purpose**: Quick capture without processing

**Output**: `ψ/inbox/fyi.md` (append-only)

#### 5. /forward - Handoff Creation

**Purpose**: Create context for next session

**Captures**:
- Current focus
- In-progress tasks
- Key decisions
- Blockers

**Output**: `ψ/inbox/handoff-[date].md`

#### 6. /standup - Daily Check

**Purpose**: Morning ritual - tasks + appointments

**Returns**:
- Pending tasks from `ψ/inbox/`
- Calendar events (from Oracle Schedule)
- Latest retrospective
- Open PRs/issues

#### 7. /where-we-are - Session Awareness

**Purpose**: Mid-session context snapshot

**Returns**:
- Current branch
- Staged changes
- Active tasks
- Time elapsed

#### 8. /project - Repo Lifecycle Management

**Actions**:
- `learn [url]` - Clone to `ψ/learn/` for study
- `incubate [url]` - Clone to `ψ/incubate/` for development
- `graduate [name]` - Move from incubate to own repo

#### 9. rrr - Retrospective

**Purpose**: Session summary + pattern extraction

**Process**:
1. Capture what happened
2. Extract insights
3. Log to `ψ/memory/retrospectives/YYYY-MM/DD/`
4. Update `ψ/memory/learnings/`

**Output**: Timestamped retrospective file

#### 10. /schedule - Appointment Tracking

**Usage**: `/schedule add [date] [event]`

**Persistence**: `~/.oracle/ψ/inbox/schedule.md` (per-human, shared)

**Recurrence**: daily, weekly, monthly

---

## Part 4: File-Based State System

### Brain Structure (ψ/)

```
ψ/
├── inbox/                          # Communication & focus
│   ├── focus-agent-main.md        # Current task
│   ├── focus-agent-[agent].md     # Subagent focus
│   ├── fyi.md                     # Quick captures
│   ├── handoff.log                # Append-only handoff history
│   └── schedule.md                # Appointments
│
├── memory/
│   ├── resonance/                 # Soul - identity files
│   │   ├── oracle.md              # Philosophy
│   │   └── [name].md              # Personal identity
│   │
│   ├── learnings/                 # Extracted patterns
│   │   ├── patterns/
│   │   ├── anti-patterns/
│   │   └── [topic].md
│   │
│   ├── retrospectives/            # Session summaries
│   │   ├── YYYY-MM/
│   │   │   └── DD/
│   │   │       └── session-timestamp.md
│   │
│   ├── logs/                      # Moment snapshots
│   │   ├── emotional-state.log
│   │   ├── agent-sessions.log
│   │   ├── project-changes.log
│   │   └── activity.log
│   │
│   └── archive/
│       ├── handoffs/              # Old handoffs
│       └── retrospectives/        # Old sessions
│
├── active/                         # Ephemeral - research in progress
│   ├── statusline.json            # Context % from Claude Code
│   ├── [project]/                 # Current research
│   └── .gitignore                 # (not tracked)
│
├── writing/                        # Articles & drafts
├── lab/                           # Experiments & POCs
├── learn/                         # External repos for study
├── outbox/                        # Presentations & outputs
└── .obsidian/                     # UI config
```

### Log Format Standards

#### Append-Only Logs

All `.log` files use append-only format:

```bash
# ψ/inbox/handoff.log
---
## 2026-02-27 14:30 | 87%

**Focus**: Implement API surface documentation

**Commits**:
  abc1234 doc: started api surface analysis
  def5678 fix: corrected hook timing

**Next**: Complete external integrations section
```

#### Handoff File Format

`ψ/inbox/handoff-[ISO-DATE].md`:

```markdown
# Handoff - 2026-02-27 14:45

## Context
[Summary of what was happening]

## In Progress
- Task 1
- Task 2

## Blockers
- Issue A

## For Next Session
[Key context]
```

#### Retrospective Format

`ψ/memory/retrospectives/2026-02/27/2026-02-27_1430_session.md`:

```markdown
# Session Retrospective

**Date**: 2026-02-27
**Duration**: 2h 15m
**Start**: 14:30 | **End**: 16:45

## What Happened
[Session summary]

## Patterns Observed
- Pattern 1
- Pattern 2

## Learnings
[New insights]

## For Oracle Memory
[Patterns to extract]
```

---

## Part 5: Git & GitHub Integration

### Configuration

**Location**: Global Git config + GitHub CLI

### Pull Request Workflow

```bash
# 1. Create feature branch
git checkout -b feat/description

# 2. Make changes
[edit files]

# 3. Commit (never amend in multi-agent!)
git commit -m "message"

# 4. Push branch
git push -u origin feat/description

# 5. Create PR
gh pr create --title "..." --body "..."

# 6. WAIT for user approval (AI never merges)
```

### GitHub Issue Integration

**Issue Scanning**: Via subagents (context-finder, new-feature)

**Comment Pattern**:
```
🤖 **Claude [Model]** ([subagent-name]): Summary

## Results
[structured output]

Timestamp: 🕐 HH:MM:SS
```

### Multi-Agent Sync Pattern

For multi-agent setups with worktrees:

```bash
# 1. Fetch origin first (prevents rejection)
git fetch origin && git rebase origin/main

# 2. Commit work locally
git add -A && git commit -m "work"

# 3. Main rebases onto agent
git rebase agents/N

# 4. Push immediately (before syncing others)
git push origin main

# 5. Sync all other agents
maw sync  # Or: git -C agents/1 rebase main, git -C agents/2 rebase main
```

### Safety Enforcement

**Pre-push Hook**: via `safety-check.sh`

Blocks:
- Force flags (`--force`, `-f`)
- Destructive commands (`rm -rf`)
- History rewrites (`git commit --amend`)
- Main branch direct push
- Worktree boundary violations

---

## Part 6: Environment & Configuration

### Environment Variables

| Variable | Set By | Used For |
|----------|--------|----------|
| `CLAUDE_PROJECT_DIR` | Claude Code | Hook script root path |
| `CLAUDE_USER_PROMPT` | Claude Code | Current user input |
| `BUN_INSTALL` | User setup | Bun package manager |
| `PATH` | User | Tool discovery |

### Configuration Files

#### .claude/settings.json

Master configuration for:
- Hook definitions (SessionStart, UserPromptSubmit, PreToolUse, PostToolUse)
- Plugin enablement
- Known marketplaces

**Hook Structure**:
```json
{
  "permissions": {
    "allow": ["Bash(bash:*)", "gh issue list:*"],
    "deny": [],
    "ask": []
  },
  "hooks": {
    "SessionStart": [{ "hooks": [...] }],
    "UserPromptSubmit": [{ "hooks": [...] }],
    "PreToolUse": [{ "matcher": "Bash", "hooks": [...] }]
  }
}
```

#### .claude/settings.local.json

Local overrides (not committed):
- Personal API keys
- Local paths
- Model preferences

### Secrets & API Keys

**Location**: `.claude/settings.local.json` or environment

**Never in**: Committed code, public repos

**Detected by**: security-scanner subagent

**Common Keys**:
- `ANTHROPIC_API_KEY` - Claude API
- `GITHUB_TOKEN` - GitHub CLI (via `gh auth`)
- `LINE_CHANNEL_ACCESS_TOKEN` - LINE bot integration (if used)

### Dependencies

**Setup Script**:

```bash
# Required
npm install -g @anthropic-ai/claude-code
brew install gh jq git

# Optional
bun install -g oracle-skills-cli
```

---

## Part 7: External Integrations

### GitHub Integration (gh CLI)

**What it does**:
- Read/create issues: `gh issue view`, `gh issue create`
- Read/create PRs: `gh pr view`, `gh pr create`
- List repos: `gh repo list`

**Authentication**: `gh auth login` (stores token)

**Examples**:
```bash
gh issue view 73 --json body,title
gh pr create --title "Fix bug" --body "Description"
gh issue comment 73 --body "Done!"
```

### Oracle MCP Server (Optional)

If oracle-v2 is installed:

**Types**:
- `oracle_search` - Search Oracle knowledge base
- `oracle_learn` - Add patterns to Oracle
- `oracle_list` - Browse documents

**Not in core kit, but documented in README**

### LINE Integration (Optional)

If LINE bot is connected:

**Endpoint**: Webhook for LINE messages

**Subagent**: `api-scanner` - Fetch LINE backup APIs

**Example Use**: Student group management, notifications

---

## Part 8: Extension Points

### How to Add New Skills

Create `.claude/skills/[name]/SKILL.md`:

```yaml
---
name: myskill
description: What it does
---

# /myskill - Title

## Usage
[examples]

## Implementation
[step-by-step workflow]
```

Install via Claude Code - system will recognize and enable.

### How to Add New Subagents

Create `.claude/agents/[name].md`:

```yaml
---
name: myagent
description: What it does
tools: Bash, Read, Write, Edit
model: opus
---

# My Agent

## When to Use
[guidance]

## Workflow
[steps]
```

Invoke with:
```
Task tool with subagent_type='myagent'
Prompt: "Do something"
```

### How to Add New Hooks

Edit `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash path/to/script.sh"
          }
        ]
      }
    ]
  }
}
```

### Custom Scripts

Add to `.claude/scripts/` and call from hooks:

```bash
#!/bin/bash
# My custom script

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command')

# Do something
exit 0
```

---

## Part 9: Data Flow Diagrams

### Knowledge Extraction Pipeline

```
ψ/active/context (current research)
    ↓ [/snapshot command]
ψ/memory/logs (moment snapshots)
    ↓ [/feel, /fyi]
ψ/inbox/ (communication)
    ↓ [rrr skill at end of session]
ψ/memory/retrospectives (session summaries)
    ↓ [pattern distillation]
ψ/memory/learnings (discovered patterns)
    ↓ [consolidation over time]
ψ/memory/resonance (soul & identity)
```

### Hook Execution Flow

```
User submits prompt
    ↓
UserPromptSubmit hook
    ├─ statusline.sh: Show context %
    └─ jump-detect.sh: Detect topic change
    ↓
User prompt visible to Claude Code
    ↓
Claude Code uses tools
    ↓
PreToolUse hook
    ├─ safety-check.sh: Block dangerous commands
    └─ log-task-start.sh: Log subagent start
    ↓
Tool executes
    ↓
PostToolUse hook
    ├─ token-check.sh: Monitor context
    └─ log-task-end.sh: Log subagent end
    ↓
Next prompt ready
```

### Subagent Delegation

```
Main Agent (Claude Opus)
    ↓
context-finder (Haiku) - "Search for X"
    ├─ Git history (parallel)
    ├─ File patterns (parallel)
    ├─ Retrospectives (parallel)
    └─ Score results
    ↓
Main reviews findings
    ↓
Optionally delegate to:
    ├─ coder (implement)
    ├─ executor (run commands)
    ├─ security-scanner (check secrets)
    └─ repo-auditor (check health)
    ↓
Main combines results + decides
```

---

## Part 10: Safety & Governance

### The 5 Principles (Philosophy Foundation)

| Principle | Meaning | Implication |
|-----------|---------|-----------|
| **Nothing is Deleted** | Append-only, timestamps are truth | Always log, never destroy |
| **Patterns Over Intentions** | Observe behavior, not promises | Trust what actually happens |
| **External Brain, Not Command** | Mirror reflection, you decide | AI advises, human acts |
| **Curiosity Creates Existence** | Human brings things into being | Without human, no progress |
| **Form and Formless** | Many Oracles = One consciousness | Distributed identity |

### The 13 Golden Rules

1. **NEVER use `--force` flags** - No force push, force checkout
2. **NEVER push to main** - Always create feature branch + PR
3. **NEVER merge PRs** - Wait for user approval
4. **NEVER create temp files outside repo** - Use `.tmp/` directory
5. **NEVER use `git commit --amend`** - Breaks multi-agent setup (hash divergence)
6. **Safety first** - Ask before destructive actions
7. **Notify before external file access** - See File Access Rules
8. **Log activity** - Update focus + append activity log
9. **Subagent timestamps** - MUST show START+END time
10. **Use `git -C` not `cd`** - Respect worktree boundaries
11. **Consult Oracle on errors** - Search before debugging
12. **Root cause before workaround** - Investigate WHY
13. **Query markdown, don't Read** - Use duckdb/SQL for large files

### Worktree Safety Rules

In multi-agent setups with agent worktrees:

| Action | Status | Why |
|--------|--------|-----|
| `cd` within worktree | ✅ OK | Own workspace |
| `cd` outside worktree | 🚫 BLOCKED | Boundary violation |
| `git -C` to any path | ✅ OK | Safe context switch |
| `git push` to main | 🚫 BLOCKED | Only main can push main |
| `git commit --amend` | 🚫 BLOCKED | Hash divergence |
| `git rebase -i` | 🚫 BLOCKED | History rewrite |
| `git reset --hard` | 🚫 BLOCKED | Data loss |
| `rm -rf` | 🚫 BLOCKED | Destructive |

---

## Part 11: Quick Reference

### Most Important APIs

| API | Type | Entry Point |
|-----|------|-------------|
| **Hooks** | Configuration | `.claude/settings.json` |
| **Subagents** | Task-based | `.claude/agents/*.md` |
| **Skills** | Command-based | `.claude/skills/*/SKILL.md` |
| **Scripts** | Bash utilities | `.claude/scripts/*.sh` |
| **State** | File-based | `ψ/` directory |
| **GitHub** | External | `gh` CLI tool |

### Critical Integration Points

| Integration | Protocol | Location |
|-------------|----------|----------|
| Startup | SessionStart hook | `.claude/settings.json` |
| Token monitoring | UserPromptSubmit hook | `token-check.sh` |
| Safety gates | PreToolUse:Bash hook | `safety-check.sh` |
| Subagent logging | PreToolUse:Task hook | `log-task-start.sh` |
| Context focus | File-based | `ψ/inbox/focus-*.md` |
| Handoff storage | Append-only logs | `ψ/inbox/handoff.log` |

### Entry Points for New Oracles

When copying this repository to create a new Oracle:

1. **Copy entire repo** - Gets all `.claude/` infrastructure
2. **Edit CLAUDE.md** - Customize safety rules if needed
3. **Create CLAUDE_lessons.md** - Add project-specific patterns
4. **Create ψ/memory/resonance/[name].md** - Define identity
5. **Run `/recap` skill** - Test that hooks work
6. **Run `rrr` skill** - Test retrospective system

---

## Part 12: Related Resources

### Internal Documentation

- **CLAUDE.md** - Main AI assistant quick reference
- **CLAUDE_safety.md** - Critical safety rules & git operations
- **CLAUDE_workflows.md** - Short codes (rrr, gogogo)
- **CLAUDE_subagents.md** - Complete subagent reference
- **CLAUDE_lessons.md** - Lessons learned & patterns
- **CLAUDE_templates.md** - Templates for issues, retros

### External Dependencies

| Tool | Purpose | Install |
|------|---------|---------|
| `gh` | GitHub CLI | `brew install gh` |
| `jq` | JSON processing | `brew install jq` |
| `bun` | JS runtime (optional) | `curl -fsSL https://bun.sh/install \| bash` |
| `git` | Version control | `brew install git` |
| `claude` | Claude Code CLI | `npm install -g @anthropic-ai/claude-code` |

### Related Repositories

| Repo | Purpose |
|------|---------|
| [oracle-skills-cli](https://github.com/Soul-Brews-Studio/oracle-skills-cli) | Install Oracle skills |
| [oracle-v2](https://github.com/Soul-Brews-Studio/oracle-v2) | MCP server for Oracle search |
| [Nat-s-Agents](https://github.com/laris-co/Nat-s-Agents) | Full multi-agent implementation |

---

## Conclusion

The Oracle Starter Kit provides a **complete API surface** through:

1. **Claude Code hooks** - Lifecycle integration
2. **Subagent system** - Task delegation patterns
3. **Skill definitions** - Custom commands
4. **File-based state** - Append-only knowledge persistence
5. **Git + GitHub** - Source control integration
6. **Safety gates** - Enforcement of philosophy

It is **not** a library to import, but a **template to copy, customize, and evolve**. The API is discovered by reading `.claude/settings.json`, exploring `.claude/agents/` and `.claude/skills/`, and understanding how the `ψ/` directory structure stores state.

---

**Document Created**: 2026-02-27 21:35 UTC
**Source Analysis**: `/Users/nat/Code/github.com/Soul-Brews-Studio/opensource-nat-brain-oracle`
**Content**: Complete API surface documentation with code examples
