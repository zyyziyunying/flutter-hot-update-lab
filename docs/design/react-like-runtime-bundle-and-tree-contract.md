# React-Like Runtime Bundle And Tree Contract

Status: active
Scope: Stable contract for the first JS runtime PoC bundle entry, serialized tree format, and event and state lifecycle.
Source of truth: this file
Last updated: 2026-04-09

## Context

The repository has already chosen a React-like JS runtime direction for hot-update effects in a fixed Flutter host.
The first PoC now needs one explicit contract so the JS side and Flutter side do not drift into separate ad hoc implementations.

This file defines the first PoC contract for:

- bundle entry
- serialized tree shape
- event callback transport
- minimal state lifecycle

This contract is intentionally narrow.
It is designed to prove the architecture, not to be a final production ABI.
The current repository snapshot now includes one minimal patch transport slice for rerender updates after the initial full-tree activation.

## Contract Goals

The first contract must:

- be small enough to implement quickly
- be explicit enough that JS runtime and Flutter renderer can be developed against the same shape
- prove interactive rerender, not only static tree rendering
- keep patch transport narrow enough that it does not become a broad protocol design exercise too early

## Non-Goals

This contract does not try to support:

- general patch-based tree transport with insert, remove, or move operations
- multi-page routing
- list virtualization
- text input
- async effects such as `useEffect`
- arbitrary host API access
- runtime state preservation across bundle replacement

## Bundle Entry Contract

The first PoC bundle is a host-loaded script asset, not a host-called source string API.

Each JS bundle must expose one host-known global entry:

- `globalThis.__poc_bootstrap`

The host evaluates the bundle source first.
After evaluation, the host invokes:

```js
globalThis.__poc_bootstrap(host)
```

The bundle must register exactly one root application during bootstrap.

## Bundle ABI Contract

The first PoC uses one minimal bundle ABI so bundle loading and compatibility are explicit.

### Bundle Format

- each built bundle is one plain JavaScript asset file
- the host loads bundle source from a local asset path such as `assets/bundles/bundle_a.js`
- the host evaluates that source inside one fresh JS runtime session
- the bundle must execute successfully as a script, not rely on dynamic module loading at runtime

The build pipeline may use TypeScript or TSX as source inputs, but the runtime artifact contract is a single built JavaScript script asset.

### Required Runtime Globals

After evaluation, a valid bundle must define:

- `globalThis.__poc_bundle_meta`
- `globalThis.__poc_bootstrap`
- `globalThis.__poc_dispatch_event`

If any required global is missing, bundle load must fail with a readable host error.

### Bundle Metadata Shape

Each bundle must expose:

```js
globalThis.__poc_bundle_meta = {
  bundleId: 'bundle-a',
  bundleVersion: '1.0.0',
  runtimeAbiVersion: 'poc-v1',
  treeSchemaVersion: 'poc-tree-v1',
};
```

Required fields:

- `bundleId`: string
- `bundleVersion`: string
- `runtimeAbiVersion`: string
- `treeSchemaVersion`: string

### Compatibility Rule

The first PoC host must accept only:

- `runtimeAbiVersion === 'poc-v1'`
- `treeSchemaVersion === 'poc-tree-v1'`

If either version does not match, the host must reject the bundle before bootstrap.

This is intentionally simple.
It is only a first handshake to prevent silent drift between bundle output and host expectations.

### Host Object Shape

The `host` object passed into `__poc_bootstrap` exposes only:

- `commitTree(tree): { ok: true } | { ok: false, reason: string }`
- `commitPatch(patch): { ok: true } | { ok: false, reason: string }`
- `log(level, message)`

`commitTree(tree)` sends a full serialized tree snapshot to Flutter and returns a result object instead of acting as fire-and-forget transport.
`{ ok: true }` means Flutter accepted that tree as the next active UI snapshot.
`{ ok: false, reason }` means Flutter rejected the tree, kept the previously committed tree active, and did not promote the candidate event-binding data or callback lookup state.
`commitPatch(patch)` applies a narrow patch payload against the currently active serialized tree and returns the same result shape.
If patch application fails, Flutter must keep the previous committed tree and previous event-binding data active.
`log(level, message)` is for debugging only.

No additional host services are available in the first PoC.

