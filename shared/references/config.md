# Workflow configuration

Both skills read one optional JSON config. Nothing here is required — with no
config file and no tracker, the skills still run end to end using slugs.

## Resolution order

1. `.taskspec.json` at the repository root.
2. `.specify/workflow.json` (for repositories already running Spec Kit).
3. Environment variables: `TASKSPEC_TRACKER`, `TASKSPEC_DOCS_ROOT`.
4. The defaults in the table below.

Read the first file that exists; do not merge two files. Environment variables
override individual keys of whichever file was read.

## Keys

| Key | Default | Meaning |
|---|---|---|
| `tracker` | autodetect, else `"none"` | `jira`, `github`, `linear`, or `none`. Selects which `references/trackers/{tracker}.md` adapter to follow. |
| `docs_root` | `"docs/specs"` | Directory the Task Spec folders are written under. |
| `id_pattern` | `"^[A-Z][A-Z0-9]+-[0-9]+$"` | Regex deciding whether argument 1 is a work-item ID. No match means it is a slug and no tracker call is made. `null` disables ID handling entirely. |
| `parent_grouping` | `true` | Whether a resolved parent (epic, milestone, project) adds a folder level. |
| `child_items` | `"manual"` | `auto` creates one child work item per Feature Slice, `manual` prints the payloads for a human to file, `none` skips creation. `auto` is honored only under the destination rule below. |
| `parent_docs` | `[]` | Filenames the skill checks for in the parent folder and reports as missing, e.g. `["prd.md", "rfc.md"]`. Empty array disables the check. |
| `writing_style` | `null` | Path to a project writing-style file. When absent, the skill falls back to `references/writing-style.md`. |

## Destination rule for writes

Reading from a tracker is safe. Creating child items writes to a system other
people share, so it needs an explicit destination.

1. `child_items: "auto"` is honored **only** when `tracker` is set explicitly in
   a config file or environment variable. An **autodetected** tracker is
   read-only — treat `auto` as `manual` and say why in the output.
2. Before the first write, name the destination: the Jira site and parent key,
   the GitHub `owner/repo`, or the Linear team. Do not write to a destination
   you inferred without stating it.
3. Child item descriptions are derived from repository material. Do not copy
   source paths, code, or internal identifiers into them beyond what the
   acceptance criteria need.

`manual` prints the payloads and creates nothing. It is the default because the
safe failure for a spec tool is an unfiled ticket, not an unwanted one.

## Autodetecting the tracker

When `tracker` is unset, pick the first that applies:

1. A Jira MCP tool is available in the session → `jira`.
2. `gh auth status` exits 0 **and** `git remote -v` points at github.com → `github`.
3. A Linear MCP tool is available → `linear`.
4. Otherwise → `none`.

State the detected tracker in your output so the user can pin it in config if
the guess was wrong. A detected tracker never creates child items — see the
destination rule above.

## Example

```json
{
  "tracker": "jira",
  "docs_root": "docs/product/briefs",
  "id_pattern": "^[A-Z]+-[0-9]+$",
  "parent_grouping": true,
  "child_items": "auto",   // explicit tracker above, so writes are allowed
  "parent_docs": ["prd.md", "rfc.md"],
  "writing_style": ".specify/memory/writing-style.md"
}
```
