# jira-create

Creates a Jira issue after asking you for the details.

**Run it:** ask Claude to create, raise or log a Jira ticket. You can give some or all of the details up front.

**What it does:** asks for anything missing. It asks for the description in plain chat (you type it), and the board as a clickable question (the default board is offered first, and you can change it). Next, a round of clickable questions offers example acceptance criteria written from your description (tick the ones you want, add or rewrite your own), then asks for the assignee, the epic (it offers the open ones) and the status. You can type your own answer to any question. The issue type defaults to Task and can be changed in the draft. It writes the title from the description, rewrites the text in clear English and checks spelling and grammar. It then shows you the full draft. After you approve, it creates the issue with the Atlassian MCP server, moves it to the status you asked for, checks the result and gives you the link.

**Inputs:** your answers. Jira rules (site, default project, required components, team list) come from the `CLAUDE.md` files of the folder you run it in, so company-specific details stay out of this skill.

**Needs:** the Atlassian MCP server connected to Claude Code and signed in to your Atlassian site (check with `/mcp`). Nothing to install on the machine.

**Writes:** Jira only: one new issue, plus a status change and any field fix-ups on that issue. Nothing is written until you approve the draft.

| File | Purpose |
| ---- | ------- |
| `SKILL.md` | The instructions Claude follows. |
| `README.md` | This file. |
