# Repository Guidelines

## Project Structure & Module Organization

This repository is a documentation-first lab, not yet a standard Flutter package. The root contains `README.md`, the local launcher scripts in `bin/`, and the documentation tree in `docs/`. Use `docs/README.md` as the source of truth for document placement:

- `docs/discussion/`: open technical exploration; name files `YYYY-MM-DD-short-topic.md`
- `docs/design/`: accepted technical direction and architecture notes
- `docs/plan/`: execution plans
- `docs/product/`, `docs/problem/`, `docs/check/`, `docs/status/`: requirements, risks, validation, and progress

Local runtime directories `.home/`, `.npm-global/`, and `.omx/` are generated for the isolated lab environment and must stay untracked.

## Build, Test, and Development Commands

- `./bin/codex-lab`: starts Codex with the repo-local `HOME` and `CODEX_HOME`
- `./bin/omx-lab doctor`: checks the isolated OMX setup
- `./bin/omx-lab`: runs OMX inside the lab environment
- `git diff -- docs/`: review doc-only edits before commit

There is no Flutter app, build pipeline, or automated test suite yet. If you add one, document the commands in `README.md` and update this guide.

## Coding Style & Naming Conventions

Write Markdown with short sections, direct prose, and concise bullets. Keep file names descriptive and consistent with the docs taxonomy. Discussion notes should follow `YYYY-MM-DD-short-topic.md`.

Shell scripts in `bin/` should remain POSIX `sh`, keep `set -eu`, and use uppercase environment variable names such as `LAB_ROOT` and `CODEX_HOME`.

## Testing Guidelines

For doc changes, verify paths, commands, and destination folders against the current tree. For script changes, run the affected command, for example `./bin/omx-lab doctor`, before opening a PR. No coverage target is defined yet; new checks should be added alongside the code they validate and documented in the repository.

## Commit & Pull Request Guidelines

Recent commits use short imperative subjects, sometimes with a conventional prefix, for example `chore: initialize flutter hot update lab`. Prefer one topic per commit.

PRs should explain the intent, list the main paths changed, and note how the change was validated. Include terminal output snippets or screenshots only when they clarify script behavior or rendered documentation changes.

## Security & Configuration Tips

Do not commit `.home/`, `.npm-global/`, `.omx/`, local auth files, or symlinked credentials. Treat the isolated lab environment as local-only configuration.
