# Minimal Hot Update Demo Plan

Status: active
Scope: Execution plan for a first exploratory demo of local UI or logic hot update in a fixed Flutter host.
Source of truth: this file
Last updated: 2026-04-08

## Context

Current design direction already favors a fixed host plus a controlled dynamic business layer.
Recent discussion concluded that the next step should not be a full runtime architecture decision.
The next step should be a small working demo that tests whether the direction is practical and understandable.

Related inputs:

- `docs/design/flutter-hot-update-react-like-direction.md`
- `docs/discussion/2026-04-08-react-like-dynamic-runtime.md`
- `docs/discussion/2026-04-08-fuckjs-demo-analysis.md`
- `docs/discussion/2026-04-08-minimal-hot-update-payload-boundary.md`

## Requirements Summary

Build a first demo that proves one narrow point:

- the Flutter host stays fixed
- a local dynamic payload can be replaced without changing host page code
- the replaced payload can change either visible UI or a small piece of interaction logic

The goal is exploration, not production readiness.

## Non-Goals

Do not include in this first demo:

- remote download
- security hardening
- rollback infrastructure
- full dynamic navigation system
- large widget set
- full JS runtime or general-purpose scripting engine

## Acceptance Criteria

- There is a single fixed Flutter host screen for the demo.
- The demo reads a local dynamic payload from a replaceable file or equivalent local source.
- The payload can express a minimal UI composed from a very small supported set.
- The payload can change at least one interaction behavior without host code changes.
- At least two payload variants exist and can produce clearly different results.
- The switching flow is simple enough for manual repeatable testing.
- The result is documented with what worked, what felt awkward, and what boundary questions appeared.

## Proposed Demo Shape

Use the lightest possible form:

- fixed Flutter page
- local payload file
- minimal supported view model or DSL
- one tiny stateful interaction such as a counter action

Preferred initial supported capability set:

- `Column`
- `Text`
- `Button`
- `Container`
- one simple action such as incrementing or changing displayed text

Preferred update shape:

- swap local payload A and payload B
- reload from host action
- observe UI or logic difference without modifying host page code

## Implementation Steps

### 1. Define the smallest demo boundary

Decide the exact first payload shape before coding.
Choose one of these as the first-class target:

- UI-first: payload mainly changes layout and labels
- logic-first: payload mainly changes button behavior
- mixed minimal: payload changes both a small layout detail and a small action

Expected output:

- one chosen demo shape
- one explicit list of supported fields
- one explicit list of unsupported features

### 2. Create a fixed host demo screen

Add one isolated Flutter screen or module dedicated to the experiment.
Keep host responsibilities intentionally narrow:

- load payload
- validate payload shape lightly
- render the supported nodes
- expose one reload action for manual testing

Expected output:

- host screen exists
- no business-specific assumptions leak into the host beyond the minimal supported contract

### 3. Implement the minimal payload interpreter

Implement only the smallest mapping needed for the demo.
Avoid abstraction growth.
Use a tiny renderer or interpreter that understands only the agreed supported set.

Expected output:

- payload-to-widget rendering for the selected minimal node types
- one simple action model for interaction changes

### 4. Create two clearly different payload samples

Prepare two local payload variants to prove update value.
The difference must be obvious and intentional.

Examples:

- variant A shows one title and a `+1` action
- variant B shows different copy and a `+2` action

Expected output:

- payload A
- payload B
- clear manual procedure to switch and reload

### 5. Run manual verification and record findings

Verify the demo manually and write down the result while the context is fresh.
The purpose is not just "it works", but "what does this teach us about the boundary".

Expected output:

- basic test notes
- friction points
- next boundary questions

## Risks And Mitigations

### Risk: Scope expands into a framework too early

Mitigation:

- cap supported node types tightly
- reject general-purpose extensibility in the first pass

### Risk: The demo proves too little

Mitigation:

- require at least one logic difference, not only static text changes

### Risk: The demo proves too much in the wrong direction

Mitigation:

- do not introduce a full script engine or large runtime in this phase
- keep the demo focused on boundary exploration, not technology novelty

### Risk: Host responsibilities become blurry

Mitigation:

- keep all unsupported behavior in host code comments or notes as explicitly out of scope

## Verification Steps

- Load payload A and confirm the expected UI appears.
- Trigger the supported interaction and confirm the expected behavior occurs.
- Switch to payload B without host code changes.
- Reload the demo and confirm the visible or logical behavior changes as intended.
- Confirm unsupported input fails in a controlled and understandable way, if validation is added.
- Record the outcome in a discussion or status doc after implementation.

## Exit Conditions For This Plan

This plan is complete when:

- a minimal local hot-update demo exists
- the demo shows real UI or logic replacement value
- the team can answer whether this direction feels practical enough to continue

## Follow-up After Completion

Depending on what the demo teaches, the next step should be one of:

- expand the supported payload shape slightly
- test a more realistic player-business interaction
- compare this lightweight approach against a stronger runtime-based approach
