"""Classify Jira tickets by whether the user owes a reply.

Usage: python3 -I classify.py <your-account-id> "<Your Display Name>" <jql-result.json>...

Reads one or more searchJiraIssuesUsingJql results (fields: summary, status,
comment; markdown format), merges them by issue key, and prints, per ticket,
its last comments and a verdict:
  OWED     someone mentioned you after your latest comment
  HANDLED  your latest comment is newer than every mention, or you were never mentioned
"""

import json
import sys

me, name, paths = sys.argv[1], sys.argv[2], sys.argv[3:]
issues = {}
for path in paths:
    with open(path) as fh:
        for issue in json.load(fh)["issues"]["nodes"]:
            issues[issue["key"]] = issue

for issue in sorted(issues.values(), key=lambda i: i["key"]):
    f = issue["fields"]
    comments = f.get("comment", {}).get("comments", [])
    mine = [c["created"] for c in comments if c["author"].get("accountId") == me]
    mentions = [
        c["created"]
        for c in comments
        if c["author"].get("accountId") != me and f"@{name}" in str(c["body"])
    ]
    last_mine = max(mine, default="")
    last_mention = max(mentions, default="")
    verdict = "OWED" if last_mention > last_mine else "HANDLED"

    print(f"\n=== {issue['key']} [{f['status']['name']}] {verdict}  {f['summary'][:80]}")
    # A mention can pair with an older, partly answered request, so print the whole thread.
    shown, limit = (comments, None) if mentions else (comments[-6:], 300)
    for c in shown:
        who = "ME" if c["author"].get("accountId") == me else c["author"]["displayName"]
        body = str(c["body"]).replace("\n", " ")[:limit]
        print(f"  {c['created'][:16]}  {who[:22]:22}  {body}")
