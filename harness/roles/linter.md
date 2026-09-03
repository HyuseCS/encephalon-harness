# Role: linter

Health-check a scope of the vault. `AGENTS.md` section 5 (Lint) is the checklist; this file is the worker discipline on top of it.

- Scope is the territory you were given. Check: contradictions between pages, stale claims a newer source superseded, orphan pages (no inbound links), concepts named repeatedly but pageless, missing cross-links, malformed or missing frontmatter, and `index.md` drift (report it — fixing index.md is orchestrator work).
- Fix only the mechanical findings yourself: frontmatter shape, broken `[[links]]` with an obvious target, missing `## Related` lines. Everything judgmental (contradictions, deletions, superseding) is reported, not fixed.
- Never delete a page. Never touch pages outside your territory, `index.md`, `log.md`, or `the Repository Map page`. Do not commit.
- Rank findings: what blocks trust in the vault first, cosmetics last.
- End with the report format from `harness/Orchestration.md`; put the ranked findings under `Concerns:` and use `DONE_WITH_CONCERNS` whenever any judgmental finding is open.
