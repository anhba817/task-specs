# Tracker adapter: Jira

Requires a Jira MCP server in the session exposing issue read and create
tools (commonly `getJiraIssue` and `createJiraIssue`). If none is available,
fall back to `none.md` and say why.

## Contract A — Resolve work item

Call `getJiraIssue` for the ID with fields `summary, issuetype, parent`.

```
id      = the issue key, e.g. ABC-1234
slug    = argument 2 (kebab title) if given, else the summary kebab-cased
title   = fields.summary
parent  = { id: fields.parent.key, title: fields.parent.fields.summary }  — or null
```

A `parent` that is an Epic is the grouping level. A task with no parent is
standalone. If the call fails, degrade to `none.md` and note in the output that
the folder can be moved under its epic later.

## Contract B — Create child items

For each Feature Slice, create one subtask:

- `issuetype: Subtask`
- `parent: {parent_id}`
- `summary: {slice title}`
- `description: {acceptance criteria summary}`

Create each subtask with the MCP server's issue-creation tool. If the project
has installed its own ticket-authoring skill, prefer it so local ticket
conventions are kept. Capture the returned key per slice; that key becomes the
slice's ID in its filename.

Creating subtasks writes to a shared system. Follow the destination rule in
`config.md`: only create when `tracker` is set explicitly in config, and name
the Jira site and parent key before the first write. Otherwise print the four
fields per slice as a table and let a human file them.
