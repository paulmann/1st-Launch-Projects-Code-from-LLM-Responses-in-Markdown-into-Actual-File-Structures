# MD_to_Files.sh — LLM Code Projector

[![Version](https://img.shields.io/badge/version-6.0.1-blue.svg)](https://github.com/paulmann/1st-Launch-Projects-Code-from-LLM-Responses-in-Markdown-into-Actual-File-Structures)
[![License: PolyForm Noncommercial](https://img.shields.io/badge/license-PolyForm%20Noncommercial%201.0.0-orange.svg)](LICENSE)
[![Shell: bash 4.0+](https://img.shields.io/badge/shell-bash%20%E2%89%A54.0-lightgrey.svg)](https://www.gnu.org/software/bash/)
[![Platform: Linux | macOS | WSL](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20WSL-lightgrey.svg)](#system-requirements)

**Turn an LLM answer into a working project in one command.** `MD_to_Files.sh` reads a Markdown response from ChatGPT, Claude, Gemini or DeepSeek and recreates every fenced code block as a real file, with its directories, inside the project folder you choose — instead of copying dozens of files by hand.

```bash
./MD_to_Files.sh chatgpt_response.md ./my-new-project
```

A single Bash script, no runtime dependencies, no package manager, no build step. It parses the response, resolves the target path for each code block, rejects unsafe paths, and writes the files with a summary you can check.

---

## 📑 Table of contents

- [Why this tool exists](#-why-this-tool-exists)
- [What it does](#-what-it-does)
- [System requirements](#system-requirements)
- [Quick start](#-quick-start)
- [How it works](#-how-it-works)
- [File marker formats](#-file-marker-formats)
- [Directory trees](#-directory-trees)
- [Command-line options](#-command-line-options)
- [Examples](#-examples)
- [Prompt template for LLMs](#-prompt-template-for-llms)
- [Integration](#-integration)
- [Troubleshooting](#-troubleshooting)
- [FAQ](#-faq)
- [Documentation](#-documentation)
- [Contributing](#-contributing)
- [License](#-license)
- [Contact](#-contact)

---

## 🎯 Why this tool exists

Ask any assistant for a project and you get a long Markdown answer: a directory tree, then a code block per file. The answer looks complete, but it is only text. Turning it into files means creating each folder, opening each block, pasting, saving under the right name — and repeating that for every file the model produced.

`MD_to_Files.sh` (also published as **LLM Code Projector**) automates exactly that step:

| Without the script | With the script |
|---|---|
| 20–50 manual copy-paste operations per project | one command |
| file names and nesting drift from the tree | paths come from the response itself |
| encoding surprises (`cp1252`, `latin-1`) | converted to UTF-8 automatically |
| `../../etc/passwd` style paths in model output | sanitized and rejected before writing |
| no record of what happened | per-file log, `--dry-run`, `--log` |

It is a **deterministic post-processor for LLM output**, not another code generator: the model still writes the code, the script only materialises it.

---

## ✨ What it does

- **Extracts fenced code blocks** with their language tag (` ```js `, ` ```python `, ` ```json ` …).
- **Resolves the target path** from one of three marker formats — see [File marker formats](#-file-marker-formats).
- **Creates nested directories** exactly as the paths require.
- **Sanitizes paths**: strips terminal escape codes and `< > : " | ? *`, removes leading `/` and `../` segments, collapses `//`, truncates names above 255 characters.
- **Normalises encoding**: `UTF-8` and ASCII pass through, `Windows-1252` / `ISO-8859-1` are converted with `iconv` when available.
- **Writes safely**: existing files are skipped unless `--force` is given; `--backup` keeps a `.bak.YYYYmmdd_HHMMSS` copy before overwriting.
- **Previews**: `--dry-run` prints every `mkdir` and every file it would write, and touches nothing.
- **Reports**: per-file status lines, a summary of files/directories/code blocks, optional log file.
- **Adds project metadata** with `--project`: a generated `README.md` (when none exists) and a `.llm-projector` file recording tool version, source file and generation date.

**Who it is for:** developers prototyping from an assistant's answer, DevOps engineers
generating project skeletons, technical writers turning documentation into runnable
examples, educators preparing course material, and teams that want a repeatable
starting point instead of ad-hoc copy-paste.

---

## System requirements

| Component | Requirement |
|---|---|
| **OS** | Linux 3.2+, macOS 10.12+, Windows through WSL / Cygwin / Git Bash, BSD |
| **Shell** | Bash 4.0 or newer (5.x recommended; macOS ships 3.2 — install a newer Bash) |
| **Core utilities** | `mkdir`, `find`, `grep`, `sed`, `cat`, `printf` |
| **Optional** | `file` (encoding detection), `iconv` (conversion), `readlink` (path resolution) |
| **Disk** | about 100 MB free for generated projects |

Check the environment in one line:

```bash
bash --version && for c in mkdir find grep sed file iconv; do
  command -v "$c" >/dev/null && echo "✓ $c" || echo "✗ $c"; done
```

---

## 🚀 Quick start

### 1. Install

```bash
git clone https://github.com/paulmann/1st-Launch-Projects-Code-from-LLM-Responses-in-Markdown-into-Actual-File-Structures.git
cd 1st-Launch-Projects-Code-from-LLM-Responses-in-Markdown-into-Actual-File-Structures
chmod +x MD_to_Files.sh
./MD_to_Files.sh --version
```

No clone? Fetch the script directly:

```bash
curl -L -o ~/bin/md2files \
  https://raw.githubusercontent.com/paulmann/1st-Launch-Projects-Code-from-LLM-Responses-in-Markdown-into-Actual-File-Structures/main/MD_to_Files.sh
chmod +x ~/bin/md2files
```

Optional shell alias:

```bash
echo 'alias md2files="$HOME/bin/md2files"' >> ~/.bashrc
source ~/.bashrc
```

### 2. Save an LLM answer as Markdown

````markdown
# Greeting CLI

## Implementation

```javascript
// [file name]: src/index.js
const name = process.argv[2] ?? 'world';
console.log(`Hello, ${name}!`);
```

```json
// [file name]: package.json
{
  "name": "greeting-cli",
  "version": "1.0.0"
}
```
````

### 3. Run it

```bash
./MD_to_Files.sh greeting.md ./greeting-cli
```

Real output (v6.0.1):

```
ℹ️  INFO Input: greeting.md
ℹ️  INFO Target: ./greeting-cli
⏳ PROGRESS Extracting code blocks from markdown...
✅ OK Extracted 2 code block(s)

=== Creating Project Structure from Code Blocks ===
Files to create:
  package.json
  src/index.js

⏳ PROGRESS Creating project structure from code blocks...
ℹ️  INFO Created directory: ./greeting-cli/src
✅ OK Created with content: ./greeting-cli/package.json (50 bytes)
✅ OK Created with content: ./greeting-cli/src/index.js (72 bytes)
✅ OK Structure from code blocks completed:
ℹ️  INFO  Directories: 1 | Files: 2
✅ OK Project structure created successfully

=== SUMMARY ===
✅ OK Created: 2 files, 1 directories
ℹ️  INFO Code blocks: 2 extracted, 2 applied
✨ Project successfully created/updated!
```

The exit code is `0` on success and `1` when no code blocks with a resolvable file path were found.

---

## ⚙️ How it works

1. **Read** the Markdown file line by line (encoding normalised first).
2. **Open/close fences** on every ```` ``` ```` line, remembering the language tag.
3. **Resolve the target path** inside each block — the marker line is consumed and never written to the file.
4. **Sanitize** the path and skip anything that tries to leave the target directory.
5. **Create directories, then files**, printing one line per artefact and a final summary. `--dry-run` stops after step 4.

The directory tree inside the response is **not** used to build folders — see the next two sections for why that matters.

---

## 🏷️ File marker formats

The script recognises three ways to say which file a code block belongs to.

### 1. Comment marker inside the block (recommended)

```javascript
// [file name]: src/app.js
console.log('hello');
```

Also accepted with `#`, `--` and `REM` prefixes, for Python, SQL/Lua and batch examples:

```python
# [file name]: app/main.py
print('hello')
```

### 2. Bare path on the first line of the block

```
src/app.js
console.log('hello');
```

### 3. Heading with the path, directly above the block

````markdown
## src/app.js

```javascript
console.log('hello');
```
````

### What is *not* recognised

**Bold-only markers are not parsed.** Earlier versions of this README recommended `**src/app.js**` above a block; the parser never had a rule for it, so such blocks are ignored and the run ends with `No code blocks found`. Use one of the three formats above.

When several blocks target the same path, the last one wins.

---

## 🌳 Directory trees

A tree is still useful documentation for the human reading the response, and harmless for the script:

```
greeting-cli/
├── src/
│   └── index.js
└── package.json
```

Since v6.0.1 the script **builds the structure from the file paths in the code blocks** and ignores the tree section. This is deliberate: LLM trees frequently disagree with the code that follows (renamed files, extra folders), and creating both produced empty directories nobody asked for. Keep the tree for readability — the folders will be created from the paths.

---

## 💻 Command-line options

```bash
./MD_to_Files.sh [OPTIONS] INPUT_FILE [TARGET_DIR]
```

`TARGET_DIR` defaults to the current directory and is created if missing.

| Option | Long form | Effect |
|---|---|---|
| `-h` | `--help` | Show help |
| `-V` | `--version` | Show version, author, license, Bash version |
| `-v` | `--verbose` | Debug output for every parsed line and resolved path |
| `-d` | `--dry-run` | Print planned `mkdir`/file writes, change nothing |
| `-f` | `--force` | Overwrite existing files instead of skipping them |
| `-b` | `--backup` | Keep `.bak.YYYYmmdd_HHMMSS` before overwriting |
| `-l FILE` | `--log FILE` | Append a detailed log to `FILE` |
| `-U` | `--update` | Update existing files whose content differs |
| `-P` | `--project` | Also generate `README.md` and `.llm-projector` metadata |
| `-C` | `--no-code` | Skip code extraction (kept for compatibility, see below) |
| `-a` | `--all` | Reserved, no effect in 6.0.x |
| `-i` | `--interactive` | Reserved, no effect in 6.0.x |

**Notes on the last three.** `--no-code` disables the only source of file paths, so a run with `-C` ends with `No code blocks found`; it stays in the CLI for backwards compatibility. `--all` and `--interactive` were meaningful when the tool still parsed several trees per document; in 6.0.x one document produces one set of files and both flags are accepted but ignored.

Common combinations:

```bash
# Preview a risky update
./MD_to_Files.sh -d -v response.md ./project

# Update with backups and a log
./MD_to_Files.sh -U -b -l update.log response.md ./project

# Create with metadata, overwriting generated files
./MD_to_Files.sh -P -f response.md ./project
```

---

## 🎬 Examples

### Node.js CLI (verified output)

Input and output are shown in [Quick start](#-quick-start).

### React application

````markdown
# React Application

## src/index.js

```javascript
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
```

## src/App.js

```javascript
export default function App() {
  return <h1>Hello from React</h1>;
}
```

## package.json

```json
{
  "name": "react-app",
  "version": "1.0.0",
  "dependencies": { "react": "^18.2.0", "react-dom": "^18.2.0" }
}
```
````

```bash
./MD_to_Files.sh -P react_app.md ./my-react-app
cd my-react-app && npm install && npm start
```

### Python course, several documents

```bash
./MD_to_Files.sh lesson-1.md ./course-materials
./MD_to_Files.sh lesson-2.md ./course-materials
```

Each run only adds what its own document contains; existing files are left untouched without `--force`.

### Updating an existing project

```bash
# Files that differ get the new content, identical ones are reported as skipped
./MD_to_Files.sh -U -b response-v2.md ./existing-project
```

---

## 🤖 Prompt template for LLMs

Paste this into the request so the answer is parseable on the first try:

````text
Format the answer so MD_to_Files.sh can turn it into files:

1. Start with "# <Project name>" and a one-paragraph description.
2. Add a "## Project structure" section with a tree in a ``` fence (for humans).
3. For every file, add a heading with its full relative path, then one fenced code block:

## path/to/file.ext

```<language>
<complete file content>
```

Rules:
- every path is relative to the project root, no leading slash;
- use the same path in the heading and in the tree;
- one code block per file, complete content, no placeholders;
- include configuration files (package.json, .env.example, .gitignore).
````

What to avoid:

1. **Bold-only markers** (`**src/app.js**`) — not recognised.
2. **Several files in one block** — only one path can be attached to a block.
3. **Elided content** (`// ... rest of the file`) — the script writes exactly what the model produced.
4. **Paths with `..`** — stripped by the sanitizer.
5. **Non-UTF-8 output** — readable, but only `cp1252`/`latin-1` are converted automatically.

---

## 🔗 Integration

### Git pre-commit validation

```bash
#!/usr/bin/env bash
# .git/hooks/pre-commit — reject Markdown that cannot be materialised
set -e
for md in $(git diff --cached --name-only --diff-filter=ACM | grep '\.md$' || true); do
    ./MD_to_Files.sh -d "$md" /tmp/md2files-check >/dev/null || {
        echo "❌ $md has no parsable code blocks"; exit 1; }
done
```

### GitHub Actions

```yaml
name: Generate project from Markdown

on:
  push:
    paths: ['docs/project-structure.md']

jobs:
  generate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Generate
        run: |
          chmod +x ./MD_to_Files.sh
          ./MD_to_Files.sh -P docs/project-structure.md ./generated
      - name: Commit
        run: |
          git config user.name  "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add generated/
          git commit -m "chore: regenerate from Markdown" || true
          git push
```

### VS Code task

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Generate files from Markdown",
      "type": "shell",
      "command": "${workspaceFolder}/MD_to_Files.sh",
      "args": ["${file}", "${workspaceFolder}/generated"],
      "presentation": { "reveal": "always" }
    }
  ]
}
```

---

## 🔧 Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `No code blocks found - cannot create project structure` | no fence carries a resolvable path, or only bold markers were used | add `// [file name]: path`, a bare path line, or a `## path` heading |
| `File exists, skipping: …` | target already has the file | `--force`, optionally with `--backup` |
| Garbled non-Latin text | input was not UTF-8 and not `cp1252`/`latin-1` | convert first: `iconv -f cp1251 -t utf-8 in.md > out.md` |
| `Bash 4.0+ required` | macOS ships Bash 3.2 | `brew install bash`, then use that binary |
| `--dry-run` created nothing (expected) | dry-run never writes | run without `-d` |
| Empty file in the output | the block had a marker but no content | check the fence in the source Markdown |

Diagnostics:

```bash
./MD_to_Files.sh -d -v -l debug.log response.md ./preview
grep -E "ERROR|WARN" debug.log
```

---

## ❓ FAQ

<details>
<summary><b>Does it work with ChatGPT, Claude, Gemini and DeepSeek output?</b></summary>

Yes. Any Markdown file with fenced code blocks works, regardless of which assistant produced it. The parser also understands DeepSeek's habit of putting the bare path on the first line of the block.
</details>

<details>
<summary><b>Can it update a project that already exists?</b></summary>

Yes — `-U` rewrites only the files whose content differs, `-b` keeps a timestamped backup of each file it touches, and `-d` shows the plan first.
</details>

<details>
<summary><b>Does it need Node.js, Python or any runtime?</b></summary>

No. It is a Bash script using coreutils, `grep`, `sed` and, when available, `file`, `iconv` and `readlink`.
</details>

<details>
<summary><b>Why are directories missing from my tree in the output?</b></summary>

Since 6.0.1 the tree is documentation only; folders come from the file paths in the code blocks. A folder that contains no file is not created.
</details>

<details>
<summary><b>Is it safe to run on untrusted model output?</b></summary>

Paths are sanitized: control characters, `< > : " | ? *`, leading `/` and `../` segments are removed, and files are written only inside `TARGET_DIR`. Use `--dry-run` first if you want to see the plan.
</details>

<details>
<summary><b>Does it run on Windows?</b></summary>

Through WSL, Cygwin or Git Bash. Native `cmd.exe`/PowerShell are not supported.
</details>

<details>
<summary><b>What license applies?</b></summary>

PolyForm Noncommercial License 1.0.0 — free for noncommercial use, commercial use requires a separate license. See [LICENSE](LICENSE).
</details>

---

## 📚 Documentation

| Document | What is inside |
|---|---|
| [docs/INDEX.md](docs/INDEX.md) | Map of the documentation set and reading paths |
| [docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md) | One-page cheat sheet: marker syntax, checklist, common mistakes |
| [docs/PROMPT_TEMPLATES.md](docs/PROMPT_TEMPLATES.md) | Copy-paste prompts for Python, JavaScript, full-stack and Docker projects |
| [docs/PROMPT_GUIDE.md](docs/PROMPT_GUIDE.md) | Full reference on prompt formatting and validation |
| [docs/EXAMPLES.md](docs/EXAMPLES.md) | Worked examples from request to generated project |
| [docs/RUSSIAN_QUICK_START.md](docs/RUSSIAN_QUICK_START.md) | Краткая инструкция на русском |
| [docs/PROMPTS.txt](docs/PROMPTS.txt) | The same prompts as plain text |
| [docs/MANIFEST.md](docs/MANIFEST.md) | Description of the documentation package |
| [CHANGELOG.md](CHANGELOG.md) | Version history |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to propose a change |
| [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) | Community rules |

---

## 🤝 Contributing

Bug reports, prompt-format edge cases and pull requests are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md). Useful reports include the input Markdown (or a minimal fragment), the command line, and the output of `--dry-run -v`.

---

## 📄 License

**PolyForm Noncommercial License 1.0.0.** Noncommercial use, modification and distribution are permitted under the terms in [LICENSE](LICENSE). Commercial use requires a separate license from the author.

Copyright (c) 2025–2026 Mikhail Deynekin.

---

## 📞 Contact

**Author:** Mikhail Deynekin

- 🌐 Website: [deynekin.com](https://deynekin.com)
- 📧 Email: [mid1977@gmail.com](mailto:mid1977@gmail.com)
- 💼 LinkedIn: [linkedin.com/in/mikhail-deynekin](https://linkedin.com/in/mikhail-deynekin)

**Project:**

- 🐙 Repository: [1st-Launch-Projects-Code-from-LLM-Responses-in-Markdown-into-Actual-File-Structures](https://github.com/paulmann/1st-Launch-Projects-Code-from-LLM-Responses-in-Markdown-into-Actual-File-Structures)
- 🐛 Issues: [report a problem](https://github.com/paulmann/1st-Launch-Projects-Code-from-LLM-Responses-in-Markdown-into-Actual-File-Structures/issues)

<div align="center">

**[⬆ Back to top](#md_to_filessh--llm-code-projector)**

Made for people who are tired of copy-pasting code out of chat windows.

</div>
