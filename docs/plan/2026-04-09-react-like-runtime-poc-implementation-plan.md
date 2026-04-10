# React-Like Runtime PoC Implementation Plan

Status: implemented in the current repository snapshot
Scope: Task-by-task implementation checklist for the first runnable `demo/react_like_runtime_poc`
Source of truth: `/Users/zyyziyunying/flutter-hot-update-lab/docs/status/2026-04-09-react-like-runtime-poc-result.md`
Last updated: 2026-04-10

**Goal:** Build the first runnable `demo/react_like_runtime_poc` that proves JS bundle execution, native Flutter rendering, `onPress` event dispatch, `useState` rerender, and bundle A/B switching without host Dart code changes.

**Architecture:** Create a standalone Flutter macOS demo with a narrow runtime facade, a host-owned tree parser and native widget renderer, and a tiny JS runtime contract that exposes `__poc_bundle_meta`, `__poc_bootstrap(host)`, and `__poc_dispatch_event(handlerId, payload)`. Keep the first slice intentionally narrow: `View`, `Text`, `Button`, full-tree commit, local asset bundles, and one `useState`-style hook.

**Tech Stack:** Flutter 3.41, Dart 3.11, `flutter_js`, Flutter widget tests, TypeScript, TSX, esbuild

## Acceptance Hold Points

This implementation plan is not only a build checklist.
At a few points, work should pause for a short manual macOS acceptance check before moving on.

These hold points are intentionally small.
They exist to confirm real runtime behavior at the moments most likely to hide false confidence.

### Hold Point 1: After Real Runtime Wiring

Trigger point:

- after Task 8 is complete enough that the app starts from real bundle assets instead of only fakes

Manual acceptance:

- run the macOS app in a production-like path
- verify bundle A cold boots successfully
- verify the first visible UI is the expected native Flutter screen

This is the first point where the repository should claim that the JS-to-native runtime chain exists outside tests.

### Hold Point 2: After First Real Interaction Loop

Trigger point:

- after Task 8 and before final sign-off in Task 9

Manual acceptance:

- press a bundle A button such as add or remove
- verify the UI changes after the press
- verify the change reflects JS state-driven rerender in the native Flutter tree

This is the point where event dispatch and `useState` rerender become manually proven rather than only test-covered.

### Hold Point 3: After List Reorder Capability Exists

Trigger point:

- after the implementation snapshot includes the single-page keyed list reorder path

Manual acceptance:

- trigger the reorder action in bundle A
- verify the visible order changes on macOS
- verify the screen remains stable after the reorder

This hold point is specifically for the current keyed list update slice.
It is not part of the original minimum runnable PoC baseline unless the active snapshot explicitly includes that reorder capability.
It should be repeated if reorder handling semantics materially change later.

### Hold Point 4: Before PoC Completion Claim

Trigger point:

- during Task 9 full verification

Manual acceptance:

- switch from bundle A to bundle B
- verify both UI text and button behavior change
- if available, switch back and confirm bundle A behavior returns

This is the final manual proof that bundle replacement works without changing host Dart code.

---

### Task 1: Scaffold The Demo App

**Files:**
- Create: `demo/react_like_runtime_poc/`
- Modify: `README.md`

**Step 1: Create the Flutter app**

Run: `flutter create demo/react_like_runtime_poc --platforms=macos`

**Step 2: Verify the generated app builds**

Run: `cd demo/react_like_runtime_poc && flutter analyze`
Expected: generated app analyzes cleanly before feature work starts

**Step 3: Document the new active demo path**

Update the repository `README.md` so the active implementation path no longer points at a non-existent directory.

### Task 2: Add Runtime Dependencies And Testable Boundaries

**Files:**
- Modify: `demo/react_like_runtime_poc/pubspec.yaml`
- Create: `demo/react_like_runtime_poc/lib/src/runtime/runtime_facade.dart`
- Create: `demo/react_like_runtime_poc/lib/src/runtime/flutter_js_runtime.dart`
- Create: `demo/react_like_runtime_poc/lib/src/runtime/bundle_loader.dart`

