# Research projects carried out by AI tools

Each directory in this repo is a separate research project carried out by an LLM tool - usually [Claude Code](https://www.claude.com/product/claude-code). Every single line of text and code was written by an LLM.

Inspired by [simonw/research](https://github.com/simonw/research).

<!--[[[cog
import os
import re
import subprocess
import pathlib
from datetime import datetime, timezone

# Model to use for generating summaries
MODEL = "github/gpt-4.1"

# Get all subdirectories with their first commit dates
research_dir = pathlib.Path.cwd()
subdirs_with_dates = []

for d in research_dir.iterdir():
    if d.is_dir() and not d.name.startswith('.') and not d.name.startswith('_'):
        # Get the date of the first commit that touched this directory
        try:
            result = subprocess.run(
                ['git', 'log', '--diff-filter=A', '--follow', '--format=%aI', '--reverse', '--', d.name],
                capture_output=True,
                text=True,
                timeout=5
            )
            if result.returncode == 0 and result.stdout.strip():
                # Parse first line (oldest commit)
                date_str = result.stdout.strip().split('\n')[0]
                commit_date = datetime.fromisoformat(date_str.replace('Z', '+00:00'))
                subdirs_with_dates.append((d.name, commit_date))
            else:
                # No git history, use directory modification time
                subdirs_with_dates.append((d.name, datetime.fromtimestamp(d.stat().st_mtime, tz=timezone.utc)))
        except Exception:
            # Fallback to directory modification time
            subdirs_with_dates.append((d.name, datetime.fromtimestamp(d.stat().st_mtime, tz=timezone.utc)))

# Print the heading with count
print(f"## {len(subdirs_with_dates)} research projects\n")

# Sort by date, most recent first
subdirs_with_dates.sort(key=lambda x: x[1], reverse=True)

for dirname, commit_date in subdirs_with_dates:
    folder_path = research_dir / dirname
    readme_path = folder_path / "README.md"
    summary_path = folder_path / "_summary.md"

    date_formatted = commit_date.astimezone(timezone.utc).strftime('%Y-%m-%d %H:%M')

    # Get GitHub repo URL
    github_url = None
    try:
        result = subprocess.run(
            ['git', 'remote', 'get-url', 'origin'],
            capture_output=True,
            text=True,
            timeout=2
        )
        if result.returncode == 0 and result.stdout.strip():
            origin = result.stdout.strip()
            # Convert SSH URL to HTTPS URL for GitHub
            if origin.startswith('git@github.com:'):
                origin = origin.replace('git@github.com:', 'https://github.com/')
            if origin.endswith('.git'):
                origin = origin[:-4]
            github_url = f"{origin}/tree/main/{dirname}"
    except Exception:
        pass

    # Extract title from first H1 header in README, fallback to dirname
    title = dirname
    if readme_path.exists():
        with open(readme_path, 'r') as f:
            for readme_line in f:
                if readme_line.startswith('# '):
                    title = readme_line[2:].strip()
                    break

    if github_url:
        print(f"### [{title}]({github_url}#readme) ({date_formatted})\n")
    else:
        print(f"### {title} ({date_formatted})\n")

    # Check if summary already exists
    if summary_path.exists():
        # Use cached summary
        with open(summary_path, 'r') as f:
            description = f.read().strip()
            if description:
                print(description)
            else:
                print("*No description available.*")
    elif readme_path.exists():
        # Generate new summary using llm command
        prompt = """Summarize this research project concisely. Write just 1 paragraph (3-5 sentences) followed by an optional short bullet list if there are key findings. Vary your opening - don't start with "This report" or "This research". Include 1-2 links to key tools/projects. Be specific but brief. No emoji."""
        result = subprocess.run(
            ['llm', '-m', MODEL, '-s', prompt],
            stdin=open(readme_path),
            capture_output=True,
            text=True,
            timeout=60
        )
        if result.returncode != 0:
            error_msg = f"LLM command failed for {dirname} with return code {result.returncode}"
            if result.stderr:
                error_msg += f"\nStderr: {result.stderr}"
            raise RuntimeError(error_msg)
        if result.stdout.strip():
            description = result.stdout.strip()
            print(description)
            # Save to cache file
            with open(summary_path, 'w') as f:
                f.write(description + '\n')
        else:
            raise RuntimeError(f"LLM command returned no output for {dirname}")
    else:
        print("*No description available.*")

    print()  # Add blank line between entries

# Add AI-generated note to all project README.md files
# Note: we construct these marker strings via concatenation to avoid the HTML comment close sequence
AI_NOTE_START = "<!-- AI-GENERATED-NOTE --" + ">"
AI_NOTE_END = "<!-- /AI-GENERATED-NOTE --" + ">"
AI_NOTE_CONTENT = """> [!NOTE]
> This is an AI-generated research report. All text and code in this report was created by an LLM (Large Language Model). For more information on how these reports are created, see the [main research repository](https://github.com/scottj/agent-research)."""

for dirname, _ in subdirs_with_dates:
    folder_path = research_dir / dirname
    readme_path = folder_path / "README.md"

    if not readme_path.exists():
        continue

    content = readme_path.read_text()

    # Check if note already exists
    if AI_NOTE_START in content:
        # Replace existing note
        pattern = re.escape(AI_NOTE_START) + r'.*?' + re.escape(AI_NOTE_END)
        new_note = f"{AI_NOTE_START}\n{AI_NOTE_CONTENT}\n{AI_NOTE_END}"
        new_content = re.sub(pattern, new_note, content, flags=re.DOTALL)
        if new_content != content:
            readme_path.write_text(new_content)
    else:
        # Add note after first heading (# ...)
        lines = content.split('\n')
        new_lines = []
        note_added = False
        for i, line in enumerate(lines):
            new_lines.append(line)
            if not note_added and line.startswith('# '):
                # Add blank line, then note, then blank line
                new_lines.append('')
                new_lines.append(AI_NOTE_START)
                new_lines.append(AI_NOTE_CONTENT)
                new_lines.append(AI_NOTE_END)
                note_added = True

        if note_added:
            readme_path.write_text('\n'.join(new_lines))

]]]-->
## 3 research projects

### [Cross-Platform Desktop Framework Analysis (2026)](https://github.com/scottj/agent-research/tree/main/desktop-framework-analysis#readme) (2026-02-27 14:24)

Evaluating cross-platform desktop frameworks in 2026 reveals a maturing ecosystem with compelling choices for different developer backgrounds and deployment needs. Tauri v2 stands out for its tiny binaries, Rust-powered security, and new mobile support, making it ideal for web developers seeking performance and portability. Electron remains dominant due to its vast npm ecosystem despite its heavy resource use, while Qt continues to offer the most native look and best performance for traditional desktop apps, albeit with increased licensing complexity. For C# developers, Avalonia UI is now preferred over .NET MAUI for cross-platform reach, with MAUI retaining value for mobile-centric solutions. Choosing the right framework hinges on priorities like bundle size, native integration, target OSes, and licensing constraints.

**Key findings:**
- Tauri v2 and Neutralinojs deliver the smallest binaries; Tauri also supports mobile from a single codebase ([Tauri](https://tauri.app/)).
- Qt 6 and wxWidgets offer the most native UI and performance across platforms, but require familiarity with C++/Python and handle more complex licensing ([Qt](https://www.qt.io/)).
- Electron remains the web ecosystem giant at the cost of size and RAM.
- Avalonia UI is the top .NET option for cross-platform desktop, notably supporting Linux.
- Wails is optimal for Go developers seeking a modern web-based UI.
- No single framework is “best” for all cases; practical considerations around language, UI fidelity, and ecosystem should guide selection.

### [Analysis Report: chongdashu/cc-statusline](https://github.com/scottj/agent-research/tree/main/cc-statusline-analysis#readme) (2026-02-20 03:49)

Designed to enhance Claude Code’s terminal interface, `cc-statusline` is a CLI tool that generates a customizable bash statusline displaying real-time session data, git branch info, cost, token metrics, and optionally session reset timers. The tool installs via a simple command (`npx @chongdashu/cc-statusline@latest init`), guides users through feature selection, and writes a generated bash script to their `.claude/` directory, modifying settings minimally and responsibly. Its runtime behavior is secure: it parses JSON input from Claude Code using `jq` or bash tools, displays data without executing user input, and makes no network calls, ensuring low risk for personal use. Optional features, like session reset timers, require external dependencies (e.g., [`ccusage`](https://github.com/ryoppippi/ccusage)), but are opt-in and guarded against hangs. Open source and MIT-licensed, the project is actively maintained, with clear code structure and prompt bug fixes.

Key findings:
- No network access or elevated privileges required; writes scoped to `.claude/`
- Committed API key in dev config (`settings.local.json`) poses no user risk but highlights hygiene
- Optional logging can be disabled; log file contains only local session info
- Main dependency (`ccusage`) for reset timer is separate; most users won’t need it
- See the [GitHub repository](https://github.com/chongdashu/cc-statusline) for code and issues

### [C# GUI App Folder Structures: A Field Guide](https://github.com/scottj/agent-research/tree/main/csharp-gui-folder-structures#readme) (2026-02-19 00:20)

C# GUI application development today is defined by a mix of legacy MVVM patterns, modular architectures, and modern, feature-centric folder structures across frameworks like WPF, WinUI 3, .NET MAUI, and Avalonia UI. While classic layer-based MVVM is still widely used for its familiarity, contemporary projects increasingly favor feature folders, vertical slice architecture, or clean architecture for improved scalability, testability, and developer onboarding. Multi-project splits (core logic + UI) are now recommended by Microsoft and embraced in flagship apps like [Files](https://github.com/files-community/Files), while community favorites like [Avalonia](https://github.com/AvaloniaUI/Avalonia) are pioneering cross-platform design patterns. Generally, feature-focused organization and clean separation of concerns are seen as best practices, and pragmatic teams start simple, evolving their structure as the app grows.

**Key Findings:**
- Feature folders and vertical slices are gaining popularity for their clarity, cohesion, and scalability.
- Multi-project (Core + UI) architecture is the mainstream recommendation for cross-platform and testable apps.
- Prism module approach remains relevant for plugin-heavy enterprise applications but is rarely chosen for greenfield projects.
- Layer-centric MVVM, while still present, is considered dated for new development.
- Active community frameworks and tooling impose little structural opinion, placing architectural responsibility on developers.

<!--[[[end]]]-->

---

## Updating this README

This README uses [cogapp](https://nedbatchelder.com/code/cog/) to automatically generate project descriptions.

### Automatic updates

A GitHub Action automatically runs `cog -r -P README.md` on every push to main and commits any changes to the README or new `_summary.md` files.

### Manual updates

To update locally:

```bash
# Run cogapp to regenerate the project list
cog -r -P README.md
```

The script automatically:
- Discovers all subdirectories in this folder
- Gets the first commit date for each folder and sorts by most recent first
- For each folder, checks if a `_summary.md` file exists
- If the summary exists, it uses the cached version
- If not, it generates a new summary using `llm -m {MODEL}` with a prompt that creates engaging descriptions with bullets and links
- Creates markdown links to each project folder on GitHub
- New summaries are saved to `_summary.md` to avoid regenerating them on every run

To regenerate a specific project's description, delete its `_summary.md` file and run `cog -r -P README.md` again.
