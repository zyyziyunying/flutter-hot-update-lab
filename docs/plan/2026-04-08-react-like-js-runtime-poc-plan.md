# React-Like JS Runtime PoC Plan

Status: active
Scope: Execution plan for the first serious proof of concept of JS runtime to Flutter native widget mapping in this repository.
Source of truth: this file
Last updated: 2026-04-09

## Context

This plan is subordinate to the canonical long-term design set.
If this file conflicts with a long-term design file, the long-term design wins and this plan must be updated.

Read and interpret this plan under these active design documents:

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/flutter-hot-update-react-like-direction.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-long-term-overview.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-long-term-architecture.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-host-bridge-governance.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-bundle-lifecycle.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-bundle-and-tree-contract.md`

The repository no longer treats the JSON payload demo route as the target architecture.
The next meaningful implementation step is a direct proof of the real chain:

- JS bundle execution inside a fixed Flutter host
- React-like component and state model
- JS-produced tree mapped to native Flutter widgets
- bundle replacement causing visible and behavioral change without host Dart code changes

## Requirements Summary

Build a first PoC that proves these points:

- the Flutter host stays fixed
- the host can load and execute a JS bundle in a release-capable Flutter environment
- the JS side can define UI with a minimal React-like component model
- the JS side can hold state and update it through event callbacks
- Flutter renders native widgets from JS-produced structure rather than using a WebView
- replacing bundle A with bundle B changes both UI and behavior without modifying host Dart code

This PoC is about runtime feasibility, not production readiness.

## Acceptance Criteria

- A new standalone Flutter demo exists under `demo/react_like_runtime_poc`.
- The demo runs on macOS first.
- The host embeds a JS runtime and can evaluate a local bundled JS entry.
- The host validates bundle metadata before bootstrap.
- The JS runtime can trigger a Flutter-side commit with a serialized element tree.
- Flutter can render at least `View`, `Text`, and `Button` as native widgets.
- Flutter can send button press events back into the JS runtime.
- The JS side supports one minimal hook-style state capability such as `useState`.
- Two JS bundles exist and produce clearly different UI and behavior.
- The host can switch bundles and reload them without changing Dart host code.
- The result is verified with `flutter analyze`, `flutter test`, `flutter build macos --profile`, and at least one production-like macOS runtime validation such as `flutter run -d macos --profile` or launching the built macOS app artifact.

## Implementation Decisions

### 1. Platform Scope For The First PoC

Start with macOS only.

Why:

- the lab already runs on macOS
- the first goal is to prove the runtime chain locally with the shortest loop
- cross-platform hardening should wait until the core loop is real

### 2. Runtime Baseline

Use `flutter_js` as the fixed runtime baseline for the first PoC.

Why:

- it is a Flutter package rather than a Dart-only engine binding
- it is the shortest path to a working macOS proof in the current lab
- the first task is to prove the runtime chain, not to de-risk every future engine swap in advance
- the current risk profile looks lower than starting directly from a lower-level QuickJS binding

Constraint for this phase:

- only one implementation slice may directly depend on `flutter_js`
- tree schema, bundle contract, and renderer behavior must stay independent from package-specific APIs

Bundle compatibility rule for this phase:

- each built bundle is a host-loaded script asset
- each bundle must expose metadata and runtime globals required by `react-like-runtime-bundle-and-tree-contract.md`
- the host must reject incompatible bundle ABI or tree schema versions before bootstrap

This PoC does not attempt to validate engine portability.
It validates the architecture with `flutter_js` as the chosen first host runtime.

### 3. Rendering Protocol

Use full-tree commits for the first PoC, not diff patches.

Why:

- the first risk is correctness of the runtime loop, not incremental performance
- full-tree snapshots are easier to debug
- diff and patch design can wait until the basic architecture is proven

### 4. UI Capability Boundary

Support only a very small native widget set:

- `View`
- `Text`
- `Button`

First-pass style subset:

- `padding`
- `backgroundColor`
- `textColor`
- `fontSize`

Do not add navigation, networking, lists, text input, or general host services in the first PoC.

### 5. State And Events

Support only:

- local component state through one `useState`-style hook
- button press callbacks

This is enough to prove rerender and behavior change without opening a large host bridge.

## Proposed Repository Shape

Create a new demo app:

- `demo/react_like_runtime_poc/`

Inside that app, use these implementation slices:

- `lib/main.dart`
- `lib/src/app/poc_shell.dart`
- `lib/src/runtime/flutter_js_runtime.dart`
- `lib/src/runtime/runtime_bridge.dart`
- `lib/src/runtime/bundle_loader.dart`
- `lib/src/render/element_node.dart`
- `lib/src/render/element_parser.dart`
- `lib/src/render/flutter_widget_factory.dart`
- `lib/src/render/render_view.dart`
- `assets/bundles/bundle_a.js`
- `assets/bundles/bundle_b.js`
- `js/package.json`
- `js/tsconfig.json`
- `js/esbuild.config.mjs`
- `js/src/runtime/createElement.ts`
- `js/src/runtime/hooks.ts`
- `js/src/runtime/renderer.ts`
- `js/src/apps/bundleA.tsx`
- `js/src/apps/bundleB.tsx`

The JS sources should be build inputs.
The built bundle files under `assets/bundles/` should be host load targets.

For the first PoC:

- built `assets/bundles/*.js` files are committed artifacts
- bundle rebuild is an explicit developer step before Flutter verification runs
- the repository should provide one documented command to rebuild bundle assets from `js/`

## Runtime Architecture

### Flutter Host Side

The Flutter host should own:

- runtime creation and disposal through the `flutter_js` integration
- bundle loading
- tree commit reception
- tree parsing and widget rebuild
- active runtime session reference
- event dispatch by `handlerId` back into JS
- bundle switching and reload controls
- promotion of the visible tree, active session reference, and committed event-binding data only after a tree commit is accepted

### JS Side

The JS side should own:

- component execution
- state storage for the current runtime session
- element creation
- rerender scheduling
- event handler registration
- `handlerId -> callback` lookup state for the active runtime session
- serialization of the current rendered tree

### Bridge Contract

The first PoC bridge should stay minimal.

JS to Flutter:

- `commitTree(serializedTree): { ok: true } | { ok: false, reason: string }`
- `log(level, message)`

Host to JS runtime session:

- evaluate bundle script source
- call `globalThis.__poc_bootstrap(host)`
- call `globalThis.__poc_dispatch_event(handlerId, payload)` on UI events
- on bundle switch, keep the old session active until the candidate session has loaded, bootstrapped, and committed an accepted initial tree

Event handlers should be represented as runtime-managed ids, not as direct native callback objects.
The host must never copy JS callback objects or own the callback lookup table directly.
Each successful accepted commit promotes the visible tree, the active session reference, and the committed handler-binding data together.
If a commit is rejected, the host keeps the previously active visible tree, session reference, and handler-binding data, while the JS runtime keeps serving callbacks from the last successfully committed callback lookup table in that session.
The host must treat the visible tree, active runtime session, and committed handler-binding data as one atomic active snapshot.

## Verification Gate

The PoC exit criteria must prove a production-like macOS path, not only a debug development loop.

Required verification set:

- `flutter analyze`
- `flutter test`
- `flutter build macos --profile`
- one production-like runtime validation on macOS, such as `flutter run -d macos --profile` or launching the built app artifact after the profile build

`flutter build macos --debug` may still be useful during development, but it does not satisfy the PoC exit criteria on its own.

## Execution Flow

### Boot

1. Flutter starts the host app.
2. Flutter creates one JS runtime session.
3. Flutter loads `bundle_a.js` from assets.
4. Flutter evaluates the bundle script.
5. Flutter validates `__poc_bundle_meta` and required globals.
6. Flutter injects the host object and calls `globalThis.__poc_bootstrap(host)`.
7. JS renders the root component and calls `commitTree(...)`.
8. Flutter parses the tree and builds native widgets.

### Interaction

1. The user presses a Flutter button.
2. Flutter looks up the handler id attached to that button node.
3. Flutter calls `globalThis.__poc_dispatch_event(handlerId, payload)` into JS.
4. JS updates state through the minimal hook runtime.
5. JS rerenders and sends a new full tree through `commitTree(...)`.
6. Flutter rebuilds from the new tree.

### Bundle Replacement

1. The host selects bundle B.
2. Flutter keeps the current bundle A session active and visible.
3. Flutter creates a fresh candidate runtime session for bundle B.
4. Flutter loads and evaluates `bundle_b.js` in that candidate session.
5. Flutter validates `__poc_bundle_meta` and required globals before treating bundle B as activatable.
6. Flutter calls `globalThis.__poc_bootstrap(host)` in the candidate session.
7. JS commits an initial tree for bundle B.
8. Flutter validates that tree.
9. Only after validation succeeds does Flutter promote bundle B, render the new result, and dispose bundle A.
10. If any step fails, Flutter discards the candidate session, keeps bundle A active, and surfaces a readable error.

## Implementation Steps

### 1. Create The New PoC App

- scaffold `demo/react_like_runtime_poc`
- keep it isolated from `demo/minimal_hot_update_demo`
- wire macOS support from the start

Expected result:

- a clean Flutter app dedicated to the runtime PoC

### 2. Integrate The JS Runtime Layer

- add the runtime dependency
- keep all direct `flutter_js` usage inside `flutter_js_runtime.dart`
- expose only the small PoC operations needed by the rest of the host
- define one small injectable runtime facade so widget tests can use a fake runtime instead of real `flutter_js`
- centralize active-snapshot promotion so session reference, visible tree, and committed event-binding data switch together

Expected result:

- Flutter can evaluate raw JS and receive bridge callbacks
- widget tests are not blocked on the desktop JS engine

### 3. Implement The Tree Commit Bridge

- define the serialized element node format
- define the bundle metadata validation path
- implement JS-side `commitTree` result handling
- implement Flutter-side parsing into `ElementNode`
- make `commitTree(...)` return `{ ok: true }` or `{ ok: false, reason }` instead of acting as fire-and-forget transport

Expected result:

- JS can send a complete render tree into Flutter
- the host can reject incompatible bundles before bootstrap

### 4. Implement The Native Widget Renderer

- map `View` to a Flutter layout container
- map `Text` to Flutter `Text`
- map `Button` to Flutter button widgets
- attach event handler ids to rendered button nodes

Expected result:

- Flutter can display a fully native UI from JS-produced structure

### 5. Implement Minimal React-Like Runtime Pieces

- `createElement`
- one function-component execution path
- one `useState`-style hook
- rerender on state change

Expected result:

- JS bundles can define interactive components with local state

### 6. Add Bundle Tooling And Two Demo Bundles

- add a tiny TypeScript and build setup
- build bundle A and bundle B into Flutter assets
- make bundle A and bundle B differ in both copy and interaction behavior
- document the bundle rebuild command used before Flutter verification

Expected result:

- the host can switch between two distinct business bundles

### 7. Add Verification And Debuggability

- add unit tests for tree parsing and bridge behavior
- add widget tests for host rendering and bundle swap
- add tests for bundle metadata validation and version mismatch rejection
- add tests for unknown node type rejection
- add tests for invalid children rejection
- add tests for invalid event rejection
- add tests for event handler error surfacing
- add tests for callback lookup replacement after rerender inside the active session
- add tests that rejected rerenders keep the previous committed event-binding data and callback lookup state active
- add tests that failed bundle activation keeps the current session alive
- add tests that snapshot promotion swaps tree, session, and committed event-binding data together
- log JS exceptions and surface them in the host UI

Expected result:

- the PoC is inspectable rather than opaque

## Risks And Mitigations

### Risk: The Runtime Package Is Easy To Demo But Hard To Control

Mitigation:

- keep all direct package usage in one file
- keep the public bridge contract package-agnostic

### Risk: The JS To Flutter Boundary Becomes Too Loose

Mitigation:

- define one explicit tree schema
- keep node types and style fields tightly capped

### Risk: Event Identity And State Retention Become Confusing

Mitigation:

- use runtime-generated handler ids
- keep one root page and one runtime session in the first pass

### Risk: Full-Tree Commits Look Slow

Mitigation:

- accept that cost for the first PoC
- defer patch transport until correctness is proven

### Risk: The PoC Quietly Slides Back Into A Schema Demo

Mitigation:

- require `useState` and JS event callbacks in the first pass
- reject any implementation that only swaps static tree data

## Verification Steps

- Run `flutter analyze` inside `demo/react_like_runtime_poc`.
- Run `flutter test` inside `demo/react_like_runtime_poc`.
- Run the documented JS bundle rebuild command and confirm `assets/bundles/*.js` are up to date.
- Run `flutter build macos --profile` inside `demo/react_like_runtime_poc`.
- Run one production-like macOS path such as `flutter run -d macos --profile` or launch the built app artifact after the profile build.
- Confirm bundle A renders native Flutter widgets from JS.
- Press the interactive control and confirm JS state updates rerender the UI.
- Confirm `commitTree(...)` returns an acceptance result to JS instead of acting as fire-and-forget transport.
- Confirm a successful rerender replaces the active callback lookup state inside the session, and old handler ids are rejected only after the new tree is accepted.
- Trigger an invalid rerender and confirm the previous UI, committed event-binding data, and callback lookup state remain active.
- Switch to bundle B and confirm both UI and behavior change without host Dart edits.
- Intentionally break bundle B bootstrap or initial tree validation and confirm bundle A stays active.
- Confirm bundle promotion never exposes a mixed snapshot of new tree, old session, or stale committed event-binding data.
- Try a bundle with incompatible `runtimeAbiVersion` or `treeSchemaVersion` and confirm the host rejects it before bootstrap.
- Try a tree with an unknown node type and confirm the host rejects it with a readable error.
- Try an invalid child shape for `Text` or `Button` and confirm the host rejects it with a readable error.
- Try an invalid event field and confirm the host rejects it with a readable error.
- Trigger an event handler error and confirm the host surfaces it while keeping the last valid tree.
- Intentionally break one bundle and confirm the host surfaces a readable runtime error.

## Exit Conditions

This plan is complete when:

- the repository has a working macOS PoC for the accepted architecture
- the PoC proves JS runtime execution, native Flutter rendering, and event-driven rerender
- the team can judge whether to continue toward patch transport, richer components, and remote bundle delivery

## Follow-Up After Completion

If this PoC works, the next planning topic should be one of:

- patch-based tree updates instead of full-tree commits
- host bridge expansion for selected real business services
- remote bundle loading, signature verification, and rollback
- page routing and mixed dynamic/native navigation
