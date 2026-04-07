# Project Docs

Status: active
Scope: Documentation structure and placement rules for this repository.
Source of truth: this file

This repository uses a small default taxonomy so future notes do not accumulate in random files.

## Where To Put Things

- `docs/discussion/`: open technical discussion, unresolved questions, exploratory notes
- `docs/design/`: design conclusions, architecture sketches, accepted technical direction
- `docs/product/`: scope, goals, and requirements
- `docs/plan/`: execution plans and implementation sequencing
- `docs/check/`: validation, acceptance, and test checklists
- `docs/status/`: progress snapshots and results
- `docs/problem/`: blockers, risks, defects, and constraints

## Current Working Rule

Until the repository grows a stronger convention, all ongoing technical discussion should be recorded in `docs/discussion/`.

Use one file per topic or session.
Recommended file name:

`YYYY-MM-DD-short-topic.md`

When a discussion turns into a stable conclusion, distill that result into the right destination:

- design outcome -> `docs/design/`
- requirement outcome -> `docs/product/`
- execution outcome -> `docs/plan/`
- validation outcome -> `docs/check/`
- blocker or risk outcome -> `docs/problem/`
- progress/result summary -> `docs/status/`

Closed discussion files can later move into `docs/discussion/archive/`.
