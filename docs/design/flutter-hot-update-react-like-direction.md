# Flutter Hot Update React-Like Direction

Status: active
Scope: Current stable direction for the Flutter hot update architecture in this repository.
Source of truth: this file
Last updated: 2026-04-08

## Context

The target environment is not a normal consumer mobile app iteration loop.
The Flutter business is expected to run on hardware devices, so remote update value is materially higher than ordinary app convenience.

## Problem Statement

The project needs a hot-update strategy that improves iteration and operational experience versus repeated full APK replacement, especially for high-change business flows around media playback and interaction.

## Stable Conclusions

- True arbitrary Flutter/Dart release-code hot update is not the target direction.
- The more realistic shape is a preinstalled Flutter host plus a controlled dynamic business layer.
- The dynamic target is not the deepest playback engine.
- The dynamic target is the player-facing business shell: UI, interaction flow, orchestration, and resource-loading strategy.

## Chosen Architectural Direction

Use:

- a fixed host shell
- a fixed native or Flutter-side player core
- standardized host player capabilities
- a React-like dynamic runtime for selected business surfaces

Do not use as the primary target:

- unrestricted executable code replacement of the whole Flutter app

## Why This Direction Won

- It is much more realistic than full post-release code replacement.
- It is much more expressive than remote config alone.
- It is better aligned with complex interaction-flow needs than a narrow schema-only approach.
- It preserves a clean boundary between stable media capability and fast-changing business logic.

## Boundary

Keep in the host shell:

- playback core
- decoder and DRM integration
- hardware and platform-specific access
- low-level media state and capability ownership

Allow the dynamic layer to control:

- page composition
- interaction flow
- business state
- player orchestration
- resource selection and business-level loading strategy
- experiment logic and operational adjustments

## Strategic Position

The React-like route should currently be treated as:

- a priority research direction
- a likely high-flexibility capability for selected surfaces
- not yet the universal default architecture for every part of the application

## Related Docs

- active discussion: /Users/zyyziyunying/flutter-hot-update-lab/docs/discussion/2026-04-08-react-like-dynamic-runtime.md
- archived broad research log: /Users/zyyziyunying/flutter-hot-update-lab/docs/discussion/archive/2026-04-07-flutter-hot-update-technical-research.md
