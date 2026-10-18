# Contributing to MD_to_Files.sh

Thanks for taking the time to improve the tool. This page describes the shortest
path from an idea to a merged change.

## Reporting a bug

A useful report contains three things:

1. **Input** — the Markdown fragment that reproduces the problem (redact anything private).
2. **Command** — the exact line you ran, for example
   `./MD_to_Files.sh -d -v response.md ./out`.
3. **Output** — the console output, plus `debug.log` when you used `-l debug.log`.

If the file layout is wrong rather than missing, say what you expected and what you got.

## Proposing a change

1. Open an issue describing the behaviour you want, or comment on an existing one.
2. Fork the repository and create a branch: `git checkout -b fix/marker-parsing`.
3. Make the change small and single-purpose — one topic per pull request.
4. Test it (see below) and describe the test in the pull request.
5. Open the pull request against `main`.

## Testing locally

The script has no test framework; verification is a sandbox run with a document that
covers the marker format you touched:

````bash
mkdir -p /tmp/md2files-sandbox && cd /tmp/md2files-sandbox
cp /path/to/MD_to_Files.sh .

cat > case.md <<'EOF'
# Case

## src/app.js

```javascript
line1
line2
```
EOF

./MD_to_Files.sh -d case.md ./out      # plan only
./MD_to_Files.sh    case.md ./out      # real run
cat out/src/app.js                     # content must be complete: line1 and line2
````

Check at least:

- `--dry-run` creates no files and no directories;
- every line of every code block appears in the generated file;
- `--version` and `--help` report the version from `SCRIPT_VERSION`;
- the run exits `0` on success and `1` when nothing parsable is found.

## Code style

- Target **Bash 4.0+**; the script starts with `set -euo pipefail`.
- Keep the existing function layout (`log_*`, `parse_*`, `create_*`) and quote every expansion.
- Run `shellcheck MD_to_Files.sh` before opening the pull request. The repository has
  six known findings (`SC2034` on reserved flags, `SC2155`, `SC2046`); do not add new ones.
- Comments explain *why*, not *what* — the code already says what it does.
- Documentation changes belong in `docs/` and `README.md`; keep both consistent with the parser.

## Commits

- One logical change per commit, message in the imperative mood
  (`fix: keep the first code line after a file marker`).
- Sign the commit with your own identity; do not commit as a bot or on behalf of someone else.
- Never commit secrets, tokens or personal data — the repository is public.
