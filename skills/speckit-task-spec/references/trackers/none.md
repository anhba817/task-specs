# Tracker adapter: none

No issue tracker. Everything is derived from the arguments and the filesystem.
This is the fallback whenever no tracker is configured, no tracker tool is
available, or argument 1 does not match `id_pattern`.

## Contract A — Resolve work item

Input: argument 1 (a slug), argument 2 (the kebab-case title, optional).

Return:

```
id      = null
slug    = argument 1
title   = argument 2 in sentence case, or the slug in sentence case
parent  = null
```

Make no network calls. Never invent an ID.

## Contract B — Create child items

Input: the parent slug and the list of Feature Slice titles.

Return `null` for every child ID. The Feature Slice filenames fall back to the
parent slug, and the slice files themselves are the only record of the
breakdown. Say so in the output summary so the user knows nothing was filed.
