---
name: jira-create
description: Create a Jira issue by asking the user for the details (project, assignee, parent epic, status, description, acceptance criteria), writing a title from the description, checking all text for spelling and grammar, capturing a cost estimate and an approval-before-work criterion whenever the work may incur cost (infrastructure, AWS, Databricks and similar), and showing the draft for approval before creating it with the Atlassian MCP server. Use when the user asks to create, raise, open or log a Jira ticket, issue, task or story.
---

# jira-create

Creates one Jira issue with the Atlassian MCP server, as whoever is signed in to it.

## Rules that always apply

- **Nothing is written to Jira until the user approves the final draft** (step 4). The user asking for a ticket counts as approval only when they gave every detail and said not to ask.
- **Follow the project and company rules.** Before creating, read any `CLAUDE.md` in the working folder and its parents for Jira rules: site and `cloudId`, default project, required components or labels, board rules, team names. Those rules win over the defaults here.
- **Never invent facts.** No made-up owners, dates, numbers, epics or scope. If the description needs a fact you don't have, ask.
- **Acceptance criteria live in the Acceptance Criteria field, not in the description.** Never write an "Acceptance criteria" section into the description.
- **Rewording keeps meaning.** Fix spelling, grammar and clarity. Don't add requirements or scope the user didn't give.
- **Cost check on every ticket.** If the work may incur cost (infrastructure, cloud such as AWS, Databricks, licences, SaaS, data storage, data transfer, compute, extra environments or similar), the ticket must carry a cost estimate, a clear cost warning in the description, and an acceptance criterion that the costs are approved before work starts (see "Cost impact" in step 3). **Work this out yourself, don't ask the user whether it costs money or what it costs.** Read the description and decide from what the work does (new or bigger resources, more data stored or copied, more requests or compute, extra environments, new licences, retention or versioning changes). Then get the estimate yourself (see "Rules for the estimate" in step 3). Ask the user only for a figure that no source can give you. If the work genuinely has no cost, write "No cost expected" with a one-line reason in the draft.

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
     ```

   - **Acceptance criteria go in the Jira "Acceptance Criteria" field, never in the description.** Keep a separate list of the criteria (including the cost-approval one, first) and send it as that field in step 5. The description must not contain an "Acceptance criteria" heading or a copy of the criteria. In the draft (step 4), show the criteria under their own "Acceptance criteria (field)" heading so the user can review them, and make clear they are stored in the field. Write them as a Markdown bullet list, one testable statement per bullet.

   - **Cost impact (when the work may incur cost).** Put this section in the description straight after the first paragraph, so it can't be missed (there is no separate cost field or cost-approval section in Jira: the cost impact stays in the description, and the approval is an ordinary acceptance criterion):

     ```markdown
     ## Cost impact: DO NOT START until costs are approved

     **Estimated cost:** <one-off USD X, recurring USD Y a month, or a range>. This is an estimate, not a quote.

     | Item | Basis and assumptions | One-off | Monthly |
     | ---- | --------------------- | ------- | ------- |
     | <resource or action> | <unit price, quantity, size, region, duration> | USD <n> | USD <n> |

     <one line on what drives the cost up, for example data volume, request count, retention, number of environments>
     ```

     Rules for the estimate:
     - **Get the numbers yourself, and never invent them.**
       - Quantities and sizes: read them from the real system with read-only calls (for example CloudWatch bucket sizes and object counts, resource lists and counts through the AWS tools or CLI, Databricks usage or cluster details), or from the repo, the ticket or the export you were given.
       - Unit prices: use the published list price (for example the AWS pricing documentation through the AWS tools, or the Databricks pricing page), and note the region and date.
       - Multiply them out in the table, and show the unit price and quantity so anyone can check it.
       - If a source can't be reached or a figure doesn't exist anywhere, write "not estimated: needs" plus the missing figure in that row, say what you tried, and only then ask the user. Don't leave a blank or a guess.
     - Cover **one-off and recurring** cost, and anything that grows over time (storage, retention, data transfer, requests, DBUs, extra copies or versions).
     - Say whether it is a new cost or a change to an existing one, and the account or workspace it lands in.
     - Give a range when the quantity is uncertain, and say which assumption moves it.
     - Make the first item in the Acceptance Criteria field (not in the description) this criterion, so the ticket can't be closed, or started, without the cost approval: `Costs reviewed and approved by <approver, or "the ticket owner" if the user named nobody> before any work starts; approval and the agreed amount recorded as a comment on this ticket`. Don't invent an approver's name.
     - If the work is split into phases with different costs, give one row per phase.

   - **Check every piece of text** (title, description, criteria, labels): spelling, grammar, punctuation, consistent tense, consistent names for teams and systems. Keep proper nouns and product names exactly as the user writes them unless clearly misspelled; if unsure, ask.

4. **Show the draft and get approval.** Print project, issue type, title, assignee, epic, status, priority, labels, components and the full description. Show the cost verdict on its own line first ("Cost: estimated USD X one-off, USD Y a month, approval required before work starts" or "Cost: none expected" plus a one-line reason), say where the figures came from, and flag any row marked "not estimated". List any wording changes that might alter meaning. Then ask with `AskUserQuestion`: "Create this ticket?" with options "Yes, create it" and "Change something" (the user types the change through "Other" or in notes). Apply edits and show the draft again if they were large.

5. **Create the issue** with `createJiraIssue`: `cloudId`, `projectKey`, `issueType`, `summary`, `description` (without acceptance criteria), `assignee` (accountId), `parent` (epic key, if any), `priority`, `labels`, and any required fields from `CLAUDE.md` in `additional_fields` (for example `components`).

   **Acceptance criteria field:** the field's id differs per site. Find it once per session: read an existing issue in the project with `getJiraIssue` and `view: full` (or `evidence`) and look for "Acceptance Criteria" under `customFields` (for example `customfield_13230` on one site), or use `discover` ("get create metadata for jira issue type"). Pass the criteria as that field in `additional_fields`. If the field isn't accepted on create, set it straight after with `editJiraIssue`. If the project has no Acceptance Criteria field, tell the user and ask where to put them. Don't fall back to the description without asking.

6. **Set the status** if it isn't the starting one: `transitionJiraIssue` with `transitionName`. If that name fails, get the transitions with `discover` ("list jira issue transitions") and pick the one that leads to the requested status.

7. **Check it** with `searchJiraIssuesUsingJql` (`key = <KEY>`, fields `summary, status, assignee, parent, components`), and read the issue with `getJiraIssue` to check the Acceptance Criteria field is filled and the description has no acceptance criteria in it. Some create calls silently drop fields such as components or custom fields: if one is missing, add it with `editJiraIssue` (for components, send the full list).

8. **Report** the key as a link (`https://<site>/browse/<KEY>`), the final title, status, assignee, epic and any required fields that were set. If the ticket has a cost impact, say so and give the estimate.

## Existing tickets

When the user asks to change a ticket (not create one) and the change adds or reveals cost, apply the same rule: add the "Cost impact" section to its description and the approval criterion to its Acceptance Criteria field (as the first criterion, keeping the existing ones), keeping all existing text, and ask before writing as usual. If an existing ticket has acceptance criteria written in its description, tell the user and offer to move them into the field.

## If something fails

- A rejected create returns a `repairHint` and `allowedValues`: fix that field and retry once.
- If the issue was created but a later step failed, don't create it again. Fix the existing issue and say what happened.
