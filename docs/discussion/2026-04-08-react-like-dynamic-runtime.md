# React-Like Dynamic Runtime Discussion

Status: active
Scope: Ongoing focused discussion for the React-like dynamic business-layer route for Flutter hot update.
Source of truth: /Users/zyyziyunying/flutter-hot-update-lab/docs/design/flutter-hot-update-react-like-direction.md
Last updated: 2026-04-08

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

## Notes

- Keep new discussion here unless a subtopic becomes large enough to deserve its own file.
- Promote stable outcomes into the design doc when they stop being open discussion.