### Bundle Responsibility

During bootstrap, the bundle must:

1. create the runtime app
2. render the root component
3. call `host.commitTree(...)` with the current full tree and treat `{ ok: true }` as the moment that tree becomes active
4. keep enough runtime state so later host-dispatched events can trigger rerender and emit a minimal patch payload against the active tree

### Event Dispatch Entry

After bootstrap, the host may invoke one global event dispatcher:

- `globalThis.__poc_dispatch_event(handlerId, payload)`

The bundle runtime must look up the handler by id, execute it, update state if needed, rerender, and then call `host.commitPatch(...)` with a minimal patch payload against the active tree.
If that commit returns `{ ok: false, ... }`, the runtime must preserve the last successfully committed callback lookup table because Flutter is still showing the previous tree.

## Minimal Patch Transport

The current PoC supports one narrow patch payload shape for rerenders.

### Patch Shape

```json
{
  "ops": [
    {
      "op": "replace",
      "path": [1],
      "node": {
        "type": "Text",
        "props": {
          "text": "Counter: 1"
        },
        "events": {},
        "children": []
      }
    }
  ]
}
```

Rules:

- `ops` must be an array
- each op currently supports only `replace`
- `path` is an array of child indexes from the root
- `path: []` means replace the root node itself
- `node` must be a valid serialized node under the same tree schema as full-tree commits

This is intentionally limited.
The current PoC does not yet support insert, remove, or move operations.

## Serialized Tree Format

The first PoC uses one explicit JSON-compatible node schema.

### Root Shape

Every committed tree must be one node object:

```json
{
  "type": "View",
  "props": {},
  "events": {},
  "children": []
}
```

The root is always a node object, never a raw array or primitive.

### Node Shape

Each node uses this structure:

```json
{
  "type": "View",
  "key": "optional-stable-key",
  "props": {
    "padding": 16,
    "backgroundColor": "#EAF4FF"
  },
  "events": {},
  "children": []
}
```

Fields:

- `type`: required string
- `key`: optional string used only for future identity work
- `props`: required object, may be empty
- `events`: required object, may be empty
- `children`: required array, may be empty

### Supported Node Types

Only these node types are valid:

- `View`
- `Text`
- `Button`

Unknown node types must fail fast and surface a readable host error.

### Props Contract

#### View

Supported `props`:

- `padding`: number
- `backgroundColor`: `#RRGGBB` string

#### Text

Supported `props`:

- `text`: string
- `textColor`: `#RRGGBB` string
- `fontSize`: number
- `padding`: number

`Text` nodes must not use child text fragments in the first PoC.
Their content must come from `props.text`.

#### Button

Supported `props`:

- `label`: string
- `padding`: number

Buttons do not accept arbitrary children in the first PoC.
Their visible text comes from `props.label`.

### Events Contract

Only one event is supported:

- `onPress`

The `events` object uses runtime-generated handler ids:

```json
{
  "onPress": "h_3"
}
```

If a node type does not support an event field, that event is invalid and must fail fast.

### Children Contract

- `View` may contain zero or more children.
- `Text` must contain no children.
- `Button` must contain no children.

This restriction is deliberate.
It removes ambiguity in the first renderer and keeps the tree grammar small.

## Event Lifecycle

The first PoC uses this event flow:

1. JS renders a tree and assigns runtime-generated handler ids.
2. JS stores a handler map inside the active runtime session.
3. JS commits the full tree to Flutter.
4. Flutter renders native widgets and keeps the handler id on interactive nodes.
5. On user press, Flutter calls `globalThis.__poc_dispatch_event(handlerId, payload)`.
6. JS resolves the handler id in the current session.
7. JS executes the handler.
8. If state changed, JS rerenders and sends a patch through `commitPatch` against the active committed tree.

### Callback Lookup Ownership And Lifetime

The first PoC uses one simple activation rule:

- the active JS runtime session owns the `handlerId -> callback` lookup table
- Flutter owns only the active session reference, the visible tree, and the committed event-binding data needed to dispatch by `handlerId`
- each render pass may build a candidate callback lookup table for the candidate tree inside the candidate or active JS runtime session
- only a successful accepted commit may promote that candidate callback lookup table to become the active callback lookup table for the active session
- handler ids from any earlier committed tree become invalid only after the new tree is accepted
- if a rerender commit is rejected, the previously committed callback lookup table and committed runtime state must stay active inside that runtime session

