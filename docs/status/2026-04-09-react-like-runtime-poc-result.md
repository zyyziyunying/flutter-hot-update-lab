# React-Like Runtime PoC Result

Status: active
Scope: Current implementation status and verification result for the first runnable React-like runtime PoC.
Source of truth: this file
Last updated: 2026-04-09

## Outcome

The repository now contains the first runnable in-repo PoC for the active React-like runtime route:

- `/Users/zyyziyunying/flutter-hot-update-lab/demo/react_like_runtime_poc`

This PoC proves the intended first implementation chain:

- a fixed Flutter host
- `flutter_js`-backed runtime session creation
- local JS bundle evaluation
- bundle metadata and required-global validation
- JS full-tree commit into Flutter
- JS minimal replace-patch commit into Flutter for rerender updates
- native Flutter rendering of `View`, `Text`, and `Button`
- button press dispatch back into JS
- `useState`-driven rerender
- bundle A/B switching with visible and behavioral change

## What Exists

- Flutter host shell under `demo/react_like_runtime_poc/lib/src/app/`
- runtime facade and `flutter_js` integration under `demo/react_like_runtime_poc/lib/src/runtime/`
- tree schema parsing, patch application, and native rendering under `demo/react_like_runtime_poc/lib/src/render/`
- JS runtime inputs and build tooling under `demo/react_like_runtime_poc/js/`
- committed built bundle assets under `demo/react_like_runtime_poc/assets/bundles/`

## Verification

The following commands were re-run successfully on 2026-04-09 in this repository snapshot:

- `cd /Users/zyyziyunying/flutter-hot-update-lab/demo/react_like_runtime_poc/js && npm ci`
- `cd /Users/zyyziyunying/flutter-hot-update-lab/demo/react_like_runtime_poc/js && npm run build`
- `cd /Users/zyyziyunying/flutter-hot-update-lab/demo/react_like_runtime_poc && flutter analyze`
- `cd /Users/zyyziyunying/flutter-hot-update-lab/demo/react_like_runtime_poc && flutter test`
- `cd /Users/zyyziyunying/flutter-hot-update-lab/demo/react_like_runtime_poc && flutter build macos --profile`

The profiled macOS app bundle was produced at:

- `demo/react_like_runtime_poc/build/macos/Build/Products/Profile/react_like_runtime_poc.app`

## Current Limits

This first PoC still intentionally does not prove:

- broad patch-based tree transport beyond single replace operations
- navigation bridge
- player or telemetry bridge
- remote bundle delivery
- rollback automation beyond local A/B switching
- cross-bundle state continuity
- GUI launch was not re-executed in this documentation update pass

## Recommended Next Topics

The next meaningful follow-up should be one of:

- stronger runtime error surfacing and negative-path tests
- broader patch transport beyond single replace operations
- governed host bridge expansion for selected business capabilities
- remote bundle delivery, integrity verification, and rollback
