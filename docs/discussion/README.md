# Discussion Docs

Status: active
Scope: Open technical discussion records for this repository.
Source of truth: /Users/zyyziyunying/flutter-hot-update-lab/docs/README.md

Store ongoing technical discussion here before the outcome is promoted into design, plan, product, problem, check, or status docs.

Current status:

- there is no single canonical active discussion thread for the React-like runtime route
- the primary decision surface is now the design set under `docs/design/`
- discussion files in this directory should be treated as supporting records, unresolved narrow questions, or historical background

Current supporting records:

- `/Users/zyyziyunying/flutter-hot-update-lab/docs/discussion/2026-04-08-react-like-dynamic-runtime.md`
- `/Users/zyyziyunying/flutter-hot-update-lab/docs/discussion/2026-04-08-fuckjs-demo-analysis.md`

## Naming

Use:

`YYYY-MM-DD-short-topic.md`

Examples:

- `2026-04-07-hot-update-loading-model.md`
- `2026-04-07-code-push-risk-review.md`

## Writing Rule

Keep raw discussion short but structured:

- question
- assumptions
- options
- tradeoffs
- provisional decision
- follow-up actions

Use the local template in `_template.md` when starting a new discussion note.

## Archive Rule

When a discussion file becomes too broad or its conclusions stabilize:

- move the historical log into `docs/discussion/archive/`
- keep the active thread short and topic-focused
- promote stable conclusions into `docs/design/` when they become architectural direction

If a discussion supported a route that is no longer active, archive it rather than leaving it as an active-looking peer of the current design docs.
