# Tracker adapter: Linear

Requires a Linear MCP server in the session. If none is available, fall back to
`none.md` and say why.

## Contract A — Resolve work item

Fetch the issue by its identifier (e.g. `ENG-123`) and read `title`, `parent`,
and `project`.

```
id      = the issue identifier
slug    = argument 2 if given, else the title kebab-cased
title   = title
parent  = { id: parent.identifier, title: parent.title }  when a parent issue exists
        | { id: project.slugId,    title: project.name }  when only a project is set
        | null
```

## Contract B — Create child items

Create one sub-issue per Feature Slice with `parentId` set to the parent issue,
`title` set to the slice title, and the acceptance criteria summary as the
description. The returned identifier is the slice ID.

Creating sub-issues writes to a shared workspace. Follow the destination rule
in `config.md`: only create when `tracker` is set explicitly in config, and name
the target team and parent issue before the first write. Otherwise print the
payloads and let a human file them.
