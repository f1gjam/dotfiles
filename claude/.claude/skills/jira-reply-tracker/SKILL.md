---
name: jira-reply-tracker
description: Find the Jira tickets where someone is waiting on the person running the skill. Searches the Atlassian MCP server for open tickets that mention them or that they watch or are assigned to, checks whether they already replied, and reports what still needs a reply. Use when someone asks which Jira mentions they still owe a reply on, or to triage, go through or catch up on their Jira notifications.
---

# Jira Reply Tracker

Jira is read with the Atlassian MCP server. Everything is resolved from whoever is signed in to that server, so any teammate can run it. Gmail is not used, so this only sees what is in Jira.

## Rules that always apply

- **Never post, edit or transition anything in Jira.** This skill only reads Jira. Offer to draft a reply, and post nothing.
- **Ignore Done tickets.** Both searches exclude them, so a ticket that closed with a request still open is not reported.

## Steps

1. **Get the account and site.** Call `atlassianUserInfo` for the account ID and display name. Call `getAccessibleAtlassianResources` for the `cloudId`. If more than one site comes back, ask which one to use.

2. **Search twice.** A ticket where the user is only mentioned shows up in the first search and not the second, so run both. The lookback is 14 days unless the user gives another. Call `searchJiraIssuesUsingJql` with:
   - `cloudId`: from step 1
   - `jql`, first search: `comment ~ currentUser() AND statusCategory != Done AND updated >= -14d ORDER BY updated DESC`
   - `jql`, second search: `(watcher = currentUser() OR assignee = currentUser()) AND statusCategory != Done AND updated >= -14d ORDER BY updated DESC`
   - `fields`: `["summary", "status", "assignee", "comment"]`
   - `responseContentFormat`: `markdown`
   - `maxResults`: `100`

   Results are paginated. While `pageInfo.hasNextPage` is true, call again with `nextPageToken` set to `endCursor`. The result is usually too large to return inline, so the tool saves each page to a file. Keep every path.

3. **Classify the tickets.**

   ```bash
   python3 -I <skill-base-directory>/classify.py <account-id> "<Display Name>" <saved-file>...
   ```

   Pass every saved file from both searches. The script merges them by issue key. It matches the literal text `@<Display Name>`, so a comment that says only the first name isn't counted. It marks each ticket **OWED** (someone mentioned the user after their latest comment) or **HANDLED**. That's a first pass, so read the comments it prints:
   - Every OWED ticket is reported, even when the newest mention is only an acknowledgement ("Thank you!", "just submitted", "looks good, closing"). Label it **Ask** if someone wants something from the user, or **FYI** if not.
   - On a HANDLED ticket, check that every request addressed to the user was actually answered. Their later comment may cover only part of an earlier ask. If something is still open, mark it **Maybe** and say exactly what's missing.
   - If someone else on the thread answered a question addressed to the user, mark it **Maybe** and quote that answer.
   - If the user asked someone else a question that's still unanswered and they also owe a reply, mark it **Maybe** and say whose move it is.

4. **Re-fetch before reporting.** For each OWED or Maybe ticket, call `getJiraIssue` for the latest comments. A reply may have landed since the search.

5. **Report and stop.** Use four tables:
   - **Needs your reply:** the Ask tickets: ticket, status, who asked, what they asked, and when.
   - **Mentioned you:** the FYI tickets: ticket, status, who mentioned them, and a one-line quote.
   - **May need your reply:** ticket, status and what's unresolved.
   - **Handled:** tickets with no mention of them after their latest comment, and their last state, in one line.

   Offer to draft replies for the Needs your reply tickets.

## Limits

- A mention inside a screenshot or attachment can't be searched or read. Say so when a comment is mostly an image.
- A request made in email, Slack or a meeting isn't in Jira and won't appear.
