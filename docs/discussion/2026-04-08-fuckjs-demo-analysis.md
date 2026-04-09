# fuckjs_demo Open-Source Project Analysis

Status: supporting-reference
Scope: Supporting external reference analysis used to inform the React-like runtime direction in this repository.
Source of truth: this file
Last updated: 2026-04-09

## Reader Note

This file is a reference analysis, not a canonical architecture decision document.

The repository's stable direction now lives in the design set under:

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/`

## Context

The current project direction is a fixed Flutter host plus a controlled dynamic business layer.
To sharpen that direction, it is useful to inspect external projects that already attempt JS-driven or runtime-driven Flutter dynamic execution.

`fuckjs_demo` was analyzed as a reference case.

## Project Snapshot

The project is not aiming at unrestricted Flutter or Dart release-code hot update.
Its practical shape is closer to:

- a fixed Flutter host
- a QuickJS-based runtime
- a React-like JS business layer
- a Flutter-side renderer and service bridge

The demo application acts as a host shell that loads named JS business bundles such as `bundle` and `taro-demo`.

## Current Understanding

The most important takeaway is that this project is not "replace the whole Flutter app after release".
It is "keep the host fixed, then make the business layer dynamic through JS runtime and controlled Native services".

That means its real dynamic target is:

- page composition
- route registration
- business interaction flow
- state handling
- host capability invocation

Rather than:

- full Flutter engine replacement
- arbitrary native capability replacement
- deep media or platform-core hot swapping

## Observed Execution Chain

### 1. Flutter Host Startup

The host app starts in `app/lib/main.dart`.
It preheats the runtime with `EngineInit.initIsolate()` and routes business pages into `FuickAppPage`.

The host home page can open JS apps by passing values such as:

- `appName: 'bundle'`
- `appName: 'taro-demo'`

### 2. Flutter Container Handoff

`FuickAppPage` is a thin bridge into `FuickAppView`.
This suggests the real runtime container is the Flutter-side framework package, not the demo app itself.

The checked-out repository does not contain the full implementation of:

- `FuickAppView`
- the actual JS loader and executor
- Flutter-side widget parsing
- the Native service manager

So the last hop of execution is inferred from the demo code, assets, and usage docs rather than directly verified from the missing framework source.

### 3. JS Bundle Entry

The JS business entry is `js/src/index.ts`.
It exposes `initApp` on `globalThis` and also invokes it immediately.

Then `js/src/app.ts` performs:

- `Runtime.bindGlobals()`
- route registration through `Router.register(...)`
- global error fallback registration

This indicates the runtime expects a host-prepared JS environment and then bootstraps a business application inside it.

### 4. Bundle Form

The Flutter app ships bundle assets such as:

- `assets/js/bundle.js`
- `assets/js/bundle.qjc`
- `assets/js/taro-demo.js`
- `assets/js/taro-demo.qjc`

This implies two important design choices:

- business code is packaged as a versioned bundle unit
- release delivery can use precompiled QuickJS bytecode instead of plain source only

### 5. JS To Native Bridge

The usage doc defines a string-based service call convention:

`dartCallNative('ServiceName.MethodName', args)`

Observed and documented service surfaces include categories such as:

- `UI.*`
- `Navigator.*`
- `Network.*`
- `Timer.*`
- `NativeEvent.*`

A custom wallet example also exists, which confirms the bridge is meant to be extensible rather than limited to a tiny built-in API surface.

### 6. Hybrid Navigation

The demo explicitly supports navigation between JS pages and Flutter native pages.
This is important because it shows the dynamic runtime is not forced into an isolated full-screen sandbox.

The JS layer can:

- push another JS page
- push a Flutter page
- receive a result from that Flutter page
- pop and return data back upward

## Why This Project Is Valuable To Study

### Clear Dynamic Boundary

The project does not attempt the hardest possible target first.
It keeps the host shell stable and pushes higher-level business behavior into a dynamic layer.

This is strategically close to the direction already being discussed in this repository.

### Host Capabilities Are Service-Shaped

The JS layer does not directly manipulate arbitrary Flutter internals.
Instead, it talks to named host services.

This is valuable because a service boundary is much easier to reason about in terms of:

- permissions
- compatibility
- deprecation
- fallback
- observability

### Bundle Is The Delivery Unit

The project naturally treats a business bundle as the runtime unit.
That is more operationally useful than thinking in terms of random script fragments.

A bundle unit maps better to:

- versioning
- rollout
- rollback
- environment targeting
- compatibility checks

### Mixed Stack Operation Is Proven Useful

The hybrid navigation demo is not just a nice extra.
It proves the runtime layer can coexist with native pages instead of replacing the entire app shell.

That makes phased adoption more realistic.

### Incremental Update Direction Exists

The project includes explicit patch-oriented demo work such as `PatchOps`.
That suggests the authors are not thinking only in terms of full rerender cycles.

Even without all missing framework source, this still hints at a practical concern for:

- incremental updates
- node-level changes
- performance-sensitive reconciliation

## Limits And Risks Seen In This Reference

### The Runtime Stack Is Heavy

This route is powerful, but the engineering burden is also large.
To reproduce it cleanly, one must own and maintain:

- JS runtime integration
- bundle compilation flow
- Flutter renderer mapping
- widget registry
- service bridge protocol
- debugging and observability tools
- compatibility and rollout rules

This is far heavier than a rule-tree or finite-state-machine based business-shell model.

### The Repository Is Incomplete As A Reference

The demo app depends on local framework packages that are not present in the checked-out repository.
So the most critical implementation details are missing from direct inspection.

This limits confidence in conclusions about:

- rendering internals
- host API enforcement
- lifecycle handling
- memory model
- error isolation

### Bridge Typing Is Weak

The string convention `ServiceName.MethodName` is simple and flexible, but it is also easy to make unsafe or brittle if not strongly governed.

Without additional policy layers, this kind of bridge can become hard to control across:

- version upgrades
- argument validation
- capability exposure
- auditability

### Security And Governance Are Not Yet Evident

From the analyzed demo surface, there is not yet enough evidence of a production-grade system for:

- bundle signing
- trust verification
- permission scoping
- staged rollback rules
- crash containment

These areas matter much more once the runtime stops being a local demo and starts carrying real business logic.

### Build Reproducibility Looks Weak In The Current Checkout

The checked `js/esbuild.js` file appears structurally damaged in this local clone and is not a clean build-script reference in its current form.
So the repository should not be treated as a ready-to-reuse engineering template.

## Implications For This Repository

This reference strengthens several current intuitions:

- fixed host plus dynamic business layer is a realistic direction
- bundle-level delivery is a useful mental model
- host API boundary should be explicit and service-oriented
- hybrid navigation between dynamic and native surfaces is worth preserving

At the same time, this reference also suggests caution:

- do not jump straight to the heaviest runtime shape unless the business problem truly requires it
- do not confuse expressive power with the best first implementation step
- do not adopt a broad dynamic execution surface before defining compatibility and rollback constraints

## Provisional Conclusion

`fuckjs_demo` is useful less as a direct code template and more as an architectural signal.

The most transferable lessons are:

- dynamic business layers work best with a fixed host
- the host/dynamic boundary should be intentionally narrow and service-shaped
- bundle delivery is a better operational unit than ad hoc script updates
- mixed dynamic and native navigation should be treated as a first-class capability

The least transferable part is the full weight of a JS-driven UI runtime.
For this lab, that may be too heavy as an initial target unless later validation proves that lighter business-logic models cannot carry the real player-shell requirements.

## Follow-up

- Compare this reference against the current `React-like dynamic runtime` discussion in this repository.
- Extract a first draft of the host capability boundary that our own business shell would need.
- Decide whether the next validation step should focus on:
  - constrained business orchestration first
  - or a minimal runtime proof of concept first
