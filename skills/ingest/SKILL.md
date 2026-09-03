---
name: ingest
description: Ingest sources into the vault - files waiting in the raw/ inbox, a path, a URL, or a repo. Use when the user says /ingest, "read this and file it", "ingest this", drops a file into raw/, or pastes a document to be filed.
---

# Ingest

The operation is `AGENTS.md` section 5 (Ingest). Orchestration and worker discipline are in `harness/Orchestration.md` and `harness/roles/ingester.md`. This skill only routes.

## Arguments

- (none) — process everything at the root of `raw/` (the inbox).
- `<path or URL>` — ingest that source. A repo URL should go through `/sync add` instead.

## Routing

1. Scout the work: count sources, map each to its target vault territory.
2. One territory → ingest inline per the ingester role, with the human shown takeaways first (AGENTS.md rule).
3. Multiple independent territories → follow `harness/Orchestration.md`: one `vault-ingester` worker per territory, task block per worker, orchestrator does index/log/map bookkeeping, one commit, lint pass over touched folders after.
4. Batch mode (no per-source pause) only when the user says so.
