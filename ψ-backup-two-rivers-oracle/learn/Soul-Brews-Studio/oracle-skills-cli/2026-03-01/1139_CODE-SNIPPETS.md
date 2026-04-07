# oracle-skills-cli Code Snippets

## 1. Top-Level Bun Requirement Check (`src/cli/index.ts`)
```typescript
// Bun runtime check - must be at the very top
if (typeof Bun === 'undefined') {
  console.error(`
❌ oracle-skills requires Bun runtime
You're running with Node.js, but this CLI uses Bun-specific features.
  `);
  process.exit(1);
}
```
Interesting pattern: ensuring the runner is Bun right at the top of the entry script.

## 2. Agent Definition (`src/cli/agents.ts`)
```typescript
export const agents: Record<AgentType, AgentConfig> = {
  antigravity: {
    name: 'antigravity',
    displayName: 'Antigravity',
    skillsDir: '.agent/skills',
    globalSkillsDir: join(home, '.gemini/antigravity/skills'),
    detectInstalled: () => existsSync(join(home, '.gemini/antigravity')),
  },
  gemini: {
    name: 'gemini',
    displayName: 'Gemini CLI',
    skillsDir: '.gemini/skills',
    globalSkillsDir: join(home, '.gemini/skills'),
    commandsDir: '.gemini/commands',
    globalCommandsDir: join(home, '.gemini/commands'),
    useFlatFiles: true,
    commandFormat: 'toml',
    detectInstalled: () => existsSync(join(home, '.gemini')),
  }
};
```
Defines capabilities and installation paths dynamically per agent.

## 3. Skill Version Injection (`src/cli/installer.ts`)
```typescript
// Inject version into SKILL.md frontmatter and description
const skillMdPath = join(destPath, 'SKILL.md');
if (existsSync(skillMdPath)) {
  let content = await Bun.file(skillMdPath).text();
  if (content.startsWith('---')) {
    // Add installer field after opening ---
    content = content.replace(
      /^---\n/,
      `---\ninstaller: oracle-skills-cli v${pkg.version}\n`
    );
    // Prepend version AND scope to description
    const scopeChar = scope === 'Global' ? 'G' : 'L';
    content = content.replace(
      /^(description:\s*)(.+?)(\n)/m,
      `$1v${pkg.version} ${scopeChar}-SKLL | $2$3`
    );
    await Bun.write(skillMdPath, content);
  }
}
```
This manipulates the markdown instructions on the fly so agents know the version context of their own skills.
