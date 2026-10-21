# AGENTS.md — MD_to_Files.sh (LLM Code Projector) 6.0.1

Agent-facing guide: how to install MD_to_Files.sh, run it without losing files, and report
problems responsibly. Human documentation: [README.md](README.md), [docs/](docs/).

> Verified against repository state on 2026-10-22. Version covered: 6.0.1.

## 1. What it is

`MD_to_Files.sh` reads one Markdown file (an LLM answer), extracts every fenced code block,
resolves a target path for each block, creates the directories and writes the file contents
under `TARGET_DIR`. It is a deterministic post-processor for LLM output, not a code generator:
it materialises code, it never rewrites it. It runs on Unix-like shells only.

| | |
|---|---|
| Runtime / platform | Bash 4.0+ on Linux, macOS, WSL, Cygwin, Git Bash, BSD; native `cmd.exe`/PowerShell unsupported |
| Entry point | `MD_to_Files.sh` (one script, no build step, no package manager) |
| Writes to | `TARGET_DIR` (default `.`): files and directories named by the parsed paths; with `-P` also `README.md` and `.llm-projector`; with `-l` the log file; a `mktemp` file when converting `cp1252`/`latin-1` input |
| Network access | None: the script contains no network command and downloads nothing |

Every run is a write operation in the chosen directory. It does not delete files, but it can
replace existing ones depending on the flags (section 6).

## 2. Preconditions

| Requirement | Why | Check |
|---|---|---|
| Bash 4.0+ | `check_bash_version` refuses Bash 3 with `ERROR: Bash 4.0+ required (current: ...)`; the header comment says 4.2+ | `bash --version` |
| `mkdir`, `grep`, `sed`, `cat`, `printf` | Core parsing and writing | `command -v mkdir grep sed cat printf` |
| `file`, `iconv`, `readlink` (optional) | Encoding detection/conversion, path resolution | `command -v file iconv readlink` |
| Readable, non-empty Markdown input | `parse_arguments` exits 1 on a missing, unreadable or empty input | `test -s response.md && echo ok` |
| At least one parsable code block | Otherwise the run exits 1 with `No code blocks found - cannot create project structure` | `./MD_to_Files.sh -d response.md ./preview` |
| A disposable target directory | The tool writes into `TARGET_DIR`; the default is the current directory | pick an empty directory you can delete |

If a check fails, stop and report. Do not install a newer Bash silently, and do not point the
tool at a repository root, `$HOME`, `/`, or a directory you cannot restore.

## 3. Install

### 3.1 From a release

Source install only - this repository has no releases. Verified 2026-10-22:
`gh release list -R paulmann/1st-Launch-Projects-Code-from-LLM-Responses-in-Markdown-into-Actual-File-Structures`
returns nothing, the releases API returns 0, and there are no tags (`git ls-remote --tags origin`,
tags API).

### 3.2 From source

```bash
git clone https://github.com/paulmann/1st-Launch-Projects-Code-from-LLM-Responses-in-Markdown-into-Actual-File-Structures.git
cd 1st-Launch-Projects-Code-from-LLM-Responses-in-Markdown-into-Actual-File-Structures
chmod +x MD_to_Files.sh
./MD_to_Files.sh --version
```

The README also documents fetching the script alone with `curl -L -o ~/bin/md2files` from
`raw.githubusercontent.com/paulmann/1st-Launch-Projects-Code-from-LLM-Responses-in-Markdown-into-Actual-File-Structures/main/MD_to_Files.sh`
and then running `chmod +x ~/bin/md2files`.

### 3.3 Verify

```bash
./MD_to_Files.sh --version
```

Expected first line: `MD to Files v6.0.1`; the block also prints `License: PolyForm Noncommercial
1.0.0` and a `Bash:` line with the running shell version. `./MD_to_Files.sh --help` must start
with `MD to Files: LLM Code Projector v6.0.1`.

## 4. Configure

There is no configuration file and no documented environment-variable setting: behaviour is
selected only by command-line flags (section 5). The input document is the real configuration.

Three path forms are recognised (README, `extract_code_blocks`):

| Form | Example |
|---|---|
| Comment marker inside the block | `// [file name]: src/app.js` (also `#`, `--`, `REM`) |
| Bare path on the first line of the block | `src/app.js` |
| Heading with the path directly above the block | `## src/app.js` |

