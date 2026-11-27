# jira-create

Creates a Jira issue after asking you for the details.

**Run it:** ask Claude to create, raise or log a Jira ticket. You can give some or all of the details up front.

**What it does:** asks for anything missing. It asks for the description in plain chat (you type it), and the board as a clickable question (the default board is offered first, and you can change it). Next, a round of clickable questions offers example acceptance criteria written from your description (tick the ones you want, add or rewrite your own), then asks for the assignee, the epic (it offers the open ones) and the status. You can type your own answer to any question. The issue type defaults to Task and can be changed in the draft. **Cost check:** it works out for itself whether the work may cost money (infrastructure, AWS, Databricks, licences, storage, compute and similar), without asking you. If it may, it gets the estimate itself: sizes and counts from read-only calls to the real system (for example CloudWatch for S3), unit prices from the published pricing, and multiplies them out. It adds a "Cost impact: DO NOT START until costs are approved" section (one-off and monthly, with the unit prices and assumptions shown, never invented numbers) and makes the first acceptance criterion "costs approved before work starts". It asks you only for a figure it couldn't find, and marks that row "not estimated". The draft shows a cost line first with where the figures came from, or "no cost expected" with the reason. The same applies when you ask it to change an existing ticket and the change adds cost. It writes the title from the description, rewrites the text in clear English and checks spelling and grammar. It then shows you the full draft. After you approve, it creates the issue with the Atlassian MCP server, moves it to the status you asked for, checks the result and gives you the link.

**Inputs:** your answers. Jira rules (site, default project, required components, team list) come from the `CLAUDE.md` files of the folder you run it in, so company-specific details stay out of this skill.

**Needs:** the Atlassian MCP server connected to Claude Code and signed in to your Atlassian site (check with `/mcp`). Nothing to install on the machine.

**Writes:** Jira only: one new issue, plus a status change and any field fix-ups on that issue. Nothing is written until you approve the draft.

| File | Purpose |
| ---- | ------- |
| `SKILL.md` | The instructions Claude follows. |
| `README.md` | This file. |
