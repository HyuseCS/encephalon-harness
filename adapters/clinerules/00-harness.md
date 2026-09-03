# Harness rules for Cline

Read `AGENTS.md` first — it is the canonical schema and operating manual for this vault. Then read `index.md`.

Cline has no subagents. When a harness task list from `harness/Orchestration.md` says tasks are independent, run them sequentially, top to bottom, applying the matching role file from `harness/roles/` to each. All other rules (territories, bookkeeping, report format) apply unchanged.
