# React-Like Runtime PoC Result

Status: active
Scope: Current implementation status and verification result for the first runnable React-like runtime PoC.
Source of truth: this file
Last updated: 2026-04-10

## Outcome

The repository now contains the first runnable in-repo PoC for the active React-like runtime route:

- `/Users/zyyziyunying/flutter-hot-update-lab/demo/react_like_runtime_poc`

This PoC proves the intended first implementation chain:

- a fixed Flutter host
- `flutter_js`-backed runtime session creation
- local JS bundle evaluation
- bundle metadata and required-global validation
- JS full-tree commit into Flutter
- JS minimal insert/remove/replace/move patch commit into Flutter for rerender updates
- native Flutter rendering of `View`, `Text`, and `Button`
- button press dispatch back into JS
- `useState`-driven rerender
- bundle A/B switching with visible and behavioral change
- a single-page keyed list demo that appends, removes, and reorders native `Text` rows without replacing the whole tree
- regression coverage that proves reordered keyed `Button` nodes still refresh host-visible handler ids before the next click

## What Exists

- Flutter host shell under `demo/react_like_runtime_poc/lib/src/app/`
- runtime facade and `flutter_js` integration under `demo/react_like_runtime_poc/lib/src/runtime/`
- tree schema parsing, patch application, and native rendering under `demo/react_like_runtime_poc/lib/src/render/`
- JS runtime inputs and build tooling under `demo/react_like_runtime_poc/js/`
- committed built bundle assets under `demo/react_like_runtime_poc/assets/bundles/`
- a test-only keyed-button regression bundle source at `demo/react_like_runtime_poc/js/src/apps/bundleC.tsx`

## Current Snapshot

The current in-repo PoC state is:

- initial activation still uses full-tree commit
- rerenders now support single-parent keyed `move` plus follow-up child diffing, so moved keyed children can still emit `replace` operations when props or event ids changed
- Flutter preserves keyed subtree identity with `ValueKey` wrapping during native rendering
- keyed move handling is verified at three layers:
  - JS runtime patch derivation
  - Flutter patch application
  - end-to-end bridge/runtime tests for reordered keyed buttons

## Verification

The following commands were re-run successfully on 2026-04-10 in this repository snapshot:

- `cd /Users/zyyziyunying/flutter-hot-update-lab/demo/react_like_runtime_poc/js && npm run build`
- `cd /Users/zyyziyunying/flutter-hot-update-lab/demo/react_like_runtime_poc && flutter analyze`
- `cd /Users/zyyziyunying/flutter-hot-update-lab/demo/react_like_runtime_poc && flutter test`
- `cd /Users/zyyziyunying/flutter-hot-update-lab/demo/react_like_runtime_poc && flutter build macos --profile`

The profiled macOS app bundle was produced at:

- `demo/react_like_runtime_poc/build/macos/Build/Products/Profile/react_like_runtime_poc.app`

## Current Limits

This first PoC still intentionally does not prove:

- broad patch-based tree transport beyond single-parent append/remove/replace/move child updates
- mixed keyed reorder with simultaneous insert/remove in one richer reconciliation step
- navigation bridge
- player or telemetry bridge
- remote bundle delivery
- rollback automation beyond local A/B switching
- cross-bundle state continuity

## Milestone Git History

The current PoC state was built in these milestone commits:

- `f266488` — first runnable React-like runtime PoC committed and documented
- `08b1219` — patch transport advanced from full-tree rerender toward verified patch commits
- `e9edf02` — single-page PoC extended with insert/remove child updates and list-style demo
- `3045a8a` — keyed move handling hardened so reordered keyed children can still refresh props and handler ids, with matching regression coverage

Use this status file together with `git log --oneline -- docs/status/2026-04-09-react-like-runtime-poc-result.md demo/react_like_runtime_poc` to trace implementation milestones against the current PoC snapshot.

At the time of this update, commit `3045a8a` is the implementation checkpoint that best matches the current verified PoC description in this file.

## Recommended Next Topics

The next meaningful follow-up should be one of:

- stronger runtime error surfacing and negative-path tests
- broader patch transport beyond single-parent append/remove/replace/move child updates
- richer keyed reconciliation coverage for reorder plus simultaneous insert/remove cases
- governed host bridge expansion for selected business capabilities
- remote bundle delivery, integrity verification, and rollback
