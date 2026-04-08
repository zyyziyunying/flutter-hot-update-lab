# Minimal Hot Update Demo Result

Status: active
Scope: Current result snapshot for the first local hot-update demo.
Source of truth: this file
Last updated: 2026-04-08

## Outcome

The first minimal demo has been implemented as a standalone Flutter app at:

- `/Users/zyyziyunying/flutter-hot-update-lab/demo/minimal_hot_update_demo`

The demo now proves these points:

- the host page is fixed
- the host loads a local payload file
- payload A and payload B can replace each other without host code changes
- the visible UI changes when the payload changes
- the button behavior also changes when the payload changes

## What Was Built

- a standalone Flutter macOS demo app
- a local payload repository seeded from bundled JSON payloads
- a tiny payload renderer for `column`, `text`, `button`, and `container`
- one supported action model: `increment_counter`
- two payload variants:
  - payload A uses `delta = 1`
  - payload B uses `delta = 2`

## What Worked

- The fixed host and dynamic payload boundary is understandable at this size.
- JSON is sufficient for the first proof of concept.
- The host can stay narrow and still make the demo useful.
- A mixed minimal demo is better than a purely visual demo because it proves both rendering and behavior replacement.

## What Felt Awkward

- The current payload model is intentionally tiny and becomes limiting almost immediately.
- The host still owns all state execution, so this is not yet a strong logic runtime.
- The payload switching flow is controlled by host buttons, so it is a local exploration tool rather than an update system.

## Verification

The following checks passed inside `demo/minimal_hot_update_demo`:

- `flutter analyze`
- `flutter test`
- `flutter build macos --debug`

## Immediate Next Questions

- Should the next iteration add conditional rendering or keep the model static a little longer?
- Should the next iteration add one realistic player-business action instead of a generic counter?
- At what point does JSON stop being enough and a stronger bundle model become necessary?
