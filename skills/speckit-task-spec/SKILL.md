---
name: speckit-task-spec
description: "Generate a Task Spec (Feature Brief) for a work item and write it under the project's docs root, grouped under its parent epic/milestone folder when one exists. Works with Jira, GitHub Issues, Linear, or no tracker at all."
argument-hint: "<work-item-id|slug> [kebab-case-title] [areas to clarify]"
license: MIT
metadata:
  author: dong
user-invocable: true
disable-model-invocation: false
---

# Task Spec synthesis and generation

A **Task Spec** (Feature Brief) is the developer-owned, lead-validated brief for
one task. It captures business behavior, scope, success criteria, acceptance
criteria, assumptions, constraints, and impacted systems, mapped against what
the codebase actually does today. `speckit-feature-slice` later breaks it into
Feature Slices.

## User input

```text
$ARGUMENTS
```

Argument 1 is a work-item ID or a slug. Argument 2 is an optional kebab-case
title. Anything after that is extra context, constraints, or areas to focus on
("focus on error handling", "out of scope: billing"). You **MUST** take that
extra context into account.

## Step 0 — Resolve configuration

Read `references/config.md` and resolve the config. You need `tracker`,
`docs_root`, `id_pattern`, `parent_grouping`, `parent_docs`, and
`writing_style`. With no config file present, use the documented defaults and
autodetect the tracker.

## Step 1 — Resolve the work item

If argument 1 matches `id_pattern`, read `references/trackers/{tracker}.md` and
follow **Contract A**. Otherwise treat argument 1 as a slug and follow Contract A
of `references/trackers/none.md` — no tracker call.

Contract A gives you `id`, `slug`, `title`, and `parent`.

## Step 2 — Decide the output path

```
With a parent, parent_grouping true:  {docs_root}/{parent.id}-{parent-kebab}/{id|slug}-{slug}/task-spec.md
Otherwise:                            {docs_root}/{id|slug}-{slug}/task-spec.md
```

Reuse an existing parent folder rather than creating a second one:

```bash
find {docs_root} -maxdepth 1 -type d -name "{parent.id}-*"
```

Derive `{parent-kebab}` from the parent title, shortened to a few words. Create
the folder with `mkdir -p`. When the tracker call failed and you fell back to a
flat path, say so in the output — the folder can be moved under its parent later.

## Step 3 — Check for parent-level documents

If `parent_docs` is non-empty and the parent folder is missing any of those
files, do **not** generate them. Report what is missing in the output summary;
those documents have other owners.

## Step 4 — Ingest context

Search the repository for material that bears on this work: research notes,
architecture docs, ADRs, meeting notes, existing specs, and the code the change
touches. Read before you write. Do not summarize early — build a complete model
of the system first.

## Step 5 — Write the Task Spec

**Role:** you are a lead technical product manager and systems architect. You
turn an unstructured pile of repository context into one precise, traceable
brief.

Directives:

1. **Technical precision.** Keep the vocabulary of the source documents. Use
   explicit RFC 2119 keywords — **MUST**, **SHOULD**, **MUST NOT**.
2. **Strict traceability.** Every requirement cites the file, note, or document
   it came from.
3. **No invention.** A missing metric, architecture choice, or requirement goes
   in Open Questions. Never fabricate one.

Write `task-spec.md` with exactly this structure.

### 1. Executive summary and overview
- **Vision statement:** the business problem and the objective.
- **Scope:** explicit **In scope** and **Out of scope** boundaries.
- **Success metrics:** quantifiable business and technical outcomes (latency
  targets, cost reduction, throughput, adoption).

### 2. Context and assumptions
- **Synthesized insights:** what the source documents established, and the
  technical, financial, or regulatory constraints they surfaced.
- **Users and stakeholders:** who uses this and where their friction is.
- **Core assumptions:** 3–5 business or technical assumptions the work rests on.
- **System context diagram:** a Mermaid `graph TD` or `C4Context` block showing
  the user, the proposed system, and the external integrations it depends on.

### 3. Functional requirements
Group by system domain (orchestration, ingestion, UI, state). Use `FR-###`
identifiers — downstream `spec.md` artifacts trace back to these IDs.

| ID | System domain | Requirement description and acceptance criteria | Priority (MoSCoW) | Source |
| :-- | :-- | :-- | :-- | :-- |
| FR-001 | [Domain] | The system MUST… | Must/Should/Could | [file or note] |

### 4. Non-functional requirements

| ID | Category | Constraint / target metric | Approach | Source |
| :-- | :-- | :-- | :-- | :-- |
| NFR-001 | Performance | API p95 latency < 200 ms | How the design meets it | [file] |
| NFR-002 | Security | AES-256 at rest | Compliance driver | [file] |
| NFR-003 | Resilience | RTO < 1 h, RPO < 15 min | Availability strategy | [file] |

### 5. Approach alignment and risks
- **Architectural alignment:** how the proposed approach satisfies the Must-have
  functional requirements.
- **Conflicts:** contradictions, gaps, and underspecified areas between the
  research and the proposed approach. Name them; do not smooth them over.
- **Risk matrix:**

| Risk ID | Risk description | Impact (H/M/L) | Likelihood (H/M/L) | Mitigation |
| :-- | :-- | :-- | :-- | :-- |
| RSK-001 | State sync bottleneck across nodes | High | Medium | Distributed locking |

### 6. Open questions and information gaps
The exact details, metrics, and decisions missing from the available material,
written as direct questions a stakeholder can answer.

## Step 6 — Report

```
Task Spec written to: {folder}/task-spec.md
Tracker:              {tracker}  (configured | autodetected | unavailable, fell back to none)
Work item:            {id or "slug only"}
Parent grouping:      {parent.id} ({parent folder})   — or "none, standalone"
Parent documents:     {present | missing: prd.md, rfc.md}

Next step: validate this Task Spec with the owner, then run
/speckit-feature-slice {id|slug} to decompose it into Feature Slices.
```

## Writing style (mandatory)

If the config names a `writing_style` file and it exists, read it and apply it
to every sentence you write. Otherwise read `references/writing-style.md` and
apply that. Run its grep self-check against your draft before reporting done.
