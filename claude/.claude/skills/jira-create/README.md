# jira-create

Creates a Jira issue after asking you for the details.

**Run it:** ask Claude to create, raise or log a Jira ticket. You can give some or all of the details up front.

**What it does:** asks for anything missing (assignee, parent epic, description, acceptance criteria, and project, type or status if needed). It writes the title from the description, rewrites the text in clear English and checks spelling and grammar. It then shows you the full draft. After you approve, it creates the issue with the Atlassian MCP server, moves it to the status you asked for, checks the result and gives you the link.

**Inputs:** your answers. Jira rules (site, default project, required components, team list) come from the `CLAUDE.md` files of the folder you run it in, so company-specific details stay out of this skill.

**Writes:** Jira only: one new issue, plus a status change and any field fix-ups on that issue. Nothing is written until you approve the draft.

| File | Purpose |
| ---- | ------- |
| `SKILL.md` | The instructions Claude follows. |
| `README.md` | This file. |
