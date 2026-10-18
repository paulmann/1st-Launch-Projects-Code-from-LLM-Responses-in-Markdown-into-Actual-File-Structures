# Changelog

All notable changes to `MD_to_Files.sh` are documented here.
The version follows `SCRIPT_VERSION` inside the script:

```bash
./MD_to_Files.sh --version
```

Earlier releases were tracked only in the commit history.

## [Unreleased]

### Fixed

- **CLI options were silently ignored.** `parse_arguments` was called inside a command
  substitution, so it ran in a subshell and every flag it set was lost. `--dry-run`
  still wrote files, `--force`, `--backup`, `--update`, `--project`, `--log` and
  `--verbose` had no effect. Parsing now happens in the current shell.
- **File markers dropped code.** With `// [file name]: path` the first line of the
  block was discarded; with a bare path on the first line, the first two lines were.
  Blocks smaller than that produced no file at all. Content is now written verbatim
  after the marker line.
- **`--dry-run` created the target directory.** It now touches nothing on disk.
- **`--help` reported a hardcoded v5.1.9** instead of the real version.

### Changed

- License references inside the script (`header`, `--version`) now say
  PolyForm Noncommercial 1.0.0, matching the `LICENSE` file.
- `README.md` rewritten: documented marker formats match the parser, the option table
  matches the CLI, broken links removed, FAQ added.

## [6.0.1] — 2025-10-31

- Project structure is built from the file paths of code blocks; the directory tree
  in the response is no longer parsed (`find_tree_structures` remains as a
  compatibility stub).
- `--all` and `--interactive` are accepted but have no effect: one document produces
  one set of files.
- Encoding normalisation for `Windows-1252` / `ISO-8859-1` via `iconv` when available.
- `--project` writes `.llm-projector` metadata and a `README.md` when the target has none.

## [5.1.8] — 2025-10-31

- Version badge and README updates for the 5.1.x line.

## [5.1.3] — 2025-10-30

- Prompt-format documentation set (`docs/`) published with the script.