**Step 1: Add runtime dependency**

Run: `cd demo/react_like_runtime_poc && flutter pub add flutter_js`

**Step 2: Define a narrow runtime facade**

Expose only the operations the host needs now:

- create and dispose a runtime session
- evaluate one bundle script
- call `__poc_bootstrap`
- dispatch `handlerId` events back into JS

**Step 3: Keep `flutter_js` isolated**

All direct `flutter_js` API usage stays in `flutter_js_runtime.dart`.
The rest of the host depends only on the facade so tests can use fakes.

### Task 3: Write Parser Tests First

**Files:**
- Create: `demo/react_like_runtime_poc/test/render/element_parser_test.dart`
- Create: `demo/react_like_runtime_poc/lib/src/render/element_node.dart`
- Create: `demo/react_like_runtime_poc/lib/src/render/element_parser.dart`

**Step 1: Write failing tests**

Cover:

- valid `View/Text/Button` parsing
- unknown node type rejection
- invalid child rules for `Text` and `Button`
- invalid event field rejection

**Step 2: Run the parser tests and watch them fail**

Run: `cd demo/react_like_runtime_poc && flutter test test/render/element_parser_test.dart`
Expected: fail because parser types do not exist yet

**Step 3: Implement the minimal parser**

Add only the fields required by the current PoC contract.

**Step 4: Re-run the parser tests**

Run: `cd demo/react_like_runtime_poc && flutter test test/render/element_parser_test.dart`
Expected: pass

### Task 4: Write Bundle Contract Tests First

**Files:**
- Create: `demo/react_like_runtime_poc/test/runtime/bundle_loader_test.dart`
- Modify: `demo/react_like_runtime_poc/lib/src/runtime/bundle_loader.dart`

**Step 1: Write failing tests**

Cover:

- required globals present
- valid metadata accepted
- incompatible `runtimeAbiVersion` rejected
- incompatible `treeSchemaVersion` rejected

**Step 2: Run the bundle loader tests and watch them fail**

Run: `cd demo/react_like_runtime_poc && flutter test test/runtime/bundle_loader_test.dart`
Expected: fail because loader validation is incomplete

**Step 3: Implement minimal validation**

Keep the validation limited to the current PoC contract.

**Step 4: Re-run the bundle loader tests**

Run: `cd demo/react_like_runtime_poc && flutter test test/runtime/bundle_loader_test.dart`
Expected: pass

### Task 5: Write Host Rendering Widget Test First

**Files:**
- Create: `demo/react_like_runtime_poc/test/app/poc_shell_test.dart`
- Create: `demo/react_like_runtime_poc/lib/src/app/poc_shell.dart`
- Create: `demo/react_like_runtime_poc/lib/src/render/flutter_widget_factory.dart`
- Create: `demo/react_like_runtime_poc/lib/src/render/render_view.dart`

**Step 1: Write failing widget tests**

Cover:

- initial bundle A tree renders as native Flutter widgets
- button press dispatches a handler id into the runtime
- accepted rerender updates visible text
- bundle switch to B changes both UI copy and interaction result

**Step 2: Run the widget tests and watch them fail**

Run: `cd demo/react_like_runtime_poc && flutter test test/app/poc_shell_test.dart`
Expected: fail because shell and renderer are missing

**Step 3: Implement the minimal shell and renderer**

Keep the host state narrow:

- active runtime session reference
- current parsed tree
- committed event-binding data
- readable error state

**Step 4: Re-run the widget tests**

Run: `cd demo/react_like_runtime_poc && flutter test test/app/poc_shell_test.dart`
Expected: pass

### Task 6: Add Runtime Bridge And Fake Runtime For Tests

**Files:**
- Create: `demo/react_like_runtime_poc/lib/src/runtime/runtime_bridge.dart`
- Create: `demo/react_like_runtime_poc/test/support/fake_runtime_facade.dart`
- Modify: `demo/react_like_runtime_poc/lib/src/app/poc_shell.dart`

