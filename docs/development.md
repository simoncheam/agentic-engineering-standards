# Development & Setup Guide

How to install, use, and work on this agentic layer. This file is the living process record: **every development or build process established in this repo gets documented here when it's established** — a process that lives only in someone's head or a chat transcript doesn't exist.

## Prerequisites

- [Claude Code](https://claude.ai/code) CLI installed and authenticated
- `git`
- Python 3.10+ with `uv` (only for the orchestration layer, once it exists)

## Installing the skills (user-level, symlinked)

The daily-driver deployment (AD-5 mode 1) is **symlinks from `~/.claude/skills/` into this repo**. Nothing is copied: the deployed skill *is* the repo file, so edits here are live everywhere instantly and drift is impossible.

From the repo root:

```bash
mkdir -p ~/.claude/skills
for s in .claude/skills/*/; do
  name=$(basename "$s")
  ln -sfn "$(pwd)/.claude/skills/$name" ~/.claude/skills/"$name"
done
```

`ln -sfn` is idempotent — re-run it after pulling new skills. To uninstall, remove the symlinks (`rm ~/.claude/skills/<name>`); the repo is untouched.

### Verify the install

Interactive: open any repo in Claude Code and type `/branch` — the skill should load and ask for a ticket ref or description (it does nothing without one).

Headless (what the orchestration layer depends on): from any target repo,

```bash
claude -p "/branch" --output-format text
```

Expected: the skill expands and asks for a name, mutating nothing. If Claude instead treats `/branch` as literal text, user-level discovery isn't working — check that the symlink resolves (`ls -la ~/.claude/skills/`) and that `HOME` is intact in the environment you're running under.

## Editing skills

1. Edit the skill in this repo (`.claude/skills/<name>/SKILL.md`). Because of the symlinks, the change is live in every session immediately — no redeploy step.
2. Commit normally. All version control happens in this repo; `~/.claude/skills/` holds only pointers with no history of their own.

**Convention — skill-bundled templates:** a template that a *skill* consumes lives inside that skill's directory (e.g. `.claude/skills/start-ticket/plan-template.md`) so it travels with the skill to any machine or repo. `.claude-context/templates/` holds only human-facing shapes (bug report, PR) that no skill depends on.

## Deployment modes (summary)

| Mode | When | How |
|---|---|---|
| User-level symlinks | This machine, daily use | The loop above. Canonical for development. |
| Per-repo copy | A repo that must be self-contained (public, CI, teammates) | `/deploy-config` (planned) — a one-way copy from this repo; re-run to update. |
| Workspace root | Multi-repo workspace wanting a shared layer | Supported but deferred — see AD-11; orchestration targets repos by explicit path instead. |

## Orchestration layer

Lives in `.claude/orchestration/` (AD-11). It is invoked **by path** from this repo and targets a repository via an explicit `--repo <absolute-path>` argument — the target is validated as a git repo, resolved once at launch, and checkpointed into run state. The `claude` subprocess runs with cwd = the target repo; artifacts land in the target's own `.claude-context/`. Skills reach the target via the user-level install above — the target repo needs nothing deployed into it.

Headless runs need only a minimal environment: `HOME`, `PATH`, `USER`, `SHELL`, `TERM`, `LANG`. Note that `ANTHROPIC_API_KEY` in the environment silently switches billing from a claude.ai subscription to the API account — the safe-env function strips it deliberately. If `claude` on your machine is a shell function (e.g. an nvm wrapper), subprocesses must call the real binary (`type -a claude` to find it).

## Process log

| Date | Process established | Where documented |
|---|---|---|
| 2026-08-20 | User-level symlink deployment + headless verification | This file |
| 2026-08-20 | Skill-bundled template convention | This file · `.claude-context/README.md` |
| 2026-08-20 | Orchestration location & `--repo` targeting | AD-11 in `architecture-decisions.md` |
| 2026-09-24 | Feature development runs on entrypoint skills (`/branch` → `/start-ticket` → Gate 1 → `/implement` → `/review-against-spec` → `/quality-review` → Gate 2) | `workflows/feature-development.md` |
