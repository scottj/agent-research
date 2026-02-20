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

---

## 2026-02-20 - Full Source Analysis (Second Pass)

Fetched all source files via GitHub API and raw content URLs. Augmenting notes with
deeper analysis of each file.

### Additional Files Reviewed

**src/index.ts**
- Entry point, sets up Commander.js with init/preview/test commands
- `init` command writes to `.claude/statusline.sh` (default)
- `preview` command reads and runs an existing statusline.sh with mock data
- `test` command is a stub (prints "coming soon")

**src/cli/commands.ts**
- `checkJqInstallation()` runs `command -v jq` - standard and safe
- `initCommand()` orchestrates: checks jq, collects config, generates script, installs
- Checks both global (~/.claude) and project-level (.claude) installs
- Shows next-steps instructions to user

**src/cli/prompts.ts**
- Uses Inquirer for interactive checkbox/list prompts
- 8 feature options: working directory, git branch, model name, context %, cost, tokens,
  burn rate, session reset time
- Validates at least one feature selected
- Enables ccusage integration only if session reset is chosen

**src/cli/preview.ts**
- Reads existing statusline.sh from disk with fs.readFile()
- Executes it with `spawn('bash', [scriptPath])` with piped I/O
- Uses mock Claude Code JSON data
- 5-second timeout

**src/generators/bash-generator.ts**
- Core of the tool - assembles bash script from TypeScript template strings
- No eval of user input; builds the script text statically
- Script receives data via stdin only (Claude Code pipes JSON)

**src/features/usage.ts**
- Generates bash code for cost/token display
- Uses `ccusage blocks --json` with timeout guard (5s via `timeout` or `gtimeout`)
- Since v1.4.0 tokens/TPM use CC native data (no ccusage needed for those)

**src/features/git.ts**
- Generates bash code running `git rev-parse --abbrev-ref HEAD`
- Simple, standard git usage

**src/features/colors.ts**
- Generates ANSI color code bash functions
- Respects NO_COLOR env variable
- 256-color ANSI codes for terminal display

**src/utils/installer.ts**
- Creates .claude/ directory with mkdir -p
- Writes statusline.sh with 0o755 permissions
- Reads and updates settings.json (JSON parse/stringify)
- Platform-aware: different command for Windows vs Unix

**src/utils/tester.ts**
- Creates temp file in /tmp with 0o755
- Spawns bash subprocess
- 5-second timeout with process kill
- Cleanup of temp files

**src/utils/validator.ts**
- Validates config structure
- Warns about performance (>5 features)
- Note: validateDependencies() currently returns placeholders

**.claude/statusline.sh** (example generated script)
- 11,796 bytes
- Self-contained bash script
- No network calls
- Reads stdin once (`input=$(cat)`)
- Runs: jq, git, date, grep, sed, tr, awk
- Optionally logs to statusline.log
- Only outputs formatted text to stdout

**.claude/settings.json**
```json
{"statusLine": {"type": "command", "command": ".claude/statusline.sh", "padding": 0}}
```

**.claude/settings.local.json** (developer's local config)
- Contains CONTEXT7_API_KEY = ctx7sk-6ac2f7e9-685d-445c-aaab-6cbfc1fca9f7
- Very permissive Claude Code tool permissions (Bash:*, curl:*)
- This is the repo author's dev environment config - NOT what gets installed on user machines
- It was accidentally committed to the public repo (security hygiene issue)

### GitHub Actions Workflows
Two workflow files exist:
- claude.yml - uses anthropics/claude-code-action@beta for issue handling
- claude-code-review.yml - automated PR review
Both only run in CI (GitHub Actions). Not relevant to end-user security.

### Final Determination
Safe to run on a personal workstation. No malware characteristics. Benign statusline tool.