**Step 1: Write failing tests for snapshot promotion**

Extend the widget tests or add a focused test for:

- accepted commit promotes tree and handler ids together
- rejected rerender keeps previous tree and handler ids active
- failed bundle B activation keeps bundle A visible

**Step 2: Run the affected tests and watch them fail**

Run: `cd demo/react_like_runtime_poc && flutter test`
Expected: fail because active snapshot handling is incomplete

**Step 3: Implement runtime bridge and snapshot promotion**

Use one atomic active snapshot model matching the design contract.

**Step 4: Re-run the full test suite**

Run: `cd demo/react_like_runtime_poc && flutter test`
Expected: pass

### Task 7: Add JS Runtime Sources And Build Inputs

**Files:**
- Create: `demo/react_like_runtime_poc/js/package.json`
- Create: `demo/react_like_runtime_poc/js/tsconfig.json`
- Create: `demo/react_like_runtime_poc/js/esbuild.config.mjs`
- Create: `demo/react_like_runtime_poc/js/src/runtime/createElement.ts`
- Create: `demo/react_like_runtime_poc/js/src/runtime/hooks.ts`
- Create: `demo/react_like_runtime_poc/js/src/runtime/renderer.ts`
- Create: `demo/react_like_runtime_poc/js/src/apps/bundleA.tsx`
- Create: `demo/react_like_runtime_poc/js/src/apps/bundleB.tsx`
- Create: `demo/react_like_runtime_poc/assets/bundles/bundle_a.js`
- Create: `demo/react_like_runtime_poc/assets/bundles/bundle_b.js`

**Step 1: Create JS source inputs**

Implement only:

- `createElement`
- one root render loop
- one `useState`
- handler registration
- bundle A and bundle B apps

**Step 2: Add build script**

Provide one documented command that rebuilds committed bundle assets from `js/`.

**Step 3: Build the first committed bundle artifacts**

Run the build command and confirm the generated assets exist under `assets/bundles/`.

### Task 8: Wire The Real Runtime To The Real Bundles

**Files:**
- Modify: `demo/react_like_runtime_poc/lib/main.dart`
- Modify: `demo/react_like_runtime_poc/lib/src/app/poc_shell.dart`
- Modify: `demo/react_like_runtime_poc/pubspec.yaml`

**Step 1: Register bundle assets**

Add the built bundle files to Flutter assets.

**Step 2: Switch the app from fake runtime tests to real runtime wiring**

Start bundle A on launch and expose a bundle B switch control.

**Step 3: Verify the app still satisfies the tests**

Run: `cd demo/react_like_runtime_poc && flutter test`
Expected: pass with the real bundle assets present

**Step 4: Run Hold Point 1 and Hold Point 2**

Do a short macOS manual check before treating the real runtime wiring as complete:

- verify bundle A cold boot
- verify one real interaction updates the native UI

### Task 9: Run Full Verification

**Files:**
- Modify: `demo/react_like_runtime_poc/README.md`
- Modify: `README.md`

**Step 1: Document the bundle rebuild and verification commands**

Include:

- JS rebuild command
- `flutter analyze`
- `flutter test`
- `flutter build macos --profile`

**Step 2: Run verification**

Run:

- `cd demo/react_like_runtime_poc && flutter analyze`
- `cd demo/react_like_runtime_poc && flutter test`
- `cd demo/react_like_runtime_poc && flutter build macos --profile`

**Step 3: Record any gaps honestly**

**Step 4: Run Hold Point 3 and Hold Point 4 as applicable**

Before claiming the PoC milestone is complete, manually confirm on macOS:

- if the current snapshot includes the reorder slice, the reorder path produces the expected visible effect
- bundle A/B switching changes both UI and behavior

If macOS runtime launch cannot be completed in this session, say so clearly.

## Current Snapshot Note

The implementation described in this plan now exists in the repository.
Use the status result file for the current verification checkpoint and remaining follow-up work:

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/status/2026-04-09-react-like-runtime-poc-result.md`