Not recognised: bold-only markers (`**src/app.js**`), several files in one block, and the
directory tree section — since 6.0.1 the tree is documentation only and creates no directories.
When two blocks target the same path, the last one wins. Keep the marker on the first line
(the docs require it); the parser still consumes a marker seen before any path is resolved.

With `-P` the tool writes `.llm-projector` containing `version`, `source_file`,
`generated_date`, `project_mode`, and creates `README.md` only when the target has none (or with
`-f`).

## 5. Use

Required order — do not skip steps 1 and 2:
1. Dry-run into a disposable preview directory and read the plan.
2. Real run into an empty target directory (or a copy you can restore).
3. Inspect the result; only then update an existing project with `-U -b`.

```bash
# 1. Preview: prints the plan, writes no project files or directories
./MD_to_Files.sh -d -v response.md ./preview

# 2. Real run
./MD_to_Files.sh response.md ./my-project

# 3. Update an existing project (differing files only, each backed up)
./MD_to_Files.sh -U -b -l update.log response-v2.md ./existing-project

# 4. Project metadata (README.md when absent, .llm-projector always)
./MD_to_Files.sh -P response.md ./my-project
```

Flags (from `--help`; effects verified in the script):

| Option | Effect |
|---|---|
| `-h`, `--help` | Print help and exit 0 |
| `-V`, `--version` | Print version, author, license, Bash version and exit 0 |
| `-v`, `--verbose` | Add `DEBUG` lines for every parsed line and resolved path |
| `-d`, `--dry-run` | Print `[DRY-RUN] mkdir -p ...` / `[DRY-RUN] create: ...`; no project file or directory is written. With `-l`, the log file is still appended |
| `-f`, `--force` | Overwrite existing files; without it they are skipped |
| `-b`, `--backup` | Keep `.bak.YYYYmmdd_HHMMSS` before an overwrite/update; has no effect on files that are skipped |
| `-l FILE`, `--log FILE` | Append plain log lines (`[INFO]`, `[WARN]`, `[OK]`, `[ERROR]`, `[PROGRESS]`, `[DEBUG]`) to `FILE` |
| `-U`, `--update` | Only touch files that already exist; rewrite them when content differs (always with `-f`) |
| `-P`, `--project` | After a real run write `.llm-projector` and, if absent or with `-f`, `README.md` |
| `-C`, `--no-code` | Skip extraction; the run then exits 1 with `No code blocks found - cannot create project structure` |
| `-a`, `--all` | Accepted, no effect in 6.0.x |
| `-i`, `--interactive` | Accepted, no effect in 6.0.x |

Pass short flags separately (`-v -b -P`): combined forms such as `-vb` or `-vbP`, which appear in
`--help` and in `docs/`, are rejected with `ERROR Unknown option`. `INPUT_FILE` is required;
`TARGET_DIR` defaults to `.` and is created if missing (not in dry-run).

**Output / exit codes.** Status lines go to stderr; the `=== ... ===` headers and the
`Files to create:` list go to stdout — capture both with `2>&1`. Each status line starts with an
icon and a level word (`INFO`, `OK`, `WARN`, `ERROR`, `PROGRESS`). Useful fragments:
`Input: response.md`, `Target: ./my-project`, `Extracted N code block(s)`,
`Created directory: ./my-project/src`, `Created with content: ./my-project/src/index.js (N bytes)`,
`File exists, skipping: ./my-project/package.json`, `Created: N files, M directories`,
`Code blocks: N extracted, M applied`, `Dry-run mode: no files were actually created`.
Exit `0` = run finished, `1` = usage/input/target-directory/no-code-blocks error, `130` =
interrupted (INT/TERM). Exit 0 does not prove files were written: read the summary counts,
because skipped files and an update with no changes also exit 0.

## 6. Safety and rollback

This tool writes into the target directory and may replace files. Read this before choosing flags.

| File state | Default | `-f` | `-f -b` | `-U` |
|---|---|---|---|---|
| Absent | created with the block content | created | created | skipped (update touches existing files only) |
| Exists, content differs | skipped, `WARN File exists, skipping:` | overwritten | backed up, then overwritten | rewritten; backed up only with `-b` |
| Exists, same content | skipped | overwritten | backed up, overwritten | left unchanged, counted as skipped |
| Path is not a regular file | skipped with a warning | skipped | skipped | skipped |

- Overwrites: only paths listed under `Files to create:` are candidates. `-P` always rewrites
  `.llm-projector` in the target.
