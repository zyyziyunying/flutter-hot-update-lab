# React-Like Dynamic Runtime Discussion

Status: supporting-history
Scope: Historical focused discussion record that informed the React-like runtime direction before the long-term design set was written.
Source of truth: /Users/zyyziyunying/flutter-hot-update-lab/docs/design/flutter-hot-update-react-like-direction.md
Last updated: 2026-04-09

## Reader Note

This file is preserved as background context, not as the primary decision surface.

The current canonical design set is:

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/flutter-hot-update-react-like-direction.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-long-term-overview.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-long-term-architecture.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-host-bridge-governance.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-bundle-lifecycle.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-bundle-and-tree-contract.md`

Some discussion points below were later narrowed, replaced, or split into those design docs.

## Context

The broad route survey has been completed for now.
The active focus is the React-like dynamic runtime direction rather than general hot-update route comparison.

## Stable Baseline

- Host shell stays fixed.
- Player core stays fixed.
- Dynamic capability is aimed at the player-facing business shell.
- The chosen expression model is currently closer to React-like runtime than pure schema.

## Current Focus

The next discussion should stay centered on the React-like route, especially:

- runtime shape
- host API boundary
- business-shell capability model
- bundle model
- compatibility and rollout model

## Non-Focus For Now

- re-opening the full route comparison from scratch
- bottom-layer playback engine replacement
- deep performance tuning before the capability boundary is clear

## Working Questions

- What is the smallest React-like runtime capability that still solves the player business-shell problem?
- What host player API surface should be standardized first?
- How should the runtime bundle model be shaped for safe update and rollback?
- Which parts of the player-related flow should remain permanently non-dynamic?

## Session Record: 2026-04-08

### Discussion Method

- Continue by clarifying one working question at a time rather than forcing an early architecture decision checklist.
- The current session mainly narrowed `Q1` and did not try to close `Q2` to `Q4`.

### Provisional Understanding For Q1

- The target player is not a general-purpose player with broad traditional player features.
- The fixed player core is intentionally small and centered on `play`, `pause`, and queue playback.
- The main dynamic target is the business orchestration built on top of that fixed core rather than the playback engine itself.

### Current Layering Hypothesis

- Host fixed layer: playback execution, queue execution, and low-level stability-critical capability.
- Server logic layer: the primary path for day-to-day playback logic, likely expressed as a finite-state-machine or rule-tree model and executed locally after fetch.
- Hot update layer: a secondary path for emergency repair or changes that are awkward to express cleanly in the server logic model.

### Data vs Logic Boundary

- Simple resource-set changes such as `A-C` growing to `A-D` do not by themselves justify hot update.
- Many resource additions or replacements can stay in the normal server-data path.
- The stronger hot-update target is change in playback business logic and orchestration rather than simple data replacement.

### Runtime Responsibility Direction

- The business-logic discussion was reframed as `state + event + decision + action`.
- The most important dynamic part is still the decision layer: how the next playback step is chosen from current state and events.
- Player actions should remain executed through fixed host APIs even when the decision logic becomes dynamic.

### Update Rhythm And Switch Model

- Business logic is expected to change at a low frequency, roughly on a weekly cadence, with occasional small surprise updates.
- `Pull` is the primary update mechanism; `push` is not required as the main path.
- The playback session may stay alive for a long time, but each item is a short video unit of roughly `2s`.
- A safe logic switch point is after the current item ends and before the next item starts.
- Mid-item logic switching is not currently desired.

### Open Point Left For Practice

- A previous version already explored the finite-state-machine or rule-tree route.
- The next practical step should validate how far that model can carry daily playback orchestration before hot update needs to take over.

## Notes

- Keep new discussion here unless a subtopic becomes large enough to deserve its own file.
- Promote stable outcomes into the design doc when they stop being open discussion.
