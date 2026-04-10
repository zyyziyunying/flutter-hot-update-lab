# React-Like Runtime Doc Map

Status: active
Scope: Current document map and reading guide for the active React-like runtime direction in this repository.
Source of truth: this file
Last updated: 2026-04-10

## Current State

The repository has finished a large documentation realignment.
It now also has a first runnable in-repo PoC at:

- `/Users/zyyziyunying/flutter-hot-update-lab/demo/react_like_runtime_poc`

The active route is now:

- React-like JS runtime
- Flutter native renderer
- governed host bridge
- managed bundle lifecycle

The discarded local JSON payload demo route is preserved only as historical context.

## Where To Start

If you need the current canonical direction, read these files in order:

1. `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/flutter-hot-update-react-like-direction.md`
2. `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-long-term-overview.md`
3. `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-long-term-architecture.md`
4. `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-host-bridge-governance.md`
5. `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-bundle-lifecycle.md`
6. `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-bundle-and-tree-contract.md`

If you need the current implementation follow-up, then read:

7. `/Users/zyyziyunying/flutter-hot-update-lab/docs/plan/2026-04-08-react-like-js-runtime-poc-plan.md`
8. `/Users/zyyziyunying/flutter-hot-update-lab/docs/plan/2026-04-09-react-like-runtime-poc-implementation-plan.md`

## Current Canonical Files

### Long-Term Design

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/flutter-hot-update-react-like-direction.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-long-term-overview.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-long-term-architecture.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-host-bridge-governance.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-bundle-lifecycle.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-bundle-and-tree-contract.md`

### Short-Term Plan

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/plan/2026-04-08-react-like-js-runtime-poc-plan.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/plan/2026-04-09-react-like-runtime-poc-implementation-plan.md`

### Current Implementation Status

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/status/2026-04-09-react-like-runtime-poc-result.md`

### Git-Linked Reading Order

If you want the implementation story with commit linkage, read in this order:

1. `docs/status/2026-04-09-react-like-runtime-poc-result.md`
2. `git log --oneline -- demo/react_like_runtime_poc docs/status/2026-04-09-react-like-runtime-poc-result.md`

The status file above is the narrative entry point.
The git log is the implementation evidence trail behind it.
For the current keyed-move-safe PoC snapshot, start from implementation commit `3045a8a` and then read forward or backward as needed.

### Supporting Discussion And Reference

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/discussion/2026-04-08-react-like-dynamic-runtime.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/discussion/2026-04-08-fuckjs-demo-analysis.md`

### Historical Only

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/discussion/archive/2026-04-07-flutter-hot-update-technical-research.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/discussion/archive/2026-04-08-minimal-hot-update-payload-boundary.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/status/2026-04-08-minimal-hot-update-demo-result.md`

## What Is No Longer Current

These ideas should not be treated as the active route anymore:

- local JSON payload as the primary architecture
- the minimal payload boundary as a current design target
- discussion files as the main source of truth
- the standalone minimal demo as the current product direction

## Immediate Implementation Entry

If implementation starts now, the entry point is:

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/plan/2026-04-08-react-like-js-runtime-poc-plan.md`

But that plan must be interpreted under the long-term design docs, not on its own.

## Open Work

The biggest remaining work is now follow-up hardening and evolution of the first runnable PoC:

- stronger runtime negative-path coverage
- broader patch transport beyond single-parent append/remove/replace/move child updates
- richer keyed reconciliation coverage for reorder plus simultaneous insert/remove cases
- governed host bridge expansion
- remote bundle delivery and rollback

## Verification Checkpoint

The current PoC snapshot has been re-verified on 2026-04-10 with:

- `cd /Users/zyyziyunying/flutter-hot-update-lab/demo/react_like_runtime_poc/js && npm run build`
- `cd /Users/zyyziyunying/flutter-hot-update-lab/demo/react_like_runtime_poc && flutter analyze`
- `cd /Users/zyyziyunying/flutter-hot-update-lab/demo/react_like_runtime_poc && flutter test`
- `cd /Users/zyyziyunying/flutter-hot-update-lab/demo/react_like_runtime_poc && flutter build macos --profile`

## Decision Rule

When documents conflict:

- long-term design beats short-term plan
- short-term plan beats supporting discussion
- supporting discussion beats historical archive only as background context

## Related Docs

- docs root: /Users/zyyziyunying/flutter-hot-update-lab/docs/README.md
- design root: /Users/zyyziyunying/flutter-hot-update-lab/docs/design/README.md
- discussion root: /Users/zyyziyunying/flutter-hot-update-lab/docs/discussion/README.md
