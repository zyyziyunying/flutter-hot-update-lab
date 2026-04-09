# Flutter Hot Update React-Like Direction

Status: active
Scope: Current stable direction for the Flutter hot update architecture in this repository.
Source of truth: this file
Last updated: 2026-04-08

## Context

The project is not trying to reproduce Flutter debug hot reload in production.
Release Flutter apps run compiled Dart code, so the target is not Dart AOT code replacement.

The real goal is to achieve a production-side hot-update effect for selected business surfaces by shipping a preinstalled runtime boundary inside a fixed Flutter host.

## Problem Statement

The repository needs a direction that can:

- change business UI and behavior after release
- preserve a fixed Flutter host and native capability layer
- feel closer to front-end runtime development than to static schema configuration
- avoid pretending that release Dart code itself can be replaced dynamically

## Stable Conclusions

- True arbitrary Flutter or Dart release-code hot update is not the target direction.
- The target effect should come from replacing dynamic bundles executed inside a preinstalled runtime boundary.
- The dynamic layer should be closer to a React-like component runtime than to a narrow JSON payload schema.
- The output of the dynamic layer should be mapped to native Flutter widgets rather than rendered through a WebView.
- Bundle delivery is the right operational unit for versioning, compatibility, rollout, and rollback.

## Chosen Architectural Direction

Use:

- a fixed Flutter host shell
- a fixed native or Flutter-side player core
- an embedded JavaScript runtime such as QuickJS, JavaScriptCore, or an equivalent controlled engine
- a React-like business runtime with component functions, state, and event handling
- a Flutter-side renderer that maps JS-produced tree or patch data into native Flutter widgets
- a narrow host bridge for selected services such as navigation, playback control, resource access, and telemetry
- bundle loading, compatibility checks, rollback, and lifecycle control in the host

Do not use as the primary target:

- unrestricted executable code replacement of the whole Flutter app
- Dart AOT artifact replacement after release
- a JSON payload interpreter as the main dynamicization model

## Why This Direction Won

- It can create the hot-update effect the project actually wants in release environments.
- It gives business code a familiar front-end-like component model instead of forcing everything into static schema fields.
- It is more expressive than remote config or simple DSL payloads.
- It keeps Flutter as the native rendering target instead of falling back to a WebView UI shell.
- It is meaningfully more realistic than trying to patch compiled Dart code after distribution.

## Boundary

Keep in the fixed host:

- playback core
- decoder, DRM, and hardware integration
- platform-specific capability ownership
- bundle verification, compatibility checks, rollback, and update policy
- native widget mapping layer
- host-exposed service boundary

Allow the dynamic runtime layer to control:

- page composition
- interaction flow
- business state and state transitions
- business orchestration
- selected navigation behavior
- selected host capability invocation through the approved bridge

## Explicit Non-Goals

This direction does not aim to build:

- true release-mode Dart code hot swap
- a remote-config-only system
- a schema-only JSON page engine as the end-state architecture
- bottom-layer playback engine replacement
- unconstrained JS access to arbitrary Flutter or native internals

## Prototype Implication

The next meaningful prototype should validate this chain directly:

- load a JS bundle or bytecode bundle in a fixed Flutter host
- execute a minimal React-like component model with state and events
- map a minimal JS component set to native Flutter widgets
- route UI events back into the JS runtime
- replace the bundle without changing host Dart code and observe both UI and behavior changes

A local JSON payload demo may still exist as a discarded exploratory artifact, but it is not the target architecture and should not drive further design decisions.

## Strategic Position

The React-like route should currently be treated as:

- the primary research direction
- the highest-flexibility candidate for selected business surfaces
- a runtime-and-bundle architecture that deserves direct validation
- not yet a production-ready final system until bundle governance, bridge control, and lifecycle rules are proven

## Documentation Position

The repository should treat this direction as a two-layer design track:

- long-term design first: architecture, ownership boundaries, and stable ABI choices
- short-term plan second: PoC execution that must follow the long-term direction

The current long-term design follow-up is:

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-long-term-overview.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-long-term-architecture.md`

The current short-term implementation follow-up is:

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/plan/2026-04-08-react-like-js-runtime-poc-plan.md`

## Open Design Questions

- Which embedded JS runtime is the best fit across the target platforms?
- Should the JS-to-Flutter boundary transfer full trees, compact patches, or a hybrid form?
- How should widget identity and state retention be preserved across rerenders?
- How strict should the host bridge typing and permission model be?
- What bundle manifest, version-compatibility, and rollback contract is sufficient for the first serious prototype?

## Related Docs

- active discussion: /Users/zyyziyunying/flutter-hot-update-lab/docs/discussion/2026-04-08-react-like-dynamic-runtime.md
- external reference analysis: /Users/zyyziyunying/flutter-hot-update-lab/docs/discussion/2026-04-08-fuckjs-demo-analysis.md
- bundle and tree contract: /Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-bundle-and-tree-contract.md
- long-term architecture: /Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-long-term-architecture.md
- archived broad research log: /Users/zyyziyunying/flutter-hot-update-lab/docs/discussion/archive/2026-04-07-flutter-hot-update-technical-research.md
