# oracle-skills-cli Architecture

## Directory Structure

```
oracle-skills-cli/
├── src/
│   ├── cli/
│   │   ├── index.ts        # CLI entry point (Commander.js setup)
│   │   ├── agents.ts       # Agent configurations & paths
│   │   ├── installer.ts    # Installation logic & file manipulation
│   │   ├── fs-utils.ts     # File system wrappers
│   │   └── types.ts        # TypeScript interfaces
│   ├── skills/             # Source markdown skills that get installed
│   ├── profiles.ts         # Logic for skill bundles (minimal, full, etc.)
│   └── commands/           # (Optional) Precompiled stubs
├── docs/                   # Documentation
├── install.sh              # Shell installer script
└── package.json            # Bun package definition
```

## Core Abstractions

1. **Agents Configuration (`src/cli/agents.ts`)**
   A centralized `agents` object maps supported agents (e.g. `claude-code`, `antigravity`, `gemini`) to their respective local and global installation paths (`skillsDir`, `globalSkillsDir`, `commandsDir`). It also contains detection logic.

2. **Installer Logic (`src/cli/installer.ts`)**
   The installer resolves the target skills (via profile or explicit list), and copies the folders into the agent's target directory. It modifies the `SKILL.md` frontmatter on the fly to inject the installer version and scope (Global/Local).

3. **Profiles (`src/profiles.ts`)**
   Allows grouping skills into sets like `minimal`, `standard`, etc.

## Dependencies

- **Bun**: This CLI requires the Bun JavaScript runtime and heavily uses `Bun.$` for shell operations, `Bun.file().text()` for reading strings, and Bun's ultra-fast package manager.
- **commander**: For parsing CLI arguments.
- **@clack/prompts**: For beautiful interactive CLI prompts when no flags are passed.
