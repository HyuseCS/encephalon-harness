---
name: sync
description: Update the vault from the repositories listed in Repository Map, and (interactive only) ingest files waiting in the raw/ inbox. Use when the user says /sync, "sync the vault", "update from the repos", or asks whether repo pages are stale. Arguments - headless, on, off, status.
---

# Sync — keep the vault current with the repos

You are in this vault. Follow `AGENTS.md` for all writing. This skill adds one operation: diff every mapped repository against the vault and update only what changed.

**Orchestration:** when the scout pass finds changes in two or more independent territories, follow `harness/Orchestration.md` — one `vault-ingester` worker per territory, bookkeeping and the single commit stay with the orchestrator. One territory → work inline.

## Arguments

- (none) — full interactive sync: repos + raw/ inbox.
- `headless` — repos only. No questions, no inbox ingest. Used by the systemd timer.
- `add <url>` — clone a remote repo and ingest it. See "Adding a repo by URL" below.
- `memories` — optional pass, only when asked: merge Claude Code project memories into the vault. See "Memories pass" below. Never runs as part of a plain or headless sync.
- `on` — run `systemctl --user enable --now encephalon-sync.timer`, then report status.
- `off` — run `systemctl --user disable --now encephalon-sync.timer`, then report status.
- `status` — report: timer state (`systemctl --user status encephalon-sync.timer`), next run time (`systemctl --user list-timers encephalon-sync.timer`), last lines of `scripts/sync.log`, and count of files waiting at the root of `raw/`.

`on`, `off`, and `status` do only that. The rest of this file is for a real sync run.

## Adding a repo by URL

`/sync add <url>` — the url may be a full URL (`https://github.com/owner/repo`) or GitHub shorthand (`owner/repo`). No permanent clone is kept.

1. Shallow-clone into the session scratchpad (`git clone --depth 1` via `gh repo clone owner/repo <scratchpad>/<name> -- --depth 1`) just for the first read. `gh` is already authenticated, so private repos work.
2. Add a row to the Remote repositories table in your Repository Map page: `github:owner/repo`, a readable `[[Note]]` name per the AGENTS.md renaming rules, and a short note.
3. Run the normal new-repo ingest from the Sync procedure below: hub note plus children, `synced_commit:` stamp (the remote HEAD sha), `index.md`, `log.md`, one commit. `source:` lines cite the GitHub URL, not the temp clone.
4. Delete the temp clone.

From then on the weekly sync tracks it through the GitHub API — nothing is stored on disk.

## Memories pass (`/sync memories`)

Optional and explicit — a plain `/sync` never does this. Claude Code only (other tools: skip).

1. List `~/.claude/projects/*/memory/*.md`. The directory name encodes the project path; map it to the vault page via your Repository Map page.
2. For each memory file changed since the target page's `updated:` date: read it, keep only durable facts (skip session-scoped notes), and merge them into the matching project page. Cite the memory file in `source:`.
3. Contradiction check per AGENTS.md: a memory that disagrees with a page gets a `## Conflicts` entry, not a silent overwrite.
4. Never read session transcripts (`*.jsonl`).
5. Bookkeeping as usual: index/log if pages changed, one commit.

## Sync procedure

1. Read `AGENTS.md`, `index.md`, and your Repository Map page. The map is the registry: every repo row in its Paths table (skip rows marked "not a repo itself") plus the coursework repos section.
2. If the vault git tree is dirty, commit it first with message `pre-sync snapshot`.
3. For each repo. Two kinds, told apart by the map's Path column:
   **Local** (an absolute path on disk):
   - Find its hub note (the `[[Note]]` in the map row). Read its frontmatter key `synced_commit:`.
   - If the repo path does not exist on disk: flag it in the final report, touch nothing.
   - If `synced_commit:` exists: run `git -C <path> log <sha>..HEAD --oneline --stat`. Empty output → up to date, skip.
   - If `synced_commit:` is missing but the hub note exists (first run): use `git -C <path> log --since=<hub note's updated: date> --oneline --stat` instead.
   **Remote** (`github:owner/repo` — no local copy exists):
   - Diff with one API call: `gh api repos/owner/repo/compare/<synced_commit>...HEAD --jq '{total: .total_commits, files: [.files[].filename], msgs: [.commits[].commit.message]}'`. `total: 0` → up to date, skip.
   - Read a changed file with `gh api -H "Accept: application/vnd.github.raw" repos/owner/repo/contents/<path>`. Read only the files the diff names — docs first.
   - The new `synced_commit:` sha comes from `gh api repos/owner/repo/commits/HEAD --jq .sha`.
   - API or network failure → flag the repo in the report and skip it; never guess.
   **Both**: if the hub note does not exist, this is a **new repo** — full ingest per AGENTS.md section 5 (remote: via a temp shallow clone in the scratchpad, deleted after; headless: keep it to doc files and structure, no deep code reading).
   - For repos with new commits: read the commit messages, the changed files that matter (docs first: README, PRODUCT.md, DESIGN.md, AGENTS.md, process/, docs/ — then source files the commits touched), and update the affected vault pages. Distill, never dump. Run the contradiction check from AGENTS.md.
   - Stamp the hub note: set `updated:` to today and `synced_commit:` to the repo's current HEAD sha (local: `git -C <path> rev-parse HEAD`; remote: the API sha from above). Stamp even when you skipped for "no new commits" only if the key was missing.
4. **Interactive only**: list files at the root of `raw/` (not `raw/ingested/`). For each, run the normal Ingest operation from AGENTS.md — takeaways to the human first, then pages, then move the file into `raw/ingested/`. **Headless**: do not touch them; count them for the report.
5. Update `index.md` for any pages added or removed. Append one entry to `log.md` summarizing the run (repos checked, repos updated, pages touched, inbox count).
6. Commit everything as one commit. Message describes the change (e.g. `Sync: update Parasat and Veent HRIS pages`). No push. No co-author trailer, no AI attribution.
7. Report per repo: skipped / updated (with page names) / new / missing. Headless: this report is the final message; keep it short.

## Cost rule

Do not re-read a whole repo because it has commits. Read what the diff points at. A repo with 3 small commits is a 3-file read, not a re-ingest.
