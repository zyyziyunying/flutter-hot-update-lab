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

Run Codex in this isolated environment:

```sh
cd /Users/zyyziyunying/flutter-hot-update-lab
./bin/codex-lab
```

Run OMX commands in this isolated environment:

```sh
cd /Users/zyyziyunying/flutter-hot-update-lab
./bin/omx-lab doctor
./bin/omx-lab
```

## Minimal Demo

Run the first local hot-update demo:

```sh
cd /Users/zyyziyunying/flutter-hot-update-lab/demo/minimal_hot_update_demo
flutter run -d macos
```

Verify the demo app:

```sh
cd /Users/zyyziyunying/flutter-hot-update-lab/demo/minimal_hot_update_demo
flutter analyze
flutter test
```

## Notes

- This setup isolates the user skill/config layer, not the global `codex` binary.
- If you want the local doc skill to track your latest edits, keep the symlink in `.home/.codex/skills/project-doc-governance`.
