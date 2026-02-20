# Analysis Report: chongdashu/cc-statusline

**Repository:** https://github.com/chongdashu/cc-statusline
**Analyzed:** 2026-02-20
**Version at time of analysis:** 1.4.0

---

## What Is It?

`cc-statusline` is a CLI tool that generates a custom statusline for **Claude Code** (Anthropic's AI coding assistant). When installed, it adds a multi-line informational header to the Claude Code terminal showing:

- Current working directory and git branch
- Active Claude model name and Claude Code version
- Context window usage (percentage remaining with progress bar)
- Session cost, burn rate ($/hour), and token statistics
- Optionally: session reset timer (time until usage limit resets)

The tool is invoked as:
```
npx @chongdashu/cc-statusline@latest init
```

It answers a few interactive questions and then generates a `statusline.sh` bash script that Claude Code executes on every prompt refresh.

---

## How It Works

```
User runs init CLI
    ↓
Interactive prompts (feature selection, theme, colors)
    ↓
TypeScript generator produces statusline.sh
    ↓
Installer writes statusline.sh to .claude/ and updates settings.json
    ↓
On each Claude Code prompt:
    Claude Code → JSON on stdin → statusline.sh → formatted text output
```

The generated `statusline.sh`:
1. Reads Claude Code's JSON (session data, costs, tokens, context) from stdin
2. Runs `git branch --show-current` to get current branch
3. Parses the JSON using `jq` (preferred) or bash `grep`/`sed` fallback
4. Optionally calls `ccusage blocks --json` (with 5s timeout) for session reset time
5. Outputs up to three colored lines of status text

---

## Dependencies

### npm Package Dependencies (Runtime)

| Package | Version | Purpose |
|---------|---------|---------|
| `commander` | ^11.1.0 | CLI argument and command parsing |
| `inquirer` | ^9.2.12 | Interactive terminal prompts |
| `chalk` | ^5.3.0 | Terminal color output |
| `ora` | ^7.0.1 | Spinner/progress indicator UI |

All four are well-known, widely-used packages with good reputations in the Node.js ecosystem.

### npm Dev Dependencies (Build-time Only)

| Package | Purpose |
|---------|---------|
| `typescript` ^5.3.3 | TypeScript compiler |
| `tsup` ^8.0.1 | TypeScript bundler |
| `@types/inquirer`, `@types/node` | Type definitions |

Dev dependencies are only needed to build from source; they are not included in the published npm package.

### System Dependencies (for generated statusline.sh)

| Tool | Required | Purpose |
|------|----------|---------|
| `bash` | Required | The script runs in bash |
| `jq` | Strongly recommended | JSON parsing (fallback exists) |
| `git` | Optional | Branch name display |
| `awk`, `date`, `sed`, `grep` | Required | Standard POSIX tools (system-provided) |
| `python3` | Optional | Date/epoch fallback on some systems |
| `ccusage` | Optional | Session reset time only |
| `timeout` / `gtimeout` | Optional | Timeout guard for ccusage |

The only non-standard optional dependency is `ccusage` (separate npm package from a different author: `ryoppippi/ccusage`). It is only called when the session reset timer feature is enabled.

---

## File System Impact

After installation, the tool creates/modifies:

```
.claude/                      (or ~/.claude/ for global install)
├── statusline.sh             written (new file, executable)
├── settings.json             modified (adds "statusLine" key)
└── statusline.log            created at runtime (if logging enabled)
```

The `settings.json` modification is minimal — it adds one key:
```json
{
  "statusLine": {
    "type": "command",
    "command": ".claude/statusline.sh",
    "padding": 0
  }
}
```

The tool prompts before overwriting any existing files.

---

## Network Access

| Component | Network Access |
|-----------|---------------|
| CLI tool (`npx init`) | None beyond npm package download |
| Generated `statusline.sh` | None (reads from stdin only) |
| `ccusage` (optional) | Reads `~/.claude/` local files; no network calls |
| GitHub Actions workflows | Uses `anthropics/claude-code-action@beta` in CI only |

**The installed statusline script makes no outbound network requests.**

---

## Security Assessment

### Verdict: Low risk for personal workstation use

The tool is straightforward, auditable, and does what it advertises. There are no signs of malicious intent or supply-chain concerns.

### Positive Security Properties

- **No network calls** in the running statusline script
- **No arbitrary code execution** — the script only reads stdin, runs `git`, and optionally `ccusage`
- **No use of `eval`** or dynamic command construction from user-controlled input
- **Input data is only displayed**, never executed
- **Confirmation prompts** before overwriting existing configuration
- **Timeout guard** on ccusage calls (5 seconds) prevents hangs
- **Respects `NO_COLOR`** and other terminal conventions
- **MIT license** — fully open source and auditable
- **Scoped writes** — only touches `.claude/` directory

### Concerns (Minor)

**1. API key committed to repository**
File `.claude/settings.local.json` contains `CONTEXT7_API_KEY: ctx7sk-6ac2f7e9-685d-445c-aaab-6cbfc1fca9f7` — the author's own API key for a context management service used during development. This file is **not listed in `.gitignore`** and is publicly visible in the repo.

*Impact for users:* Low. This is the author's key, not yours. It cannot be used to compromise user machines. It does, however, indicate a lapse in security hygiene by the project author.

**2. Overly broad development permissions in settings.local.json**
The same file grants `Bash(bash:*)` and `Bash(curl:*)` permissions — Claude Code hooks that allow any bash or curl command to run without confirmation. These are the author's own convenience settings for developing the project, not what gets written to user machines during installation.

*Impact for users:* None, as long as you don't copy `settings.local.json` from the repo.

**3. Log file with session data**
If the logging option is enabled during setup, the script appends Claude Code's full JSON input (session IDs, directory paths, cost data, token counts) to `.claude/statusline.log`. The log has no rotation and will grow indefinitely.

*Impact:* Low severity — data is local and is your own session information. Disable logging during init if this is a concern.

**4. ccusage dependency (optional)**
The session reset timer feature calls an external tool (`ccusage`) maintained by a different author (`ryoppippi`). If you enable this feature, you should separately evaluate `ccusage`. The call is guarded with a 5-second timeout.

*Impact:* Opt-in only. Most users won't need this feature.

### What It Does NOT Do

- Does not exfiltrate data to remote servers
- Does not modify files outside `.claude/`
- Does not request elevated privileges
- Does not hook into system startup or install background services
- Does not embed obfuscated code
- Does not touch SSH keys, browser data, or credentials

---

## Code Quality

- Written in TypeScript with clear module separation
- The bash generator produces readable, well-commented scripts
- Graceful fallbacks when tools like `jq`, `git`, or `ccusage` are absent
- Active development: 5+ releases in 2025, responsive to bug reports
- One known contributor fixed a critical performance bug (infinite process spawning)
- Includes test scripts for concurrent process locking

---

## Summary Table

| Attribute | Details |
|-----------|---------|
| Language | TypeScript (CLI) + Bash (generated script) |
| License | MIT |
| Latest version | 1.4.0 (2025-12-24) |
| npm package | `@chongdashu/cc-statusline` |
| Node.js requirement | >=16.0.0 |
| Network calls | None (at runtime) |
| File writes | `.claude/statusline.sh`, `.claude/settings.json`, optionally `.claude/statusline.log` |
| Elevated privileges | None required |
| Background services | None installed |
| Safety for personal use | **Yes, with minor caveats noted above** |

---

## Source File Inventory

All source files reviewed directly during analysis:

| File | Size | Role |
|------|------|------|
| `src/index.ts` | 1,320 B | CLI entry point (Commander.js) |
| `src/cli/commands.ts` | 8,001 B | init command; jq check; install orchestration |
| `src/cli/prompts.ts` | 3,276 B | Inquirer interactive prompts; feature selection |
| `src/cli/preview.ts` | 3,561 B | Preview command; bash subprocess with mock data |
| `src/generators/bash-generator.ts` | 12,614 B | Core: assembles statusline.sh from TypeScript templates |
| `src/features/usage.ts` | 8,217 B | Generates bash for cost/token/session metrics |
| `src/features/git.ts` | 1,198 B | Generates bash for git branch detection |
| `src/features/colors.ts` | 2,380 B | Generates ANSI color code bash functions |
| `src/utils/installer.ts` | 4,914 B | Writes statusline.sh and settings.json |
| `src/utils/tester.ts` | 6,321 B | Spawns bash subprocess for script testing |
| `src/utils/validator.ts` | 2,110 B | Validates user config selections |
| `.claude/statusline.sh` | 11,796 B | Example generated output script |
| `.claude/settings.json` | 105 B | Sample Claude Code settings |
| `.claude/settings.local.json` | 639 B | Author dev config (contains committed API key) |
| `test/test-installation.sh` | 9,711 B | Shell tests for installation scenarios |
| `test/test-concurrent-locking.sh` | 1,586 B | Tests concurrent process locking |
| `test/test-statusline-with-lock.sh` | 1,945 B | Tests statusline + locking behavior |

---

## Shell Commands Executed by the Generated statusline.sh

The generated script uses only these system tools:

```
jq                 # JSON parsing (optional; falls back to grep/sed)
git rev-parse      # Current git branch
date / gdate       # Timestamp conversion
python3 -c         # Date epoch fallback on some systems
grep, sed, tr, awk # Standard POSIX text processing
command -v         # Tool availability check
ccusage blocks     # Optional; session reset time only; 5s timeout guard
timeout / gtimeout # Execution timeout for ccusage
```

No tool receives user-controlled input that is then passed to the shell (no command injection vector). All dynamic values from parsed JSON are used for display/arithmetic only.

---

## Changelog Highlights (Security-Relevant)

| Version | Change |
|---------|--------|
| v1.4.0 (2025-12-24) | Token stats now use Claude Code native data; ccusage only for session reset (off by default) |
| v1.3.2 | Fixed quote-escaping vulnerability in bash JSON fallback parser |
| v1.2.3 | Fixed critical bug: ccusage was spawning uncontrolled background processes; added file-based locking with PID tracking |
| v1.2.4 | Added global vs project-level installation choice |

---

## Recommendation

**Safe to run on a personal workstation.** The tool is a legitimate productivity enhancement for Claude Code users. Install it via `npx` if you want to try it without permanently installing.

If privacy is a concern, decline the logging option during setup. If you don't care about session reset times, don't enable the session timer feature (this avoids the `ccusage` dependency entirely).

The committed API key in `settings.local.json` is worth noting as a project hygiene issue but poses no risk to users.
