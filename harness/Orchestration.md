# Orchestration — how vault work is split and merged

This protocol is tool-agnostic. It binds any agent working in this vault, whether or not the tool can spawn subagents. Roles referenced here live in `harness/roles/`.

## The loop

1. **Scout first.** Size the work before touching pages: git diff or API compare for repos, a file count for the inbox, a folder list for lints. Cheap reads only. For big jobs, use the scout role (`harness/roles/scout.md`).
2. **Scale effort.**
   - One territory of work → do it inline. No workers, no ceremony.
   - Two or more independent territories → one worker per territory.
   - Parallel reads are always safe. Parallel writes only across disjoint territories.
3. **Degrade gracefully.** Express fan-out as an ordered task list with the note "these tasks are independent". Tools with subagents run them in parallel; single-thread tools run the same list top to bottom. Never write tool-specific spawn syntax into a task list.
4. **Dispatch workers.** A worker gets: the role file to follow, plus an inline task block with the specifics — source paths, target folder, shas, anything the role file cannot know. Durable method lives in the role file; per-task facts go inline.
5. **Collect, verify, close out.** The orchestrator merges reports, updates the bookkeeping files, and makes one commit. After any multi-worker ingest, run a lint pass over the touched folders — the verifier must be a different worker (or at least a fresh pass) than the writer.

## Territory rule

A worker owns exactly one vault folder subtree and writes nowhere else.
Orchestrator-only files — no worker may ever touch them:
- `index.md`
- `log.md`
- the Repository Map page
- `AGENTS.md` and the other root files
- hub notes outside the worker's territory

This is what makes parallel writes safe. Two workers in one folder is a protocol violation even if nothing collides.

## Worker contract

- Read `AGENTS.md`, then your role file, then the task block. In that order.
- Do the work inside your territory. Never git commit. Never respawn or delegate.
- Return the report (below) and terminate. The orchestrator drives all loops.

## Report format

Every worker ends with exactly this shape:

```
Status: DONE | DONE_WITH_CONCERNS | BLOCKED
Pages: <for each page created/updated: name — vault path — one-line catalog summary>
Anchors: <for repo-backed work: anchor page — full sha>
Conflicts: <each contradiction found, or "none">
Concerns: <only when status is not DONE — one line each>
```

The report is the only thing that crosses back to the orchestrator; it must be enough to write the `index.md` and `log.md` entries without re-reading the pages.

## Effort and model tiering

Where the tool allows choosing model or effort per worker: scouting, counting, and mechanical fixes run on the cheap/fast tier; page synthesis and contradiction judgment run on the capable tier. Where it does not, ignore this section.
