# React-Like Runtime Host Bridge Governance

Status: active
Scope: Long-term governance rules for what the JS runtime may call in the Flutter host and how those capabilities must be designed, versioned, and constrained.
Source of truth: this file
Last updated: 2026-04-09

## Context

The long-term architecture already chooses a React-like JS runtime with a tightly governed host bridge.
That choice is only safe if the repository owns clear rules for capability exposure.

Without governance, the host bridge becomes:

- a hidden general-purpose native API surface
- hard to version
- hard to audit
- hard to constrain for platform review and operational safety

This file defines the long-term bridge governance model.

## Core Position

The host bridge must be:

- capability-based
- allowlisted
- typed
- versioned
- observable
- revocable

The host bridge must not be:

- a raw pass-through to arbitrary Flutter internals
- a stringly typed universal command bus
- an ad hoc dumping ground for product requests

## Bridge Layers

The host bridge should grow in three layers.

### Layer 1: Runtime-Core Bridge

Always allowed:

- render tree commit
- event dispatch
- runtime logging
- lifecycle notifications

This layer exists to make the runtime function at all.

### Layer 2: Navigation And UI Shell Bridge

Allowed when dynamic pages prove useful:

- push dynamic page
- push native page
- pop with result
- present modal or sheet

This layer should stay narrow and shell-oriented.

### Layer 3: Business Capability Bridge

Allowed only after governance and testing are mature:

- player commands
- resource selection
- telemetry
- storage
- selected network access
- selected feature flags or config reads

This layer must be introduced one capability family at a time.

## Capability Registration Rule

Every host capability must be registered explicitly.

Each capability must have:

- stable capability name
- request type
- response type
- error type
- minimum host version
- bridge version
- owner
- test coverage
- observability hooks

If one of these is missing, the capability is not ready to ship.

## Naming Rule

Capability names should use a stable namespace pattern:

- `Runtime.*`
- `Navigation.*`
- `Player.*`
- `Storage.*`
- `Telemetry.*`

Examples:

- `Navigation.pushDynamicPage`
- `Navigation.pushNativePage`
- `Player.play`
- `Telemetry.track`

Avoid generic names such as:

- `callNative`
- `invoke`
- `exec`
- `misc`

## Type Rule

Every capability must use explicit request and response schemas.

Rules:

- inputs are schema-validated before host execution
- outputs are schema-validated before returning to JS
- unknown fields should be rejected unless the schema explicitly allows extension
- errors should return stable machine-readable codes plus readable messages

The bridge must never rely on:

- positional argument guessing
- arbitrary object passthrough
- undocumented optional fields

## Permission Rule

Each capability must declare whether it is:

- always allowed
- page-scoped
- bundle-scoped
- environment-gated
- rollout-gated

Examples:

- `Runtime.log` may be always allowed
- `Navigation.pushNativePage` may be bundle-scoped
- `Player.play` may be page-scoped
- `Network.fetch` should be environment-gated and tightly constrained if it is ever added

## Exposure Rule

The JS runtime should only see capabilities intentionally injected into the active session.

The host must not expose:

- arbitrary plugin access
- unrestricted filesystem access
- unrestricted network access
- unrestricted platform-channel invocation
- arbitrary reflection-like APIs

## Versioning Rule

Bridge versioning must be explicit.

Each capability should declare:

- capability version
- supported host version range
- deprecation status

If a capability changes incompatibly:

- create a new versioned capability name or version marker
- do not silently change semantics under the same contract

## Observability Rule

Each capability invocation must support:

- success/failure logging
- latency measurement
- error code reporting
- bundle id attribution
- bundle version attribution

The host must be able to answer:

- which bundle invoked which capability
- how often
- how long it took
- how often it failed

## Review Gate

A new bridge capability should not be added unless all of these are true:

- the capability cannot be cleanly solved inside JS/runtime-only logic
- the capability has a bounded product need
- the capability has a clear schema
- the capability has negative-path tests
- the capability has an explicit ownership and deprecation story

## Initial Long-Term Capability Set

The repository should treat this as the intended long-term order of introduction.

### Phase 1

- `Runtime.log`
- render commit plumbing
- event dispatch plumbing

### Phase 2

- `Navigation.pushDynamicPage`
- `Navigation.pushNativePage`
- `Navigation.pop`

### Phase 3

- `Player.play`
- `Player.pause`
- `Player.enqueue`
- `Telemetry.track`

### Deferred Until Strong Justification

- general network access
- arbitrary storage access
- timers beyond runtime-core need
- open-ended native service extension points

## Rejection Policy

The repository should reject capability proposals that:

- expose broad native internals for convenience
- lack typed schemas
- mix unrelated concerns into one method
- create silent compatibility risk
- exist mainly to work around a missing runtime abstraction that should be fixed elsewhere

## Relationship To PoC

The first PoC should stay inside Layer 1.

That means the PoC should not try to prove:

- full navigation bridge
- player bridge
- general business capability bridge

The PoC only needs enough host bridge to prove runtime viability.

## Related Docs

- direction: /Users/zyyziyunying/flutter-hot-update-lab/docs/design/flutter-hot-update-react-like-direction.md
- long-term architecture: /Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-long-term-architecture.md
- bundle lifecycle: /Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-bundle-lifecycle.md
- PoC contract: /Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-bundle-and-tree-contract.md