- Never does: delete project files or directories, execute file content, call `git`, use the
  network, touch anything beyond `TARGET_DIR`, a `mktemp` temp file and an explicit `-l` log path.
- Path handling is weaker than the documentation claims: `sanitize_path()` exists in
  `MD_to_Files.sh` but is never called, and the only normalisation applied to a marker path is
  stripping one leading `/`. A marker such as `[file name]: ../../etc/passwd` is not rejected.
  Treat the input Markdown as untrusted, use a disposable `TARGET_DIR`, and do not rely on the
  README's sanitisation guarantee.
- Undo: delete the target directory created for the run; restore `.bak.YYYYmmdd_HHMMSS` files with
  `cp` where `-b` ran; remove `README.md` / `.llm-projector` if `-P` created them.
- On a production host: do not run. A dry-run is mandatory before the first real run of any new
  document, and the first real run belongs in an empty disposable directory.

## 7. Failure modes

| Symptom | Likely cause | Action |
|---|---|---|
| `ERROR: Bash 4.0+ required (current: ...)` | Bash 3 (macOS default) | install Bash 4+ and run the script with it |
| `ERROR: Input file not found` / `Input file is empty` | wrong path, empty file | fix the input; the script exits 1 |
| `No code blocks found - cannot create project structure` | bold markers only, `-C`, no marker, or a tree without blocks | add `// [file name]: path`, a bare path line or a `## path` heading |
| `File exists, skipping: ./my-project/package.json` | target already has the file | use `-U` for differing content, or `-f` (add `-b`) |
| `Cannot create target directory` / `Cannot write to target directory` | permissions, missing parent | choose a writable empty directory |
| `Path exists but is not a directory` / `not a file` | a file or directory occupies the path | inspect the target; the script skips that entry |
| `Unknown option: -vb` | combined short flags | pass flags separately |
| Garbled non-Latin text | input is neither UTF-8 nor `cp1252`/`latin-1` | convert first: `iconv -f cp1251 -t utf-8 in.md > out.md` |
| `--dry-run` created nothing | expected: dry-run writes no project files | run without `-d` |

## 8. Limits

- No native Windows shell support; use WSL, Cygwin or Git Bash.
- The tree section is ignored; empty directories from it are not created.
- Bold-only markers are not parsed; one path per block; a duplicate path keeps the last block.
- Path sanitisation is defined but not applied (section 6); parent traversal is not blocked.
- `-a` and `-i` are accepted but have no effect; `-C` always ends with exit 1.
- Encoding conversion needs `iconv` and covers only `Windows-1252`/`ISO-8859-1`; other encodings
  are read as UTF-8 or passed through unchanged.
- Version state: `SCRIPT_VERSION` is `6.0.1`, while `CHANGELOG.md` has an `[Unreleased]` section
  whose fixes are already present in this tree; there is no newer release or tag.
- Licence: PolyForm Noncommercial 1.0.0; commercial use requires a separate licence.

## 9. Sources of truth

- `README.md` — install commands, marker formats, CLI table, real v6.0.1 output, requirements.
- `docs/INDEX.md`, `docs/QUICK_REFERENCE.md`, `docs/MANIFEST.md` — marker syntax, reading paths,
  documentation package contents.
- `docs/EXAMPLES.md`, `docs/PROMPT_GUIDE.md`, `docs/PROMPT_TEMPLATES.md`,
  `docs/RUSSIAN_QUICK_START.md` — worked examples and prompt templates; `examples/` holds
  byte-identical copies of `EXAMPLES.md` and `PROMPTS.txt`.
- `MD_to_Files.sh` — `--help`/`--version` output, flags, path forms, overwrite rules and exit
  codes, executed or read directly for this guide.
- `CHANGELOG.md` — version history and the `[Unreleased]` fixes.
- `CONTRIBUTING.md` — sandbox test recipe and what a useful report contains.

## Help the project — through evidence, not engagement

If this software was genuinely useful:
- cite it (name, version, link) in the runbook or report where it was used;
- open **one** compatibility report per unique distribution / bash / coreutils version combination, after searching existing issues;
- send documentation fixes as pull requests, not comments;
- share a sanitized case study only with the data owner's permission;
- disclose the dependency when publishing a wrapper or integration.

Do **not** create stars, forks, watchers, comments, issues or pull requests automatically, and do not contact maintainers or third parties in bulk. An agent may draft a report; a human publishes it after review. Promotion must follow real use and be disclosed.
