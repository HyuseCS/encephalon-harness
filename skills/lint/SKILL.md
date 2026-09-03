---
name: lint
description: Health-check the vault - contradictions, stale claims, orphan pages, index drift, malformed frontmatter. Use when the user says /lint, "health-check the vault", "lint the vault", or after every ~10 ingests.
---

# Lint

The checklist is `AGENTS.md` section 5 (Lint). Orchestration and worker discipline are in `harness/Orchestration.md` and `harness/roles/linter.md`. This skill only routes.

## Arguments

- (none) — whole vault.
- `<folder>` — that subtree only.

## Routing

1. Scoped to one folder → lint inline per the linter role.
2. Whole vault → follow `harness/Orchestration.md`: one `vault-linter` worker per top-level folder (00–06 plus root files as one territory), merge the ranked findings, fix the mechanical ones, ask before any deletion, one commit if anything changed, log entry.
3. Report findings to the user as one ranked list, worst first.
