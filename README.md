# Flutter Hot Update Lab

This directory is an isolated Codex environment for the Flutter hot update project.

## Project Goals

This lab currently has two primary goals:

- Test and validate skills, especially `doc` and `oh-my-codex`
- Research and prototype a self-developed hot update solution for Flutter

## What is isolated

- User-installed skills, prompts, agents, config, and hooks live under `.home/.codex/`
- `oh-my-codex` is installed under `.npm-global/`
- Runtime artifacts from `omx` live under `.omx/`

The main `~/.codex` is not used by the launch scripts here, except that `.home/.codex/auth.json` points to your existing login file so you do not need to log in again.

## Installed skill sources

- `oh-my-codex` user-scope install
- local `project-doc-governance` skill from `/Users/zyyziyunying/project-doc-governance`

## Usage

This repo provides two local launchers. They are not mutually exclusive skill-loading modes.

Run Codex in this isolated environment:

```sh
cd /Users/zyyziyunying/flutter-hot-update-lab
./bin/codex-lab
```

- Starts Codex with the repo-local `HOME` and `CODEX_HOME`
- Best for normal Codex usage in the lab environment
- Installed skills can still coexist in the same session when they are present in the visible skill path

Run OMX commands in this isolated environment:

```sh
cd /Users/zyyziyunying/flutter-hot-update-lab
./bin/omx-lab doctor
./bin/omx-lab
```

- Starts OMX runtime in the same lab-local environment
- Best when you want OMX runtime workflows such as `ralph`, `team`, or `ultrawork`

Skill loading note:

- OMX skills and `project-doc-governance` can both be available in the same session
- Skill visibility is separate from activation: a visible skill only runs when the task explicitly invokes it or matches its trigger rules
- If you want full OMX runtime behavior, prefer `./bin/omx-lab`

## Current Direction

The active technical route in this repository is the React-like JS runtime path with a Flutter native renderer.

Start with:

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/status/2026-04-09-react-like-runtime-doc-map.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/plan/2026-04-08-react-like-js-runtime-poc-plan.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/plan/2026-04-09-react-like-runtime-poc-implementation-plan.md`

This repository is currently documentation-first for that route.
The active PoC demo now exists at `demo/react_like_runtime_poc`.

Run it with:

```sh
cd /Users/zyyziyunying/flutter-hot-update-lab/demo/react_like_runtime_poc
flutter run -d macos
```

Rebuild the committed JS bundle assets with:

```sh
cd /Users/zyyziyunying/flutter-hot-update-lab/demo/react_like_runtime_poc/js
npm install
npm run build
```

## Historical Demo

The standalone `demo/minimal_hot_update_demo` flow is preserved as historical and transitional local validation only.
It is not the current product direction for the active React-like runtime route.

If you need to inspect the older local demo path, run:

```sh
cd /Users/zyyziyunying/flutter-hot-update-lab/demo/minimal_hot_update_demo
flutter run -d macos
```

Verify that historical demo with:

```sh
cd /Users/zyyziyunying/flutter-hot-update-lab/demo/minimal_hot_update_demo
flutter analyze
flutter test
```

For the current PoC implementation result, see:

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/status/2026-04-09-react-like-runtime-poc-result.md`

## Notes

- This setup isolates the user skill/config layer, not the global `codex` binary.
- If you want the local doc skill to track your latest edits, keep the symlink in `.home/.codex/skills/project-doc-governance`.
