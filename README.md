# task-specs

Two agent skills that turn a work item into a reviewed **Task Spec**, then into
**Feature Slices** a coding agent can implement one at a time.

They work with **Jira, GitHub Issues, Linear, or no tracker at all** — the
tracker is a pluggable adapter, not a hard dependency. In a bare repository with
no configuration, both skills run end to end using slugs and make zero network
calls.

## Install

```sh
npx skills add anhba817/task-specs
```

Pick one:

```sh
npx skills add anhba817/task-specs --skill speckit-task-spec
npx skills add anhba817/task-specs --list
```

## Use

```sh
# With a tracker
/speckit-task-spec ABC-1234 connect-delivery-worker
/speckit-feature-slice ABC-1234

# Without one
/speckit-task-spec payment-retries "retry failed charges"
/speckit-feature-slice payment-retries
```

`speckit-task-spec` writes `{docs_root}/{id}-{slug}/task-spec.md` — six sections
covering scope, context and assumptions, `FR-###` functional requirements,
`NFR-###` non-functional requirements, an alignment and risk matrix, and open
questions. Every requirement cites its source; anything missing becomes an open
question rather than an invented number.

`speckit-feature-slice` reads that file and writes
`{NN}-FS-{id|slug}-{title}.md` beside it. It defaults to **one** slice and
splits only when the work would genuinely land as separate PRs. With
`child_items: "auto"` and an explicitly configured tracker it files one child
item per slice and uses the returned IDs in the filenames.

Writing to a tracker needs an explicit destination. `child_items` defaults to
`"manual"` — the payloads get printed for you to file — and an **autodetected**
tracker is always read-only, so the skills never create issues in a repository
or project you did not name.

The slice files are the handoff artifact. If you run
[Spec Kit](https://github.com/github/spec-kit), feed each one to
`/speckit-specify`; if you don't, hand them to any coding agent — each slice is
self-contained by design.

## Configure

Everything project-specific lives in one optional file at the repository root:

```jsonc
// .taskspec.json
{
  "tracker": "jira",                 // jira | github | linear | none
  "docs_root": "docs/product/briefs",
  "id_pattern": "^[A-Z]+-[0-9]+$",   // no match on arg 1 ⇒ it's a slug, no tracker call
  "parent_grouping": true,           // epic/milestone adds a folder level
  "child_items": "auto",             // auto | manual | none; auto needs an explicit tracker
  "parent_docs": ["prd.md", "rfc.md"],
  "writing_style": ".specify/memory/writing-style.md"
}
```

Resolution order: `.taskspec.json` → `.specify/workflow.json` →
`TASKSPEC_TRACKER` / `TASKSPEC_DOCS_ROOT` → defaults. With `tracker` unset the
skills autodetect: a Jira MCP server, then an authenticated `gh` on a GitHub
remote, then a Linear MCP server, else `none`. The detected tracker is reported
in the output so you can pin it.

A starting file is in [`templates/taskspec.json`](templates/taskspec.json). Full
key reference: [`shared/references/config.md`](shared/references/config.md).

## Prose style

Both skills apply a writing gate so the output does not read like generated
filler — no "pivotal", no "robust", no "leverage", no trailing `-ing` padding,
no vague attribution. Point `writing_style` at your own file to override it, or
let it fall back to
[`shared/references/writing-style.md`](shared/references/writing-style.md).

## Adding a tracker

Drop a `{name}.md` into `shared/references/trackers/` answering two contracts:

- **Contract A — resolve work item:** given an ID, return `{id, slug, title, parent}`.
- **Contract B — create child items:** given a parent and N slice titles, return
  N child IDs (or `null` each).

Then run `./scripts/sync-shared.sh` and set `"tracker": "{name}"`. The skill
bodies never name a tracker, so nothing else changes.

## Repository layout

```
skills/
  speckit-task-spec/SKILL.md       + references/   (copied from shared/)
  speckit-feature-slice/SKILL.md   + references/
shared/references/                 single source of truth for the copies
scripts/sync-shared.sh             copies shared/ into each skill
templates/taskspec.json
```

Each skill directory is self-contained because `--skill <name>` installs one
directory. Edit `shared/references/`, never a copy, then run the sync script.

## License

MIT
