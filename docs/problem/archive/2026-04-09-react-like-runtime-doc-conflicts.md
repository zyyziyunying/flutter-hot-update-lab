# React-Like Runtime Documentation Conflicts

Status: closed
Scope: Active documentation conflicts in the React-like runtime route that can mislead implementation, architecture ownership, and onboarding.
Source of truth: this file
Last updated: 2026-04-09

Archived note: this is a historical closed record kept for context. Its conflict descriptions reflect the pre-fix state that existed before the linked documents were repaired.

## Summary

The current documentation realignment still leaves two kinds of conflicts active:

1. implementation-facing conflicts inside the first PoC plan and runtime contract
2. documentation-governance conflicts between long-term design docs, PoC contract docs, and repository entry docs

These are not cosmetic wording issues.
If left unresolved, they can:

- push PoC implementation toward the wrong runtime boundary
- route implementers around the canonical long-term design set
- allow PoC acceptance to pass without covering the intended runtime path
- blur the distinction between PoC scaffolding and long-term owned ABI surfaces
- send new readers into a route that the active doc map already treats as historical

## Affected Files

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/plan/2026-04-08-react-like-js-runtime-poc-plan.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/README.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-bundle-and-tree-contract.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-long-term-overview.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/status/2026-04-09-react-like-runtime-doc-map.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/README.md`

## Problem 1

### Title

PoC acceptance criteria do not cover the intended production-like runtime path.

### Conflict

The PoC plan says the host must load and execute a JS bundle in a release-capable Flutter environment.
However, the acceptance criteria only require:

- `flutter analyze`
- `flutter test`
- `flutter build macos --debug`
- manual macOS run

That verification path is weaker than the stated runtime target.

### Risk

- debug success may be mistaken for release-path feasibility
- runtime behavior may differ under profile or release build conditions
- asset loading, bundle bootstrap, and bridge behavior may fail later on the real target path

### Required Resolution

- add at least one `macOS` `profile` or `release` build-and-run validation step
- make that validation part of the PoC exit criteria, not an optional follow-up

## Problem 2

### Title

Handler ownership is described in two different ways.

### Conflict

The PoC plan says the host promotes and keeps the full active handler table as part of the active snapshot.
But the runtime contract says event handlers are runtime-managed ids and that the JS runtime must preserve the last successfully committed handler table when a later commit is rejected.

Those two statements blur an important ownership boundary:

- host-visible event attachment data on the committed tree
- JS-runtime-owned `handlerId -> callback` lookup state

The current wording makes it unclear whether Flutter owns callback tables directly or only stores handler ids while the active JS runtime session owns callback resolution.

### Risk

- implementers may copy callback state into Dart instead of keeping the bridge narrow
- the bridge may expand beyond `__poc_dispatch_event(handlerId, payload)`
- bundle-switch activation boundaries may become ambiguous

### Required Resolution

- define the callback lookup table as owned by the active JS runtime session
- define the host as owning only the active session reference, visible tree, and event-binding data needed to dispatch by `handlerId`
- rewrite the PoC plan wording so it matches the runtime contract exactly

## Problem 3

### Title

Root tree example omits a field that the schema later marks as required.

### Conflict

The root tree example shows:

```json
{
  "type": "View",
  "props": {},
  "children": []
}
```

But the node schema later defines `events` as a required field for every node.

### Risk

- different readers may implement different acceptance rules for the same schema
- the first committed tree may be accepted or rejected depending on which section is followed
- the contract loses value as an executable shared boundary

### Required Resolution

- either add `events: {}` to the root example
- or make `events` optional and define the defaulting and validation rule explicitly

## Problem 4

### Title

The PoC plan points readers to an incomplete authority set.

### Conflict

The PoC plan says the accepted direction now lives only in:

- `flutter-hot-update-react-like-direction.md`
- `react-like-runtime-bundle-and-tree-contract.md`

But the repository's doc map and overview define a broader canonical design set and explicitly say the short-term plan must be interpreted under the long-term design docs rather than on its own.

This creates a routing conflict:

- the plan context points to only part of the active design surface
- the canonical doc map points readers through the full long-term design stack first

### Risk

- implementers may read the PoC plan as if the direction doc plus PoC contract are the only active authorities
- long-term architecture, bridge governance, and bundle lifecycle constraints may be skipped at the exact moment implementation starts
- the repository's document routing becomes internally inconsistent

### Required Resolution

- update the PoC plan context so it points to the canonical long-term design set rather than only a partial subset
- or explicitly state that the PoC plan is subordinate to the full long-term design set listed in the doc map and overview

## Problem 5

### Title

The long-term overview does not cleanly distinguish current concrete contract references from final long-term ABI ownership.

### Conflict

The runtime contract doc explicitly says it is the first PoC contract and is not the final production ABI.
However, the long-term overview currently lists that same file as a primary document for:

- Runtime ABI
- Bundle ABI
- Tree Schema

The same overview also describes that file as the first concrete runtime contract for PoC implementation.
Taken together, those references do not cleanly distinguish:

- current concrete implementation contract
- final long-term owned ABI authority

### Risk

- future work may over-read PoC globals and PoC version tags as more stable than intended
- later ABI cleanup may look more disruptive than it should
- readers may need to infer where PoC-stage constraints end and long-term ownership begins

### Required Resolution

- narrow the overview wording so it distinguishes long-term owned boundaries from the current PoC concrete contract
- keep the PoC contract referenced as the active implementation contract without implying it is already the final long-term ABI definition

## Problem 6

### Title

The active doc map conflicts with the repository root onboarding path.

### Conflict

The active doc map says the local JSON payload route and the standalone minimal demo are no longer the current product direction.
But the repository root `README.md` still tells readers to run and verify `demo/minimal_hot_update_demo` as the main local demo flow.

### Risk

- new readers entering from `README.md` are routed into a deprecated path
- new readers entering from the active doc map are told that same path is historical only
- the repository tells two different onboarding stories at the same time

### Required Resolution

- either update `README.md` so its primary onboarding path matches the active React-like runtime route
- or mark the root README demo as historical and transitional until a new active demo exists
- or relax the doc map wording so it explicitly says repository-level onboarding has not been migrated yet

## Priority

Fix in this order:

1. handler ownership boundary
2. PoC acceptance criteria for production-like verification
3. PoC plan versus canonical design-set routing
4. long-term overview versus PoC contract role separation
5. root README versus active doc map onboarding
6. schema example versus required field mismatch

## Exit Criteria

This problem can be closed when all of the following are true:

- the PoC plan and runtime contract no longer disagree about handler ownership or active snapshot semantics
- the PoC acceptance criteria validate at least one production-like macOS runtime path
- the PoC plan no longer routes readers around the canonical long-term design set
- the long-term overview clearly separates owned long-term boundaries from first-PoC concrete contract details
- the root README and active doc map give a consistent onboarding story
- the tree schema example and field requirements are internally consistent

## Resolution

Closed on 2026-04-09 after:

- the PoC plan and runtime contract were aligned on JS-runtime-owned callback lookup state versus host-owned committed event-binding data
- the PoC exit criteria were strengthened to require a production-like macOS verification path
- the PoC plan was routed under the full canonical long-term design set
- the long-term overview was narrowed to distinguish repository-owned long-term boundaries from the current PoC concrete contract
- the repository root README was updated to point readers to the active React-like runtime route and mark the minimal demo as historical
- the root tree example was made consistent with the required `events` field
