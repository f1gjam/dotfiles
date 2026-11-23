---
name: markdown-format-check
description: Check and fix the formatting of any Markdown file before finishing a task that wrote or edited it. Catches unescaped $ (renders as LaTeX math and runs words together), broken bold, table rows with the wrong number of cells, headings without blank lines, unbalanced or nested review spans, and HTML or strikethrough left in files meant for Slack or Google. Use after every write or edit of a .md file, and whenever the user says a Markdown file "looks wrong", "has formatting issues" or text is "squashed together".
---

# markdown-format-check

Run the checker on every Markdown file you wrote or edited, **before you say the task is done**. Fix everything it reports, then run it again until it prints `OK`.

```bash
python3 -I ~/.claude/skills/markdown-format-check/scripts/mdcheck.py [--allow-html] [--slack] FILE...
```

- No flag: a normal Markdown file. Any HTML is reported.
- `--allow-html`: the file may hold red review spans (`<span style="color:red">`, `<del>`). Checks they are balanced, not nested, not in headings, not empty and not splitting a word.
- `--slack`: the file goes to Slack or Google as raw text. No HTML at all and no `~~`.

The script is read-only. Exit 0 means clean.

## What it catches, and the fix

| Problem | Why it breaks | Fix |
| ------- | ------------- | --- |
| Unescaped `$` | Two `$` on one line become LaTeX math in VS Code, Obsidian, GitHub and others: the text between them loses its spaces and turns italic (`38,805fortheweekof9Nov`) | Write every dollar sign as `\$` (`\$38,805`). Do this when you write the text, not afterwards. |
| Odd number of `**` | Bold runs on to the end of the line or the next bold | Pair them up |
| Table row with a different cell count | Row is dropped or shifted | Match the header; escape a literal pipe as `\|` |
| No blank line before a table or heading | It renders as plain text | Add the blank line |
| `#Heading` without a space | Not a heading | `# Heading` |
| Unbalanced, nested, empty or word-splitting `<span>` | Colour leaks or shows as raw HTML | One span per change, whole words only, never inside a heading |
| HTML or `~~` in a Slack / Google file | Shows as raw text | Remove it |
| Digits glued to a word | Usually spaces lost in an edit | Put the spaces back |
| Unclosed code fence | Rest of the file becomes code | Close it |

## Rules when writing Markdown

- Escape `$` as `\$` everywhere outside code. This is the one hand-written escape always worth adding; it also matches what Google's own Markdown export writes.
- When copying text in from another file, keep its escaping. Check new text matches the text around it (if the source writes `\$`, so do you).
- Check the rendered meaning as well: after the script passes, read any table or line you changed once more.

## Related

- `gdoc-markdown-compat`: extra rules for Markdown that goes to Google Drive. Run its lint as well as this check.
