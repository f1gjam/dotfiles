# gdoc-markdown-compat

Rules for writing Markdown that looks the same in Google Drive / Google Docs as it does locally.

**Run it:** loads automatically when Claude writes or edits a `.md` file that will go to Google Drive, or when you mention Google rendering, highlighting, colours or embedded images.

**What it covers:**

- A safe subset of Markdown, and what not to use (raw HTML, colour, underline, `==highlight==`, relative image links).
- Warnings as `### ***TEXT***` (or `***TEXT***` in table cells), since colour is not available.
- Images embedded as reference-style base64, with full-resolution PNG masters kept next to the document.
- Lint checks to run before every upload, and how to spot a Google-exported file.

**Writes:** nothing on its own. It shapes the Markdown Claude writes. Uploading is done by `gdrive-sync`.
