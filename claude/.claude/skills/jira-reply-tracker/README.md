# jira-reply-tracker

Finds the Jira tickets where someone is waiting on you to reply.

**Run it:** ask which Jira mentions you still owe a reply on, or to triage or catch up on your Jira notifications.

**What it does:** uses the Atlassian MCP server as whoever is signed in, so any teammate can run it. It runs two searches over the last 14 days (tickets that mention you, and tickets you watch or are assigned to), then `classify.py` marks each ticket OWED or HANDLED. Claude reads the comments and reports four tables: Needs your reply, Mentioned you, May need your reply, and Handled. It offers to draft replies.

**Needs:** the Atlassian MCP server connected to Claude Code and signed in to your Atlassian site (check with `/mcp`), and `python3` for `classify.py` (comes with macOS and Homebrew). Nothing else to install.

**Writes:** nothing. It never posts, edits or transitions anything in Jira.

**Limits:** mentions inside screenshots or attachments can't be read, and requests made outside Jira (email, Slack, meetings) won't appear.

| File | Purpose |
| ---- | ------- |
| `SKILL.md` | The instructions Claude follows. |
| `classify.py` | Merges the search results by issue key and gives a first-pass OWED / HANDLED verdict. |
