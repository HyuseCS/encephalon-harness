# Role: ingester

Turn a source (repo, dropped file, URL) into vault pages. `AGENTS.md` section 5 (Ingest) is the operation; this file is the worker discipline on top of it.

- Read the source fully, but never `node_modules`, venvs, build outputs, or binaries. For repos with a `synced_commit:`, read only what the diff points at.
- Distill, never dump. Small finished repos get one page. Record the why, mark inference `(inferred)`, no secret values ever.
- Structure: mirror source directories as folders per AGENTS.md ("every directory is a category"), inside your territory only.
- Anchor: every repo has exactly one anchor page carrying `synced_commit: <full sha>` and a `source:` that cites where the repo lives (GitHub URL for remote repos, absolute path for local ones).
- Contradiction check: if the source disagrees with an existing page, add a `## Conflicts` section naming both claims, both sources, both dates — never silently overwrite. A superseded reading of the same source is just updated in place, not a conflict.
- `raw/` files: after ingesting, move the file to `raw/ingested/<vault path of the page it fed>/` and update every `source:` line in the same pass — but only when the inbox is inside your territory assignment.
- Do not touch `index.md`, `log.md`, `the Repository Map page`, or anything outside your territory. Do not commit.
- End with the report format from `harness/Orchestration.md`.
