# oracle-skills-cli Quick Reference

## What it does
The `oracle-skills-cli` is a package manager designed to deploy "skills" (curated prompts and configuration workflows for LLM coding agents) to a variety of agent frameworks including Claude Code, Cursor, OpenCode, Antigravity, and Gemini CLI.

## Installation Methods

**Via curl + bash** (Auto-installs bun and ghq if missing):
```bash
curl -fsSL https://raw.githubusercontent.com/Soul-Brews-Studio/oracle-skills-cli/main/install.sh | bash
```

**Via Bun directly**:
```bash
# Requires Bun runtime
~/.bun/bin/bunx --bun oracle-skills@github:Soul-Brews-Studio/oracle-skills-cli#main install -g -y
```

## Key Features
- **Cross-Agent Support**: Identifies what agents are installed locally (via `~/.gemini`, `~/.claude`, etc.) and seamlessly pushes skills into the correct `skills/` folders.
- **Skill Profiles**: Supports `seed`, `minimal`, `standard`, and `full` collections of skills so agents aren't overwhelmed by too many instructions.
- **Auto-Cleanup**: Tracks which skills it previously injected (using frontmatter signatures) and cleans them up if they are deleted or deselected.
- **Slash Command Stubs**: Generates `.md` or `.toml` stubs for agents that rely on command files instead of raw directories.

## Usage
List skills available to install/uninstall:
```bash
oracle-skills list
```

Install explicitly for Antigravity, globally, skipping prompts:
```bash
oracle-skills install -g -y -a antigravity
```
