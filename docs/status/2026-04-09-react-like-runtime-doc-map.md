# React-Like Runtime Doc Map

Status: active
Scope: Current document map and reading guide for the active React-like runtime direction in this repository.
Source of truth: this file
Last updated: 2026-04-09

## Current State

The repository has finished a large documentation realignment.

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

The biggest remaining work is no longer document structure.
It is implementation of:

- `demo/react_like_runtime_poc`
- JS runtime integration with `flutter_js`
- first React-like runtime loop
- first native renderer

## Decision Rule

When documents conflict:

- long-term design beats short-term plan
- short-term plan beats supporting discussion
- supporting discussion beats historical archive only as background context

## Related Docs

- docs root: /Users/zyyziyunying/flutter-hot-update-lab/docs/README.md
- design root: /Users/zyyziyunying/flutter-hot-update-lab/docs/design/README.md
- discussion root: /Users/zyyziyunying/flutter-hot-update-lab/docs/discussion/README.md
