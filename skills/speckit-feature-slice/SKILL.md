---
name: speckit-feature-slice
description: "Decompose a Task Spec into self-contained Feature Slice files, optionally filing one child work item per slice. Works with Jira, GitHub Issues, Linear, or no tracker at all."
argument-hint: "<parent-work-item-id|slug> [scope overrides]"
license: MIT
metadata:
  author: dong
user-invocable: true
disable-model-invocation: false
---

# Task Spec to Feature Slices

A **Feature Slice** is one independently implementable slice of a Task Spec. It
maps 1:1 to a child work item and to exactly one downstream spec unit (the
`spec.md` / `plan.md` / `tasks.md` set).

**Output requirement:** each Feature Slice is an independent, self-contained
Markdown file. It carries everything a downstream coding agent needs to execute
that one requirement without reading the Task Spec or any sibling slice.

## User input

```text
$ARGUMENTS
```

Argument 1 is the parent work-item ID or slug. Anything after it may override
the slice count or restrict scope ("keep as a single slice", "focus on the retry
path only"). You **MUST** honor those overrides.

## Step 0 — Resolve configuration and locate the Task Spec

Read `references/config.md` and resolve `tracker`, `docs_root`, `id_pattern`,
and `child_items`.

```bash
find {docs_root} -maxdepth 2 -type d -name "{arg1}-*"
```

Read `task-spec.md` from the match. Abort with a clear message if:

- Nothing matches → "Run `/speckit-task-spec {arg1} <title>` first."
- Several match → prefer the one containing `task-spec.md`; if still ambiguous,
  list them and ask which to use.

Write every Feature Slice file into that same folder.

## Step 1 — Risks

Name the top 1–3 technical risks, unhandled edge cases, or pieces of missing
business logic in the Task Spec that would block an engineer.

## Step 2 — Slice count (scope gate)

**Default to a single Feature Slice.** Split only when at least one of these
holds:

| Signal | Split? |
|---|---|
| Sub-requirements target **different engineering layers** that could be reviewed and merged independently (schema migration + API handler + worker) | Yes |
| Sub-requirements have a **strict ordering** where one must merge before another can start | Yes |
| Sub-requirements could go to **different engineers in parallel** | Yes |
| One sub-requirement alone would take **more than ~5 days** | Yes |
| The item describes **multiple distinct behaviors** with no shared implementation code | Yes |

Stay single when the work is one bounded deliverable (one endpoint, one worker,
one integration), would land in **one PR** by one engineer, shares an
implementation surface, or is already precise enough to start on.

**The decisive question:** if one engineer implemented this in one sitting, would
they open one PR or several? One PR means one slice.

State the count and the reason **before** writing any slice content.

## Step 3 — Decompose

Break the Task Spec into specific, testable slices along its technical seams
(migration, route, validation, error handling). Every slice file repeats the
parent context — that is the point of the format, not duplication to trim.

## Step 4 — Sequence into phases

- **Phase 1 (Core MVP):** the minimum for the feature to work.
- **Phase 2 (Fast follows):** edge cases, secondary validation, retries.
- **Phase 3 (Polish):** scale, analytics, rate limiting.

Order the slices globally by execution dependency.

## Step 5 — File child work items

Count the slices first.

**One slice:** skip creation entirely. The slice uses the parent's ID (or slug)
as its reference.

**Two or more:** creating child items writes to a system other people share, so
it happens only under the destination rule in `references/config.md`:

- `child_items` is `auto` **and** `tracker` was set explicitly in config or an
  environment variable → read `references/trackers/{tracker}.md`, follow
  **Contract B**, and name the destination (Jira site and parent key, GitHub
  `owner/repo`, or Linear team) before the first write. Capture each returned ID.
- `child_items` is `auto` but the tracker was **autodetected** → treat it as
  `manual` and say why. A guessed destination is never written to.
- `child_items` is `manual` → print the payloads as a table for a human to file,
  and name the files with the parent reference.
- `child_items` is `none`, or the tracker is `none` → create nothing. Say so in
  the summary so the user knows the slice files are the only record.

Keep child descriptions to the acceptance criteria. Do not copy source paths,
code, or internal identifiers into a shared tracker beyond what those criteria
need.

## Step 6 — Write the slice files

```
{NN}-FS-{child_id | parent_id | slug}-{kebab-title}.md
```

Examples: `01-FS-ABC-1235-create-delivery-worker.md`,
`01-FS-42-create-delivery-worker.md`, `01-FS-payment-retries-create-worker.md`.

Required format:

```markdown
# {FS-ID}: {Requirement name}
**Phase:** {1: MVP | 2: Edge cases | 3: Polish}

## 1. Parent feature context
* **Feature name:** {name of the parent work item}
* **Overarching goal:** {one sentence on what the parent feature achieves}

## 2. Requirement details
* **User story:** As a [persona/system], I want to [action] so that [outcome].
* **Why this phase:** {justification for the priority}

## 3. Acceptance criteria
* **Scenario:** {name}
    * **Given** {precondition}
    * **When** {action}
    * **Then** {expected outcome}

## 4. Technical context and constraints
* **Engineering layers:** {tables, endpoints, components}
* **Rules and constraints:** {logic rules, data types, security constraints}

## 5. Dependencies
* **Prerequisites:** {slice IDs and filenames that must land first, or "None"}
```

## Step 7 — Report

```
## Technical assessment
* **Objective:** {one sentence}
* **Top delivery risks:**
  1. {risk}: {explanation and mitigation}
  2. {risk}: {explanation and mitigation}

## Feature slices generated

| # | File | Child item | Phase |
|---|------|-----------|-------|
| 01 | {folder}/01-FS-ABC-1235-create-worker.md | ABC-1235 | Phase 1 |
| 02 | {folder}/02-FS-ABC-1236-add-retry.md | ABC-1236 | Phase 2 |

Tracker: {tracker}   Child items: {created | printed for manual filing | none}

Next step: run the downstream spec command for each slice, e.g.
/speckit-specify 01-FS-ABC-1235-create-worker.md
(When no spec toolchain is installed, the slice files are the handoff artifact.)
```

## Writing style (mandatory)

If the config names a `writing_style` file and it exists, read it and apply it
to every sentence you write. Otherwise read `references/writing-style.md` and
apply that. Run its grep self-check against your draft before reporting done.
