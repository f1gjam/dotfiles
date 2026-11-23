---
name: jira-create
description: Create a Jira issue by asking the user for the details (project, assignee, parent epic, status, description, acceptance criteria), writing a title from the description, checking all text for spelling and grammar, and showing the draft for approval before creating it with the Atlassian MCP server. Use when the user asks to create, raise, open or log a Jira ticket, issue, task or story.
---

# jira-create

Creates one Jira issue with the Atlassian MCP server, as whoever is signed in to it.

## Rules that always apply

- **Nothing is written to Jira until the user approves the final draft** (step 4). The user asking for a ticket counts as approval only when they gave every detail and said not to ask.
- **Follow the project and company rules.** Before creating, read any `CLAUDE.md` in the working folder and its parents for Jira rules: site and `cloudId`, default project, required components or labels, board rules, team names. Those rules win over the defaults here.
- **Never invent facts.** No made-up owners, dates, numbers, epics or scope. If the description needs a fact you don't have, ask.
- **Rewording keeps meaning.** Fix spelling, grammar and clarity. Don't add requirements or scope the user didn't give.

## Steps

1. **Collect what the user already gave.** Read the request for project, issue type, assignee, epic, status, priority, labels, description and acceptance criteria. Only ask about what is missing.

2. **Ask for the rest** with `AskUserQuestion` (up to four questions per call; free text comes through "Other"). Ask about:
   - **Assignee**: offer "Me", "Unassigned", and people from the team list in `CLAUDE.md` if there is one.
   - **Epic**: "None" or an epic. If the user names one loosely, find it with `searchJiraIssuesUsingJql` (`project = <KEY> AND issuetype = Epic AND statusCategory != Done AND summary ~ "<words>"`) and confirm the key.
   - **Description**: what needs doing and why.
   - **Acceptance criteria**: how we know it is done.
   - Project, issue type (default `Task`) and starting status (default: the workflow's first status) only if `CLAUDE.md` or the request doesn't settle them.

   Resolve the assignee's accountId with `atlassianUserInfo` (for "me") or `lookupJiraAccountId`. If several people match, ask.

3. **Write the draft.**
   - **Title**: generate it from the description. Short (about 4 to 10 words), specific, starts with the subject or a verb, no trailing full stop. If the user gave a title, keep it and only fix spelling and grammar.
   - **Description**: rewrite the user's text in clear, plain English. Use this layout in Markdown:

     ```markdown
     ## Description

     <one or two sentences on the goal and why>

     <bullets for scope, if there is a list>

     ## Acceptance criteria

     - <testable statement>
     - <testable statement>
     ```

   - **Check every piece of text** (title, description, criteria, labels): spelling, grammar, punctuation, consistent tense, consistent names for teams and systems. Keep proper nouns and product names exactly as the user writes them unless clearly misspelled; if unsure, ask.

4. **Show the draft and get approval.** Print project, issue type, title, assignee, epic, status, priority, labels, components and the full description. List any wording changes that might alter meaning. Wait for "yes" or edits; apply edits and show it again if they were large.

5. **Create the issue** with `createJiraIssue`: `cloudId`, `projectKey`, `issueType`, `summary`, `description`, `assignee` (accountId), `parent` (epic key, if any), `priority`, `labels`, and any required fields from `CLAUDE.md` in `additional_fields` (for example `components`).

6. **Set the status** if it isn't the starting one: `transitionJiraIssue` with `transitionName`. If that name fails, get the transitions with `discover` ("list jira issue transitions") and pick the one that leads to the requested status.

7. **Check it** with `searchJiraIssuesUsingJql` (`key = <KEY>`, fields `summary, status, assignee, parent, components`). Some create calls silently drop fields such as components: if one is missing, add it with `editJiraIssue`, sending the full list.

8. **Report** the key as a link (`https://<site>/browse/<KEY>`), the final title, status, assignee, epic and any required fields that were set.

## If something fails

- A rejected create returns a `repairHint` and `allowedValues`: fix that field and retry once.
- If the issue was created but a later step failed, don't create it again. Fix the existing issue and say what happened.
