# React-Like Runtime Long-Term Architecture

Status: active
Scope: Long-term engineering architecture for the React-like JS runtime direction in this repository.
Source of truth: this file
Last updated: 2026-04-09

## Context

The repository has already chosen a React-like JS runtime direction rather than Dart AOT code replacement.
The first PoC is intentionally narrow and currently uses `flutter_js` as the runtime baseline.

That PoC decision must not be confused with the long-term architecture decision.

The long-term question is not:

- which Flutter package is easiest today

The long-term question is:

- which parts of the system must remain stable across engines, platforms, bundle tooling, and future runtime evolution

## Architectural Position

The long-term system should be defined as:

- a fixed Flutter host
- a JS runtime layer
- a React-like component and state runtime
- a Flutter native renderer
- a tightly governed host bridge
- a bundle system with compatibility, rollout, and rollback controls

The long-term architecture should not be defined as:

- permanently depending on one third-party runtime package
- requiring one single JS engine on every platform

## Core Decision

Use:

- one stable repository-owned Runtime ABI
- one stable repository-owned Bundle ABI
- one stable repository-owned tree schema
- one stable repository-owned host bridge governance model

Allow variation in:

- the underlying JS engine
- the Flutter integration package
- bundle build tooling
- performance strategy such as full-tree versus patch transport

## Stable Surfaces

These are the long-term stable surfaces the repository should own directly.

### 1. Runtime ABI

The Runtime ABI defines:

- how the host evaluates a bundle
- which globals the bundle must expose
- how events are dispatched into JS
- how JS commits render output back to Flutter
- what lifecycle states exist for one runtime session

This ABI must remain host-owned rather than package-owned.

### 2. Bundle ABI

The Bundle ABI defines:

- bundle metadata
- runtime ABI version handshake
- tree schema version handshake
- compatibility checks
- integrity fields
- rollout and rollback identity

Bundles are the operational unit of delivery.
That means versioning and rollback must be defined here, not spread across ad hoc scripts and host conventions.

### 3. Tree Schema

The tree schema defines:

- supported node types
- prop encoding
- event field encoding
- child structure
- validation rules

The schema must be independent from any specific JS engine or Flutter integration package.

### 4. Host Bridge Governance

The host bridge defines:

- which host capabilities are visible to JS
- argument shapes
- return shapes
- permission and exposure policy
- deprecation and compatibility policy
- error behavior and observability

The host bridge must stay capability-based and allowlisted.
It must not become a general escape hatch into arbitrary Flutter or native internals.

## Variable Surfaces

These are implementation choices that may change without redefining the architecture.

### JS Engine

The repository should allow different engines per platform when that is the most practical route.

Recommended long-term posture:

- Apple platforms: prefer JavaScriptCore-first integration
- Android, Windows, and Linux: prefer QuickJS-first integration

The goal is not engine uniformity.
The goal is ABI uniformity.

### Flutter Runtime Package

The repository may use:

- `flutter_js` for the first PoC
- a future custom integration
- a future lower-level QuickJS or JSC binding

The package is an implementation detail as long as the repository-owned ABI stays intact.

### Build Tooling

The JS build chain may evolve:

- TypeScript
- TSX
- esbuild
- a future custom bundler

The build tool is replaceable if the resulting runtime artifact still conforms to the Bundle ABI.

### Render Transport Strategy

The system may evolve from:

- full-tree commits

to:

- compact patch transport
- diff-based incremental updates

That is a performance evolution, not an architectural reset.

## Engine Strategy

### Recommended Long-Term Model

Use a mixed-engine strategy with one shared ABI:

- same Runtime ABI
- same Bundle ABI
- same tree schema
- same bridge rules
- different engine implementations when needed per platform

This is the most realistic balance of:

- engineering control
- platform practicality
- review and policy risk
- long-term maintainability

### Why Not Long-Term `flutter_js` Lock-In

`flutter_js` is a good PoC carrier, but it should not define the architecture.

Reasons:

- package lifecycle is outside repository control
- platform behavior may differ under the package abstraction
- long-term debugging, observability, and lifecycle control may require deeper ownership

### Why Not Long-Term QuickJS-Only Everywhere

A pure QuickJS-everywhere position is too rigid for the current stage.

Reasons:

- platform constraints and review posture are not identical
- the Apple side may be better served by JavaScriptCore-backed execution
- early insistence on one engine everywhere creates risk before ABI and bridge value are proven

## Bridge Strategy

The long-term host bridge should grow in layers.

### Layer 1: Runtime-Core Bridge

Always required:

- tree commit
- logging
- event dispatch
- runtime lifecycle hooks

### Layer 2: UI And Navigation Bridge

Add only when the runtime proves valuable:

- page navigation
- modal or sheet presentation
- route result passing

### Layer 3: Business Capability Bridge

Add only after governance is in place:

- player commands
- resource loading
- telemetry
- storage
- selected network access

Every bridge addition should be:

- typed
- documented
- versioned
- testable
- revocable

Detailed governance lives in:

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-host-bridge-governance.md`

## Bundle System Strategy

The long-term bundle system should include:

- bundle id
- bundle version
- runtime ABI version
- tree schema version
- integrity field such as hash or signature reference
- compatibility declaration
- rollback identity

The first PoC only needs a minimal compatibility handshake.
A later stage should add stronger integrity and rollout control.

Detailed lifecycle design lives in:

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-bundle-lifecycle.md`

## Verification Strategy

The long-term architecture should be validated at four levels.

### 1. Conformance

- bundle ABI conformance tests
- tree schema conformance tests
- bridge contract conformance tests

### 2. Host Rendering

- Flutter parser and renderer tests
- invalid-tree rejection tests
- event lifecycle tests

### 3. Engine Integration

- one engine-specific integration test lane per supported platform family

### 4. Delivery And Rollback

- bundle compatibility checks
- failed-load behavior
- rollback path validation

## Current Practical Decision

The repository should currently operate with this split:

- PoC implementation baseline: `flutter_js`
- long-term stable architecture: repository-owned ABI and bridge contracts

This means:

- current code may use `flutter_js`
- future code may replace `flutter_js`
- neither move should force a redesign of bundle shape, tree schema, or host bridge semantics

## Decision Summary

Long-term maturity does not come from choosing the perfect engine today.
It comes from owning the correct boundaries.

The repository should therefore treat these as long-term stable:

- Runtime ABI
- Bundle ABI
- tree schema
- host bridge governance

And treat these as replaceable implementation choices:

- JS engine
- Flutter runtime package
- build tooling
- transport optimization strategy

## Related Docs

- direction: /Users/zyyziyunying/flutter-hot-update-lab/docs/design/flutter-hot-update-react-like-direction.md
- host bridge governance: /Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-host-bridge-governance.md
- bundle lifecycle: /Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-bundle-lifecycle.md
- bundle and tree contract: /Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-bundle-and-tree-contract.md
- PoC plan: /Users/zyyziyunying/flutter-hot-update-lab/docs/plan/2026-04-08-react-like-js-runtime-poc-plan.md
