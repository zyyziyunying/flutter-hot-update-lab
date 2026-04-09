# React-Like Runtime Long-Term Overview

Status: active
Scope: Canonical overview of the long-term React-like runtime design, including stable surfaces, current PoC decisions, and still-open questions.
Source of truth: this file
Last updated: 2026-04-09

## Purpose

The repository now has multiple design files for the React-like runtime route.
This overview exists so future readers can answer three questions quickly:

1. what is the long-term target architecture
2. which decisions are already treated as stable
3. which current decisions are only PoC-stage choices

This file is the entry point for the long-term design set.

## Long-Term Target

The repository is aiming for:

- a fixed Flutter host
- a JS runtime layer
- a React-like component and state runtime
- a Flutter native renderer
- a tightly governed host bridge
- a managed bundle system with compatibility, rollout, and rollback

The repository is not aiming for:

- Dart AOT code replacement after release
- a schema-only JSON page engine as the final architecture
- a permanent dependency on one runtime package

## Stable Surfaces

These should be treated as the long-term owned boundaries of the repository.

### Runtime ABI

Owned by the repository.
Defines:

- bundle bootstrap shape
- host-to-JS event dispatch
- JS-to-host render commit
- runtime session lifecycle

Long-term governing docs:

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-long-term-architecture.md`

Current concrete PoC implementation contract:

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-bundle-and-tree-contract.md`

### Bundle ABI

Owned by the repository.
Defines:

- manifest metadata
- compatibility handshake
- activation and rollback semantics

Long-term governing docs:

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-bundle-lifecycle.md`

Current concrete PoC implementation contract:

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-bundle-and-tree-contract.md`

### Tree Schema

Owned by the repository.
Defines:

- supported node types
- props
- events
- child rules
- validation behavior

Current concrete PoC implementation contract:

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-bundle-and-tree-contract.md`

### Host Bridge Governance

Owned by the repository.
Defines:

- which host capabilities may be exposed
- how they must be typed and versioned
- how they are approved, observed, and revoked

Primary doc:

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-host-bridge-governance.md`

## Current Concrete PoC Contract

The current PoC needs one explicit concrete contract file so implementation can start without waiting for every long-term ABI document to split further.

For that reason:

- `react-like-runtime-bundle-and-tree-contract.md` is the active implementation contract for the first PoC
- it defines the current concrete bundle globals, tree schema, and handler transport that the PoC must implement now
- it does not by itself own the final long-term Runtime ABI, Bundle ABI, or Tree Schema boundary for the repository
- later ABI cleanup or document refactoring may replace PoC-specific globals and version tags without changing long-term repository ownership

## Current PoC Decisions

These are current practical decisions, not the full long-term architecture.

### Runtime Baseline

- first PoC uses `flutter_js`
- this is a delivery choice, not a long-term lock-in

### Platform Scope

- first PoC starts on macOS only

### Render Transport

- first PoC uses full-tree commits
- patch transport is explicitly deferred

### Bundle Activation Model

- first PoC uses reload-style bundle replacement
- cross-bundle state continuity is out of scope

### Host Bridge Scope

- first PoC stays inside runtime-core bridge only
- no full navigation or business capability bridge yet

Primary PoC plan:

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/plan/2026-04-08-react-like-js-runtime-poc-plan.md`

## Recommended Reading Order

Read in this sequence:

1. `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/flutter-hot-update-react-like-direction.md`
2. `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-long-term-overview.md`
3. `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-long-term-architecture.md`
4. `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-host-bridge-governance.md`
5. `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-bundle-lifecycle.md`
6. `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-bundle-and-tree-contract.md`
7. `/Users/zyyziyunying/flutter-hot-update-lab/docs/plan/2026-04-08-react-like-js-runtime-poc-plan.md`

## Current Open Questions

These are still open at the long-term design level.

### 1. Engine Ownership Depth

- should the repository stay on a package-backed engine layer for a long time
- or eventually own lower-level JSC and QuickJS integrations directly

### 2. Bridge Expansion Timing

- when should navigation bridge move from deferred to active
- when should player and telemetry capabilities enter the governed bridge

### 3. Bundle Delivery Model

- when should the system move from local asset bundles to remote managed bundles
- which integrity model should be mandatory in the first production-grade bundle system

### 4. Render Transport Evolution

- when does full-tree commit stop being acceptable
- what should the first patch-based transport contract look like

## Document Roles

Use each file for a different purpose:

- `flutter-hot-update-react-like-direction.md`
  - top-level direction and architectural intent
- `react-like-runtime-long-term-overview.md`
  - summary and routing index for the long-term design set
- `react-like-runtime-long-term-architecture.md`
  - stable-vs-variable engineering architecture
- `react-like-runtime-host-bridge-governance.md`
  - host capability policy
- `react-like-runtime-bundle-lifecycle.md`
  - bundle manifest, rollout, and rollback model
- `react-like-runtime-bundle-and-tree-contract.md`
  - current concrete PoC implementation contract, not the final long-term ABI authority by itself
- `2026-04-08-react-like-js-runtime-poc-plan.md`
  - short-term execution plan

## Decision Rule

If a short-term plan conflicts with a long-term design file:

- the long-term design wins
- the plan must be updated
- implementation should not silently choose the plan over the design

## Related Docs

- direction: /Users/zyyziyunying/flutter-hot-update-lab/docs/design/flutter-hot-update-react-like-direction.md
- long-term architecture: /Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-long-term-architecture.md
- host bridge governance: /Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-host-bridge-governance.md
- bundle lifecycle: /Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-bundle-lifecycle.md
- PoC contract: /Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-bundle-and-tree-contract.md
- short-term plan: /Users/zyyziyunying/flutter-hot-update-lab/docs/plan/2026-04-08-react-like-js-runtime-poc-plan.md
