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

2. **Ask for the rest.** Use `AskUserQuestion` for every choice (board, criteria, assignee, epic, status). Each call takes up to four questions with two to four options each, and the user can type free text through "Other". Skip any question the request already answers.

   **The description is free text, so don't ask for it with an option to pick.** Picking an option like "Type it" returns only the label, not the text. If the request has no description, ask for it in a short plain chat message and wait for the reply. Offer "Draft it from this conversation" as an `AskUserQuestion` option only when the conversation or an open file gives enough to go on.

   **Before asking**, look up what the options need: open epics in the project (`project = <KEY> AND issuetype = Epic AND statusCategory != Done ORDER BY updated DESC`, newest three), and the team list and boards from `CLAUDE.md`.

   **First call: where it goes** (can be sent while waiting for the description).
   - **Board or project**: always ask when `CLAUDE.md` lists more than one board, unless the request names one. Put the default board first, marked "(Recommended)" (the one `CLAUDE.md` calls primary or default), then the others.

   **Second call, once you have the description: done-ness, who and where.**
   - **Acceptance criteria**: write three or four short, testable example criteria from the description and offer them as options with `multiSelect: true`. The user ticks the ones to keep and adds or rewrites their own through "Other" or the notes. Use what they tick plus what they type.
   - **Assignee**: "Me", "Unassigned", and up to two people from the team list. Others come through "Other".
   - **Epic**: "None" and the open epics you found. If the user types a name loosely, search for it (`summary ~ "<words>"`) and confirm the key.
   - **Status**: the workflow's first status (for example "Backlog"), "To Do" and "In Progress".

   **Issue type** defaults to `Task` (or what the request says); mention it in the draft so the user can change it in step 4.

   Resolve the assignee's accountId with `atlassianUserInfo` (for "me") or `lookupJiraAccountId`. If several people match, ask with `AskUserQuestion`.

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

4. **Show the draft and get approval.** Print project, issue type, title, assignee, epic, status, priority, labels, components and the full description. List any wording changes that might alter meaning. Then ask with `AskUserQuestion`: "Create this ticket?" with options "Yes, create it" and "Change something" (the user types the change through "Other" or in notes). Apply edits and show the draft again if they were large.

5. **Create the issue** with `createJiraIssue`: `cloudId`, `projectKey`, `issueType`, `summary`, `description`, `assignee` (accountId), `parent` (epic key, if any), `priority`, `labels`, and any required fields from `CLAUDE.md` in `additional_fields` (for example `components`).

6. **Set the status** if it isn't the starting one: `transitionJiraIssue` with `transitionName`. If that name fails, get the transitions with `discover` ("list jira issue transitions") and pick the one that leads to the requested status.

7. **Check it** with `searchJiraIssuesUsingJql` (`key = <KEY>`, fields `summary, status, assignee, parent, components`). Some create calls silently drop fields such as components: if one is missing, add it with `editJiraIssue`, sending the full list.

8. **Report** the key as a link (`https://<site>/browse/<KEY>`), the final title, status, assignee, epic and any required fields that were set.

## If something fails

- A rejected create returns a `repairHint` and `allowedValues`: fix that field and retry once.
- If the issue was created but a later step failed, don't create it again. Fix the existing issue and say what happened.
