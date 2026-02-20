# cc-statusline Analysis Notes

## Task
Analyze the repository at https://github.com/chongdashu/cc-statusline

## 2026-02-20 - Analysis Steps

### Step 1: Repository cloned
Cloned with `git clone --depth=1` to `/tmp/cc-statusline`.

### Step 2: File inventory
Repository contains these non-git files:
- `.claude/settings.json` - sample Claude Code settings
- `.claude/settings.local.json` - author's local dev settings (SECURITY NOTE: contains API key)
- `.claude/statusline.sh` - example generated output
- `.github/workflows/claude.yml` - Claude Code GitHub Actions integration
- `.github/workflows/claude-code-review.yml` - PR review automation
- `.gitignore`, `.npmignore` - ignores
- `CHANGELOG.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `LICENSE`, `README.md`
- `package.json`, `package-lock.json`, `tsconfig.json`, `tsup.config.ts`
- `src/cli/commands.ts` - init command
- `src/cli/preview.ts` - preview command
- `src/cli/prompts.ts` - interactive prompts
- `src/features/colors.ts` - color generation
- `src/features/git.ts` - git integration
- `src/features/usage.ts` - usage/cost/token data
- `src/generators/bash-generator.ts` - generates the statusline.sh script
- `src/index.ts` - entry point
- `src/utils/installer.ts` - installs to .claude/
- `src/utils/tester.ts` - tests generated script
- `src/utils/validator.ts` - validates config
- `test/test-*.sh` - shell test scripts
- `docs/images/` - PNG and GIF screenshots

### Step 3: Understanding the architecture

**Purpose**: A CLI tool that generates a custom bash statusline script for Claude Code.

**Workflow**:
1. User runs `npx @chongdashu/cc-statusline@latest init`
2. Interactive prompts ask: features to enable, theme, color preferences
3. Tool generates a `statusline.sh` bash script
4. Installs it by writing to `.claude/statusline.sh` and `.claude/settings.json`
5. Claude Code then runs `statusline.sh` on each prompt, passing JSON on stdin
6. Script parses JSON, queries git, optionally calls ccusage, and outputs formatted text

### Step 4: Dependency analysis

**Runtime npm dependencies** (4 packages):
- `commander` ^11.1.0 - CLI argument parsing
- `inquirer` ^9.2.12 - Interactive prompts
- `chalk` ^5.3.0 - Terminal colors
- `ora` ^7.0.1 - Spinner/progress UI

**Dev dependencies** (TypeScript tooling):
- `typescript` ^5.3.3
- `tsup` ^8.0.1 - bundler
- `@types/inquirer`, `@types/node`

**System dependencies** (for generated statusline.sh):
- `bash` - required (the script itself)
- `jq` - strongly recommended (JSON parsing; fallback exists)
- `git` - for branch display (optional)
- `awk`, `date`, `sed`, `grep` - standard POSIX tools
- `python3` - fallback for date parsing on some systems
- `ccusage` - external tool, only needed for session reset time feature
- `timeout` or `gtimeout` - for ccusage timeout guard

### Step 5: What the generated script does

The statusline.sh script:
1. Reads JSON from stdin (`input=$(cat)`)
2. Checks if `jq` is available
3. Optionally logs input to `.claude/statusline.log`
4. Extracts: current directory, model name, CC version, output style
5. Runs `git branch --show-current` to get current branch
6. Parses context window data from JSON
7. Parses cost/token data from JSON
8. If session feature enabled: calls `ccusage blocks --json` with 5s timeout
9. Outputs formatted colored text (3 lines max)

### Step 6: Network access

- The CLI tool itself: **NO network calls** (except npm package download at install time)
- The generated `statusline.sh`:
  - **NO direct network calls**
  - If session reset feature enabled: calls `ccusage blocks --json` which is an external tool
    - ccusage reads from `~/.claude/` local files - it doesn't make network calls itself
    - Has a 5-second timeout guard
- The GitHub Actions workflows use `anthropics/claude-code-action@beta` - this runs only in CI

### Step 7: Security findings

**Positive:**
- No arbitrary code execution beyond what's configured
- No outbound network calls in the statusline script
- Reads only from stdin (Claude Code provides JSON)
- File writes are limited to `.claude/statusline.sh`, `.claude/settings.json`, `.claude/statusline.log`
- MIT licensed, code is open and auditable
- Checks before overwriting existing files (prompts for confirmation)
- Respects `NO_COLOR` environment variable
- Uses `command -v` safely (no shell injection from environment)
- ccusage calls are guarded with timeout

**Concerns:**
1. **API key committed to repo** (`settings.local.json`): `CONTEXT7_API_KEY` is in the public repo
   - This is the author's own key for their dev environment
   - `.claude/settings.local.json` is NOT in `.gitignore` - should be
   - The key is useless to attackers without the corresponding account context
   - This reveals a security hygiene issue with the author

2. **Very broad permissions in settings.local.json**: The author's local settings grant:
   - `Bash(bash:*)` - any bash command
   - `Bash(curl:*)` - any curl command
   - These are development-convenience settings, not what gets installed on user machines
   - Would only matter if a user copied `settings.local.json` from the repo

3. **Log file creation**: The script logs JSON from Claude Code to `.claude/statusline.log`
   - This log includes session IDs, model info, directory paths, cost data
   - The log grows unboundedly (no rotation)
   - Low severity since it's local and only the user's own data

4. **stdin data processing**: The script processes JSON provided by Claude Code
   - The JSON parsing uses grep/sed regex patterns for bash fallback
   - Patterns look safe (no eval, no dynamic command construction from input)
   - Input values are only displayed, never executed

5. **ccusage dependency**: Optional; only needed for session reset time
   - ccusage is a separate package that should be evaluated on its own

### Step 8: Version history

- v1.4.0 (2025-12-24): Made token stats native (removed most ccusage dependency)
- v1.3.x (2025-08-28): Windows support, jq detection, cost tracking
- v1.2.x: Global vs project installation, safety features
- Active development since early-mid 2025

### Conclusions

The tool is legitimate, does what it says, has no malware characteristics, and poses
low security risk for personal use. The main concerns are minor operational hygiene
issues (committed API key, log growth), not fundamental security problems.
