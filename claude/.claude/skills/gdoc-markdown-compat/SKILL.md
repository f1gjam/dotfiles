---
name: gdoc-markdown-compat
description: Write or edit Markdown that must display correctly in Google Drive / Google Docs. Use whenever creating or changing a .md file that will be uploaded to or shared through Google Drive, or when the user mentions Google compatibility, Google rendering, highlighting, colours or embedded images in markdown. Keeps to syntax Google preserves and avoids HTML, colour, relative image links and extensions that Google drops or breaks.
---

# gdoc-markdown-compat

Rules so a Markdown file looks the same in Google as it does locally. The aim is **no styling that conflicts with Google's rendering**.

**What is verified and what is inferred.** Verified: Google's own Markdown export of a Google Drive file (see "How Google writes it"). Inferred: that Google's import ignores raw HTML and extensions. Where a rule is inferred, it says so. When unsure, keep to the safe subset below, or test with a small throwaway file (ask the user before uploading a test file).

## Safe subset (use freely)

- ATX headings `#` to `######`, one blank line before and after.
- `**bold**`, `*italic*`, `***bold italic***`, `` `code` ``, fenced code blocks, `[text](https://url)` links.
- `-` bullets and `1.` numbered lists. Nested lists indented consistently.
- Pipe tables with a header row and separator row (`| --- | --- |`).
- Horizontal rule `---` on its own line, blank lines around it.
- Block quotes `>`.
- In-document links to headings: `[text](#heading-slug)` (lowercase, spaces to hyphens, punctuation removed). Keep the Contents list in step with the real headings.

## Do not use

| Avoid | Why | Use instead |
|---|---|---|
| Raw HTML: `<span style=...>`, `<b>`, `<u>`, `<mark>`, `<font>`, `<div>`, `<br>`, `<img>`, `<details>` | Inferred: Google ignores or shows it as text. Red `<span>` colour was lost in Google's copy. | Markdown emphasis and headings |
| Colour of any kind | Markdown has none, and Google will not honour HTML colour | Heading plus bold italic (below) |
| Highlight `==text==` | Editor extension (Obsidian, Typora). Not Google. | Bold italic, or a warning line (below) |
| Underline | No Markdown syntax | Bold italic |
| Relative image links `![](file.png)` | Drive cannot resolve paths on the author's disk | Embedded images (below) |
| Remote image URLs you do not control | Break when the link dies or needs login | Embedded images |
| Footnotes `[^1]`, task lists `- [ ]`, definition lists, math, emoji shortcodes `:warning:` | Not verified in Google. Treat as unsupported until tested. | Plain text and tables |
| Hand-written escapes (`\.`, `\=`), `&nbsp;` padding | Google's exporter adds these itself. Writing them by hand clutters the source. | Plain text |
| The same image twice (relative link plus embedded) | Shows twice or broken in Drive | One embedded reference only |

## Warnings and callouts (no colour available)

The convention used so far:

- **Standalone warning** (for example FOR DISCUSSION, ILLUSTRATIVE ONLY): its own line as `### ***TEXT***`. Larger than body text, bold italic, and visible in the outline.
- **Inside a table cell:** `***TEXT***` only. A heading cannot go in a cell.
- Do not wrap warnings in HTML, and do not add colour or underline.
- If the user asks for a stronger marker, an emoji prefix such as `⚠️` is plain Unicode and survives conversion. Ask before changing the established convention.

Note the outline effect: `###` headings appear in Google's outline at the same level as other `###` headings. Mention it if outline clutter matters, and offer `####`.

## Images: embed, never link a path

Embedded images travel inside the file, so Drive shows them with no separate upload.

Use reference-style syntax:

```markdown
![Alt text][image1]

[image1]: <data:image/png;base64,iVBORw0KGgo...>
```