The host must not copy callback objects into Dart or expand the bridge beyond handler-id dispatch for this PoC.

This keeps handler lifetime easy to reason about in the first pass while preserving event delivery after a failed rerender.

### Active Snapshot Atomicity

The host must treat the visible tree, active runtime session reference, and committed event-binding data as one atomic snapshot.

- accepting a rerendered tree swaps the visible tree and committed event-binding data together while the active session keeps the matching callback lookup table
- promoting bundle B swaps the visible tree, active session, and committed event-binding data together
- rejected commits or failed bundle activation must leave the full previous snapshot untouched

The host must not expose mixed states such as a new tree with stale handler ids, or a promoted session with the previous visible tree.

### Event Payload

For the first PoC, `payload` should be an object and may be empty:

```json
{}
```

No richer event payload contract is needed yet.

## State Lifecycle

The first PoC supports one minimal `useState`-style hook model.

### Scope

- state is local to the active JS runtime session
- state survives ordinary rerenders within the same session
- state does not survive bundle replacement
- state does not need to survive host-triggered full session recreation

### Hook Semantics

The first PoC runtime should use the classic minimal hook rule:

- hooks are stored by render order within a function component instance
- rerenders must execute the same hook order for the same component shape
- changing hook order is invalid behavior for the PoC runtime

### Component Identity

The first PoC only needs one safe identity rule:

- if the rendered component structure stays in the same order under the same parent path, hook state may be reused

The PoC does not need a full reconciliation algorithm.
It only needs enough stability to prove interactive local state on rerender.

### Bundle Replacement Semantics

Bundle replacement in the first PoC is a staged reload model, not live stateful hot swap:

1. keep the current runtime session and committed tree active while preparing bundle B
2. create a fresh candidate runtime session
3. evaluate the new bundle in that candidate session
4. validate compatibility before bootstrap
5. bootstrap the candidate session and require it to commit a valid initial tree
6. promote the candidate session only after Flutter accepts that tree
7. dispose the old session and clear its callback lookup table only after promotion succeeds
8. if any step fails, discard the candidate session and keep serving the previous committed tree

This means:

- bundle replacement proves host-code independence
- bundle replacement does not prove seamless state continuity across versions
- bundle compatibility is checked before the new session is bootstrapped
- failed activation does not blank the current UI or orphan its active handler ids

That tradeoff is intentional for the first PoC.

## Error Handling Rules

The first PoC should use simple fail-fast rules.

### Bundle Load Error

- show a readable error state in Flutter
- do not keep pretending the bundle loaded successfully

### Tree Validation Error

- reject the invalid tree
- return `{ ok: false, reason: 'tree-validation-error' }` to the caller
- keep the last successfully rendered tree if one exists
- keep the committed event-binding data and matching callback lookup table for that last successfully rendered tree active
- surface a readable error in the host UI

### Event Handler Error

- catch the JS error
- surface a readable error in the host UI
- keep the last successfully rendered tree

These rules are enough for a PoC without designing a full recovery system.

## Verification Implications

The implementation should be considered correct only if it proves all of these:

- a bundle exposes `__poc_bootstrap`
- a bundle exposes valid `__poc_bundle_meta`
- the host can call bootstrap successfully
- the host rejects bundles with incompatible `runtimeAbiVersion` or `treeSchemaVersion`
- the bundle can commit a valid full tree
- Flutter validates and renders the tree as native widgets
- button press routes through handler id dispatch back into JS
- `useState`-driven rerender changes visible output without rebuilding the host code
- bundle replacement recreates the session and renders a different app shape

## Related Docs

- direction: /Users/zyyziyunying/flutter-hot-update-lab/docs/design/flutter-hot-update-react-like-direction.md
- PoC plan: /Users/zyyziyunying/flutter-hot-update-lab/docs/plan/2026-04-08-react-like-js-runtime-poc-plan.md
- runtime discussion: /Users/zyyziyunying/flutter-hot-update-lab/docs/discussion/2026-04-08-react-like-dynamic-runtime.md
