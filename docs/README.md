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

When a file in any docs category is no longer active but should remain available as history, move it into that category's `archive/` subdirectory.

Examples:

- closed discussion -> `docs/discussion/archive/`
- closed plan -> `docs/plan/archive/`
- closed problem -> `docs/problem/archive/`
- closed status or progress record -> `docs/status/archive/`

## Current Focus

The active hot-update direction now has two layers:

### Long-Term Design First

The primary design decisions live in:

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/flutter-hot-update-react-like-direction.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-long-term-overview.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-long-term-architecture.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-host-bridge-governance.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-bundle-lifecycle.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-bundle-and-tree-contract.md`

These files define the stable direction, long-term engineering boundaries, and first runtime contract.

### Short-Term Plan Second

The current implementation plan lives in:

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/plan/2026-04-08-react-like-js-runtime-poc-plan.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/plan/2026-04-09-react-like-runtime-poc-implementation-plan.md`

This plan must follow the long-term design docs rather than redefine them.

### Current Status Third

The current implementation status lives in:

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/status/2026-04-09-react-like-runtime-doc-map.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/status/2026-04-09-react-like-runtime-poc-result.md`

### Discussion Support Only

Open discussion remains useful, but it is no longer the primary decision surface for the active route:

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/discussion/2026-04-08-react-like-dynamic-runtime.md`