- Put the `[imageN]: <data:...>` definitions at the **end** of the file, one per image, numbered in order of first use.
- Use PNG. Embed the **full-resolution** master. Google's own export downscales images, so do not round-trip images through Google.
- Keep the PNG masters (and any source such as `.dot`) next to the document, because an embedded copy cannot be turned back into the original.
- Use alt text, not an empty `![]`.
- File size: each image adds roughly 1.33 times its bytes. A document with a few large diagrams can pass 1 MB. That is fine for Drive, but never `Read` or print it whole: view it with the data URIs stripped:
  `sed -E 's/^\[image[0-9]+\]: <data:[^>]*>.*$/[embedded image removed]/' doc.md`

Embed or re-embed from local PNGs (run with `python3 -I`, pass paths as arguments):

```python
import base64, re, sys
doc, *pairs = sys.argv[1:]            # doc.md name1=path1.png name2=path2.png ...
s = open(doc, encoding="utf-8").read()
for i, pair in enumerate(pairs, 1):
    ref, png = pair.split("=", 1)
    b64 = base64.b64encode(open(png, "rb").read()).decode()
    link = re.compile(r'!\[([^\]]*)\]\(' + re.escape(png) + r'\)')
    s = link.sub(lambda m: "![%s][image%d]" % (m.group(1) or ref, i), s)
    defn = "[image%d]: <data:image/png;base64,%s>" % (i, b64)
    if re.search(r'(?m)^\[image%d\]: ' % i, s):
        s = re.sub(r'(?m)^\[image%d\]: .*$' % i, lambda m: defn, s)
    else:
        s = s.rstrip("\n") + "\n\n" + defn + "\n"
open(doc, "w", encoding="utf-8").write(s)
```

After embedding, verify each decoded image's md5 equals the source PNG's md5.

## Lint before every upload

Run these on the file. Anything printed under the "must be empty" checks needs fixing. Strip data URIs first so output stays small.

```bash
F=<doc.md>
V=$(sed -E 's/^\[image[0-9]+\]: <data:[^>]*>.*$/[img]/' "$F")
echo "$V" | grep -nE '<(span|b|u|mark|font|div|br|img|details|style|script)[ >/]'     # HTML: must be empty
echo "$V" | grep -nE '!\[[^]]*\]\([^)]*\)'                                          # image by path or URL: must be empty
echo "$V" | grep -nE '==[^=]+=='                                                    # highlight syntax: must be empty
echo "$V" | grep -nE '^\s*- \[[ x]\]|\[\^[0-9a-z]+\]'                               # task lists, footnotes: must be empty
echo "$V" | grep -noE '!\[[^]]*\]\[image[0-9]+\]' | sort | uniq -d                  # same image used twice: must be empty
# every [imageN] reference has a definition, and every definition is used:
diff <(echo "$V" | grep -oE '\]\[image[0-9]+\]' | tr -d '][' | sort -u) <(grep -oE '^\[image[0-9]+\]' "$F" | tr -d '][' | sort -u)
# Contents links resolve: list heading slugs and eyeball against (#...) links
echo "$V" | grep -E '^#{1,6} ' | head -60
```

Also check by eye: the Contents list matches the real section headings; no skipped heading levels that break the outline.

## How Google writes it (so you recognise a Google-exported file)

A file round-tripped through Google shows: `\.` and `\=` escapes (`## 1\. Summary`), `&nbsp;` lines, padded table separators (`| :---- | :---- |`), `![][image1]` references with base64 definitions at the end, headings left as plain text if they were not real headings, and colour/underline reduced to bold. Do not "fix" these when comparing: normalise them away (remove `&nbsp;`, unescape `\X`, collapse whitespace, ignore separator rows) before diffing against a local file.

## Workflow

1. Write or edit using the safe subset only.
2. Embed images from the PNG masters.
3. Run the lint block and fix findings.
4. For sync to Drive, hand off to the **gdrive-sync** skill. It asks before uploading.
5. After upload, tell the user what was not verified: how Drive's viewer actually renders headings, emoji, tables and images. Ask them to open the link and confirm.
