# Encephalon Harness

An agent harness for LLM-maintained knowledge vaults (Obsidian-style second brains). It turns a bare coding agent — Claude Code, OpenCode, Codex CLI, Gemini CLI, Cline, pi, DeepSeek Harness — into a repeatable wiki maintainer: ingest sources into distilled pages, keep repo-backed pages synced, and health-check the vault, fanning big jobs out to parallel workers that never collide.

Extracted from a working vault where its first run ingested a 27-repo GitHub account across six parallel workers with zero write conflicts.

## How it works

- **One canonical file.** Your vault carries an `AGENTS.md` that defines its folder schema and writing rules. Every tool reads it (natively or via a thin adapter). The harness never duplicates it.
- **`harness/` — the protocol.** `Orchestration.md`: scout first, scale effort (one territory of work → inline; more → one worker per territory), workers own exactly one folder subtree, bookkeeping files are orchestrator-only, workers return a fixed report and terminate. `roles/`: ingester, linter, scout disciplines.
- **Skills — the operations.** `/ingest`, `/lint`, `/sync`. Skills route; method lives in `harness/`.
- **Degrades to sequential.** Orchestration is written as ordered task lists with independence notes. Tools without subagents (Cline, Aider) run the same lists top to bottom.

## What your vault needs

1. An `AGENTS.md` describing your folder layout, page format, and writing rules (see [agents.md](https://agents.md/)). The skills reference its Ingest/Lint sections by convention.
2. An `index.md` catalog and a `log.md` timeline (or adjust the bookkeeping list in `harness/Orchestration.md` to your own files).
3. For `/sync`: a "Repository Map" page listing repos as local paths or `github:owner/repo` refs. Synced pages carry a `synced_commit:` frontmatter key.

## Install

### Any tool (the universal step)

Copy the protocol into your vault root:

```sh
cp -r harness/ /path/to/your/vault/harness/
```

### Claude Code (plugin)

```sh
claude plugin marketplace add <your-github-user>/encephalon-harness
claude plugin install encephalon-harness
```

Or without the marketplace: copy `skills/*` into `.claude/skills/` and `agents/*` into `.claude/agents/` in the vault.

### Codex CLI / pi / DeepSeek Harness

Read `AGENTS.md` natively. Symlink the skills:

```sh
ln -s /path/to/encephalon-harness/skills /path/to/your/vault/.codex/skills
```

(pi: `~/.pi/agent/skills/`; dsh: its skills plugin dir.)

### OpenCode

Reads `AGENTS.md` natively. Copy `adapters/opencode/agent/*` into `.opencode/agent/`.

### Gemini CLI

Copy `adapters/gemini/settings.json` into `.gemini/` (it makes Gemini load `AGENTS.md`).

### Cline

Copy `adapters/clinerules/00-harness.md` into `.clinerules/`. Cline is single-thread; the harness runs sequentially there.

### Scheduled headless sync (optional, systemd)

`scripts/sync.sh` runs `/sync headless` with a restricted toolset; `systemd/*.timer` schedules it weekly. Edit the vault path in both, then:

```sh
cp systemd/encephalon-sync.* ~/.config/systemd/user/
systemctl --user enable --now encephalon-sync.timer
```

## Design lineage

The design applies published multi-agent principles — orchestrator-worker, context isolation, territory ownership, condensed structured reports, generator ≠ verifier, degrade-to-sequential — from [Anthropic's multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system), [Cognition's counter-argument](https://cognition.ai/blog/dont-build-multi-agents), and the [AGENTS.md standard](https://agents.md/).

## License

MIT
