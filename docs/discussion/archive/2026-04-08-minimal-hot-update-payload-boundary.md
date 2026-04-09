# Minimal Hot Update Payload Boundary

Status: archived
Scope: Historical boundary definition for the discarded local JSON payload demo route.
Source of truth: /Users/zyyziyunying/flutter-hot-update-lab/docs/design/flutter-hot-update-react-like-direction.md
Last updated: 2026-04-09

## Archive Note

This discussion record is preserved only as historical context.

Its conclusions supported the earlier local JSON payload demo route, which is no longer the active architecture for this repository.
The current direction is the React-like JS runtime route defined in:

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/flutter-hot-update-react-like-direction.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/design/react-like-runtime-long-term-overview.md`

## Historical Content

The current plan is to build a very small demo before discussing a heavier runtime architecture.
The demo should prove one narrow thing:

- the Flutter host stays fixed
- a local payload can be replaced
- the replacement changes real UI or logic behavior

To keep the demo useful and cheap, the first payload boundary must be intentionally small.

## First Decision

The first demo should use `mixed minimal` rather than `UI-first` or `logic-first`.

That means:

- the payload changes a small visible UI detail
- the payload also changes a small interaction behavior

This is the best first cut because it avoids a weak demo that only changes copy or color, while also avoiding the complexity of a general-purpose runtime.

## Demo Goal

The first demo should show:

- a fixed host page
- one locally loaded payload file
- a tiny rendered UI tree
- one button action
- one small state update difference between payload variants

The host code should not change when switching payload A and payload B.

## Supported Payload Shape

The first payload version should support only these fields:

- `version`
- `screen`
- `type`
- `children`
- `text`
- `style`
- `action`
- `action.type`
- `action.delta`

## Supported Node Types

The first payload version should support only these node types:

- `column`
- `text`
- `button`
- `container`

## Supported Style Subset

The first payload version should support only a very small style subset:

- `padding`
- `backgroundColor`
- `textColor`
- `fontSize`

If a style field is not supported, it should be ignored rather than triggering framework growth.

## Supported Action Model

The first payload version should support only one action model:

- `increment_counter`

Required action fields:

- `type`
- `delta`

This keeps the first logic boundary extremely clear:

- the host owns state storage and update execution
- the payload only describes the allowed action and its parameter

## Explicit Non-Scope

The first payload version must not support:

- navigation
- network access
- loops or arbitrary conditions
- custom expressions
- embedded scripts
- general event buses
- list rendering
- user input fields
- arbitrary widget registration
- general-purpose styling system

If one of these becomes necessary during implementation, that should be treated as a new discussion, not as an implicit expansion of the first demo.

## Proposed Payload Contract

The first payload can use a simple JSON shape like this:

```json
{
  "version": 1,
  "screen": {
    "type": "column",
    "children": [
      {
        "type": "text",
        "text": "Counter Demo A",
        "style": {
          "fontSize": 24,
          "textColor": "#111111"
        }
      },
      {
        "type": "text",
        "text": "Tap the button to change the counter",
        "style": {
          "fontSize": 14,
          "textColor": "#666666"
        }
      },
      {
        "type": "button",
        "text": "Add",
        "action": {
          "type": "increment_counter",
          "delta": 1
        }
      }
    ]
  }
}
```

## Variant Intent

Payload A should prove:

- one title
- one subtitle
- one button
- action delta is `1`

Payload B should prove:

- title text changes
- maybe one color or padding value changes
- action delta becomes `2`

This makes the difference observable both in UI and in behavior.

## Host Responsibilities

The host should own:

- loading the local payload
- validating the allowed shape lightly
- rendering the supported nodes
- holding the current counter state
- executing the supported action
- exposing a reload action for manual testing

## Payload Responsibilities

The payload should own only:

- what minimal nodes to show
- what text to display
- what tiny style values to use
- what allowed action parameter to send

## Why This Boundary Is Good Enough For The First Demo

- It is small enough to implement quickly.
- It proves both visual and behavioral replacement.
- It avoids premature runtime or scripting complexity.
- It gives a concrete first look at the host/dynamic boundary.

## Open Questions Left For Later

- Should later versions allow conditional rendering?
- Should later versions allow list data?
- Should later versions allow navigation actions?
- Should later versions move from JSON to a stronger bundle format?

These questions are intentionally postponed until the first demo exists.
