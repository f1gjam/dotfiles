#!/usr/bin/env python3
"""Markdown format check: catches mistakes that make a .md file display wrongly.

Usage:
    python3 -I mdcheck.py [--allow-html] [--slack] FILE [FILE ...]

Options:
    --allow-html  The file may contain red review spans (<span style="color:red">,
                  <del>). Checks those spans are balanced, not nested, not inside
                  headings, not empty and not splitting a word.
    --slack       The file is going to Slack or Google as plain text: no HTML at all
                  and no ~~strikethrough~~.

Read-only. Prints file:line: problem, then the line. Exit 0 if clean, 1 otherwise.
Code spans, fenced code blocks and YAML front matter are skipped.
"""
import re
import sys

args = sys.argv[1:]
allow_html = "--allow-html" in args
slack = "--slack" in args
files = [a for a in args if not a.startswith("--")]
if not files:
    sys.exit(__doc__)

bad = 0


def report(path, n, msg, line):
    global bad
    bad += 1
    print(f"{path}:{n}: {msg}\n    {line.strip()[:140]}")


for path in files:
    lines = open(path, encoding="utf-8").read().split("\n")
    in_fence = False
    table_cols = None
    prev = ""
    # skip YAML front matter (e.g. SKILL.md headers); it is not rendered
    front_end = 0
    if lines and lines[0].strip() == "---":
        for j in range(1, len(lines)):
            if lines[j].strip() == "---":
                front_end = j + 1
                break
    for n, line in enumerate(lines, 1):
        if n <= front_end:
            continue
        if line.lstrip().startswith("```"):
            in_fence = not in_fence
            prev = line
            continue
        if in_fence:
            prev = line
            continue
        bare = re.sub(r"`[^`]*`", "", line)  # ignore inline code

        # 1. Unescaped $: two of them on a line become LaTeX math in many
        #    viewers (VS Code, Obsidian, GitHub), which drops the spaces
        #    ("$38,805 for the week of 9 Nov ... $167K" -> "38,805fortheweekof9Nov").
        if re.search(r"(?<!\\)\$", bare):
            report(path, n, "unescaped $ (write \\$)", line)

        # 2. HTML
        tags = re.findall(r"</?([a-zA-Z]+)[^>]*>", bare)
        if tags and (slack or not allow_html):
            report(path, n, "raw HTML: " + ",".join(sorted(set(tags))), line)
        if allow_html:
            if bare.count("<span") != bare.count("</span>"):
                report(path, n, "unbalanced <span>", line)
            if bare.count("<del>") != bare.count("</del>"):
                report(path, n, "unbalanced <del>", line)
            if re.search(r"<span[^>]*>(?:(?!</span>).)*<span", bare):
                report(path, n, "nested <span>", line)
            if re.match(r"\s*#", line) and "<span" in line:
                report(path, n, "span inside a heading", line)
            if re.search(r'<span style="color:red">\s*</span>', bare):
                report(path, n, "empty red span", line)
            if re.search(r'<span style="color:red">\w{1,2}</span>\w', bare):
                report(path, n, "span splits a word", line)
        if slack and "~~" in bare:
            report(path, n, "strikethrough ~~", line)

        # 3. Bold markers must pair up
        no_tags = re.sub(r"\*\*\*", "", re.sub(r"<[^>]+>", "", bare))
        if no_tags.count("**") % 2:
            report(path, n, "odd number of ** (broken bold)", line)

        # 4. Tables: same cell count as the header, blank line before
        if line.lstrip().startswith("|"):
            cells = len(re.sub(r"\\\|", "", line).strip().strip("|").split("|"))
            if table_cols is None:
                table_cols = cells
                if prev.strip() and not prev.lstrip().startswith("|"):
                    report(path, n, "table needs a blank line before it", line)
            elif cells != table_cols:
                report(path, n, f"table row has {cells} cells, header has {table_cols}", line)
        else:
            table_cols = None

        # 5. Headings: space after the #s, blank line before
        if re.match(r"#{1,6}[^#\s]", line):
            report(path, n, "heading needs a space after #", line)
        if re.match(r"#{1,6} ", line) and prev.strip() and n > 1:
            report(path, n, "heading needs a blank line before it", line)

        # 6. Digits glued to a long word: usually spaces lost in an edit
        if re.search(r"\d[a-z]{6,}", re.sub(r"https?://\S+", "", bare)):
            report(path, n, "digits glued to a word (lost spaces?)", line)

        prev = line
    if in_fence:
        report(path, len(lines), "unclosed code fence", "")

print("OK" if not bad else f"{bad} issue(s)")
sys.exit(1 if bad else 0)
