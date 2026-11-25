# markdown-format-check

Checks a Markdown file for formatting mistakes that make it display wrongly, so they are fixed before a task is called done.

## What it does

Runs `scripts/mdcheck.py` on one or more `.md` files and lists each problem as `file:line: problem`. It catches:

- unescaped `$`, which many viewers render as LaTeX math (the words between two `$` run together)
- unpaired `**`
- table rows whose cell count differs from the header, and tables without a blank line before them
- headings without a space after `#` or without a blank line before them
- red review spans that are unbalanced, nested, empty, inside a heading or splitting a word (`--allow-html`)
- any HTML or `~~` in files meant for Slack or Google (`--slack`)
- digits glued to a word, and unclosed code fences

## Needs

Python 3 (`python3 --version`), which comes with macOS and Homebrew. No packages to install: the script uses only the standard library.

## How to run

```bash
python3 -I ~/.claude/skills/markdown-format-check/scripts/mdcheck.py [--allow-html] [--slack] FILE...
```

Claude runs it after writing or editing any Markdown file (see `~/.claude/CLAUDE.md`). You can also ask "check the markdown formatting".

## Inputs and outputs

- Input: paths to Markdown files.
- Output: a list of problems on stdout, then `OK` or a count. Exit code 0 if clean, 1 if not.

## Writes anywhere?

No. The script is read-only. Claude fixes the reported problems in the file itself as a separate step.
