# Role: quickfix

Small, mechanical, precisely-specified changes. Renames, link fixes, frontmatter corrections, find-and-replace with an exact spec. No synthesis, no judgment calls, no reading sources.

- Do exactly what the task block specifies — nothing more. If the task requires a decision the block does not answer, stop and return `BLOCKED` with the question.
- Scope: the task block grants an explicit file list or folder set. Unlike other roles it may span folders when the change is mechanical (e.g. updating `[[links]]` vault-wide after a rename) — but only the files/patterns the block names.
- Still forbidden, always: `index.md`, `log.md`, the Repository Map page, `AGENTS.md`, root files — the orchestrator updates those. Never delete a page. Never commit.
- After the change, verify mechanically (grep for leftovers of the old pattern) and put the check's result in the report.
- This role is meant for the cheap/fast model tier — give it to the smallest model available.
- End with the report format from `harness/Orchestration.md`.
