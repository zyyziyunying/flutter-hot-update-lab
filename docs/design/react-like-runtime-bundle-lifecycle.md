# React-Like Runtime Bundle Lifecycle

Status: active
Scope: Long-term design for bundle manifest, compatibility, rollout, and rollback in the React-like runtime architecture.
Source of truth: this file
Last updated: 2026-04-09

## Context

The long-term architecture treats bundles as the operational unit of delivery.
That means bundle lifecycle cannot remain an implicit PoC detail.

This file defines the long-term repository position for:

- bundle manifest
- compatibility checks
- rollout
- rollback

## Core Position

Bundles are the delivery unit for dynamic business logic.

Therefore bundles must carry enough metadata to support:

- compatibility decisions
- auditability
- staged rollout
- rollback
- runtime attribution

## Bundle Manifest

The long-term bundle manifest should include at least:

- `bundleId`
- `bundleVersion`
- `runtimeAbiVersion`
- `treeSchemaVersion`
- `bridgeCapabilitySetVersion`
- `targetPlatformFamily`
- `minHostVersion`
- `maxHostVersion` or supported host range
- `integrity`
- `buildTimestamp`
- `entryAsset`
- `rollbackGroup`

### Meaning Of Key Fields

#### `bundleId`

Stable product identity for one logical bundle family.

#### `bundleVersion`

Concrete release identity for one bundle artifact.

#### `runtimeAbiVersion`

Declares which host/runtime contract this bundle expects.

#### `treeSchemaVersion`

Declares which render tree schema the host must understand.

#### `bridgeCapabilitySetVersion`

Declares which bridge capability set the bundle was authored against.

#### `targetPlatformFamily`

Allows the host to distinguish artifacts for:

- apple
- android
- desktop
- or a stricter family when needed

#### `integrity`

Must support future hash or signature verification.

#### `entryAsset`

Explicitly identifies which built JS asset is the runtime entry.

#### `rollbackGroup`

Lets operations define which bundle versions may safely roll back within the same compatibility family.

## Compatibility Rules

The host must validate a bundle before activation.

Minimum checks:

- runtime ABI compatibility
- tree schema compatibility
- bridge capability set compatibility
- host version compatibility
- platform family compatibility
- integrity verification

If any mandatory check fails:

- the bundle must not activate
- the host must log the rejection reason
- the previous stable bundle must remain available if one exists

## Activation Model

The long-term system should activate bundles through explicit stages.

### Stage 1: Discover

- host learns a candidate bundle exists

### Stage 2: Verify

- integrity check
- manifest parse
- compatibility check

### Stage 3: Prepare

- bundle downloaded or resolved locally
- activation point selected

### Stage 4: Activate

- new runtime session created
- bundle bootstrapped
- health check passes

### Stage 5: Commit

- bundle becomes current active bundle

### Stage 6: Roll Back If Needed

- revert to last known good compatible bundle

## Rollout Strategy

The long-term system should support staged rollout rather than all-at-once replacement.

Recommended rollout controls:

- target cohort
- environment
- rollout percentage
- rollout window
- activation condition
- kill switch

Even if the first product iteration uses a simple pull model, the data model should still support staged rollout.

## Rollback Strategy

Rollback must be a first-class operation, not an emergency hack.

The host should keep enough metadata to know:

- current active bundle
- previous stable bundle
- last activation result
- last failure reason

Rollback should be allowed only to a bundle that is:

- integrity-valid
- still compatible with current host/runtime contracts
- marked as rollback-eligible for the current `rollbackGroup`

## Long-Term Activation Timing

The host should activate bundles only at safe switch points.

Examples:

- app startup
- page entry
- session boundary
- media-item boundary

The exact switch point is product-specific, but the system model must assume activation is not always immediate.

## Health And Failure Policy

Bundle activation should have a post-activation health gate.

Examples of activation failure:

- bootstrap crash
- invalid manifest
- incompatible bridge request at startup
- invalid initial render tree

If activation fails:

- do not mark the bundle as stable
- preserve the previous stable bundle
- surface a readable host diagnostic
- emit structured telemetry

## Artifact Strategy

The long-term system should distinguish:

- source inputs
- built bundle assets
- manifest metadata
- verification metadata

The repository should not assume that one raw script file alone is sufficient forever.
The PoC may start there, but the long-term model needs an explicit manifest and integrity story.

## Relationship To PoC

The first PoC only needs a narrowed subset of this model:

- local asset bundle
- minimal metadata
- runtime ABI version check
- tree schema version check
- host-side rejection before bootstrap

The PoC does not yet need:

- remote delivery
- staged rollout percentages
- signed artifact infrastructure
- production rollback automation

## Decision Summary

The long-term system should treat bundles as managed release artifacts, not just script files.

That means the repository should own:

- manifest fields
- compatibility rules
- activation stages
- rollout controls
- rollback rules

## Related Docs

- direction: /Users/zyyziyunying/flutter-hot-update-lab/docs/design/flutter-hot-update-react-like-direction.md
- long-term architecture: /Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-long-term-architecture.md
- host bridge governance: /Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-host-bridge-governance.md
- PoC contract: /Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-bundle-and-tree-contract.md
