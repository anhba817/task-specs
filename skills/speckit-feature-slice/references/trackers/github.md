# Tracker adapter: GitHub Issues

Requires the `gh` CLI, authenticated (`gh auth status` exits 0).

## Contract A — Resolve work item

Argument 1 may be `42`, `#42`, or `owner/repo#42`.

```bash
gh issue view <n> --json number,title,milestone,parent,labels
```

```
id      = "#<number>"
slug    = argument 2 if given, else the title kebab-cased
title   = .title
parent  = { id: "#<parent.number>", title: parent.title }   when .parent is set
        | { id: .milestone.title,   title: .milestone.title } when only a milestone is set
        | null
```

`parent` is only present on repositories with sub-issues enabled; the milestone
is the usual stand-in. If `gh` is missing or unauthenticated, fall back to
`none.md`.

## Contract B — Create child items

For each Feature Slice:

```bash
gh issue create --title "<slice title>" --body "<acceptance criteria summary>"
```

Then link each new issue to the parent — `gh issue edit <parent> --add-sub-issue
<child>` where sub-issues are available, otherwise append a task-list line
`- [ ] #<child>` to the parent body. The returned `#<number>` is the slice ID.

Creating issues writes to a shared repository. Follow the destination rule in
`config.md`: only create when `tracker` is set explicitly in config, and name
the target `owner/repo` before the first write. Otherwise print the
`gh issue create` commands and let a human run them.
