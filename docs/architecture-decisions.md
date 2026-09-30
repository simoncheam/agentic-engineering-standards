# Architecture Decisions

Distilled from practice and from IndyDevDan's agentic engineering course. Each decision records what was chosen, what was rejected, and why — so the structure doesn't drift back toward rejected patterns.

## AD-1: Monolithic `.claude/`, never plugins

**Decision:** All skills, agents, and hooks live in one `.claude/` directory. No plugin split, no marketplace fragmentation.

**Why:** Commands, skills, and agents reference each other through relative paths and shared discovery. Splitting them into plugins breaks path resolution, cross-agent discovery, and single-deploy workflows — and there is no dependency system between plugins.

**The properties to preserve:** *visibility* (agents must be able to see everything) and *minimum distance to an update*.

## AD-2: Skills first; `commands/` kept for prompt-only entrypoints

**Decision:** Skills are the primary asset class. Workflow stages are user-invoked skills (`/branch`, `/start-ticket`, `/implement`, `/review-against-spec`, `/quality-review`, `/verify`); standards are auto-activating skills. `.claude/commands/` is retained for entrypoints that are a prompt and nothing else — currently `/prime`. New work defaults to a skill.

**Why:** A skill is a superset of a command: invocable by `/name`, auto-activating by trigger description, and able to bundle supporting files. Claude Code's own guidance is that "custom commands have been merged into skills" and both forms create the same `/name`, so a command file stays valid and remains the lighter shape when there is nothing to bundle. The cost is honest: two asset classes mean two authoring conventions and a slightly larger sync surface, which is why anything with a template, script, or agent binding is a skill.

**Superseded:** the original AD-2 forbade a commands directory outright. Retained as a documented exception rather than a drift.

## AD-3: Skills = capabilities, agents = implementations

**Decision:** Skills define *what* (a capability, a convention, a discipline). Subagents define *who* (an implementation that consumes skills via frontmatter and scales via parallelism).

**Why:** This split composes. A convention skill can be given to any agent that needs it; an agent needing two domains just stacks both skills. No rules-file conflicts, no glob-matching edge cases — just composable capabilities. (`rules/` directories are deliberately not used.)

## AD-4: Two levels, not four

**Decision:** One canonical source (this repo) + consumers. No corporate/division/team hierarchy.

**Why:** Multi-level hierarchies with dependency enforcement and promotion processes are infrastructure ahead of demand. The risk is that the structure becomes the project — maintaining scaffolding instead of shipping workflows. Expand only when real demand proves it.

## AD-5: Deployment — user-level first, per-repo second, workspace third

**Decision:** Three supported modes, in priority order:

1. **`~/.claude/` (user-level)** — the daily driver. Skills follow you into every repo and every editor window (VS Code, Cursor, terminal) with zero per-repo deploys. Maximum visibility, minimum distance to update.
2. **Per-repo deploy** (`/deploy-config <target> [--minimal|--frontend-only]`) — for repos that must be self-contained: public projects, CI, anything others clone. Selective loading happens via flags, not fragmentation.
3. **Workspace root** — `.claude/` at a workspace root with repos underneath, agent launched at the root. Supported for monorepo-style workspaces, but not primary: an individual repo opened in its own window does not inherit a workspace-root `.claude/`.

**Why:** Editors open repos individually; only user-level config follows you everywhere automatically. Duplicated per-repo copies drift — so the canonical version lives here, and deploys are one-way pushes from this source.

## AD-6: Partition first, chain second

**Decision:** Each SDLC stage becomes a rock-solid standalone skill before any chaining. Chains grow incrementally — two links, then three — with deterministic validation between every link. Orchestration (ADW-style programmatic pipelines) is phase 2, and starts with bug resolution because it is the most bounded problem class.

**Why:** One concrete pipeline for one problem class beats a generic framework. Three simple chained stages beat one clever orchestrator. Chaining unproven stages multiplies their failure rates.

## AD-7: The harness — deterministic verification outside the agent

**Decision:** Verification layers are programmatic and external: hooks running formatters/linters/type-checkers on every edit, validation gates between workflow stages, runtime verification that the app actually works after changes. Exit code 0 or 1 — no LLM tokens in the check itself.

**Why:** The agent cannot self-certify. External deterministic checks are what make agent output trustworthy at scale, and they free review gates to spend human attention on judgment rather than mechanics.

## AD-8: Aggressive scope discipline

**Decision:** This repo contains only the agentic layer. Anything that isn't a workflow, pattern, skill, agent, hook, orchestration script, or worked example gets deleted.

**Why:** "Aggressively reduce and delete everything that isn't the application layer or your agentic layer. Everything else is noise."

## AD-9: Skill consumption model

**Decision:** One asset class, three consumption paths — differentiated by frontmatter and consumer, not by directory:

| Mode | What it is | How it's marked |
|---|---|---|
| **Entrypoint skills** | Workflow stages invoked explicitly — a human typing `/start-ticket`, or an orchestration script running `claude -p "/start-ticket <ref>"` | `disable-model-invocation: true`, `argument-hint` for inputs |
| **Standards skills** | Auto-activate via trigger description while any work happens | trigger-style `description`, no invocation args |
| **Agent-carried skills** | Capabilities a subagent carries via its definition (reviewer carries `validating-code-cleanup`, planner carries `writing-plans`) | referenced in the agent's frontmatter (AD-3) |

**The one hard rule: entrypoint skills must never auto-trigger.** A pipeline needs deterministic stage boundaries; if a stage's logic can fire spontaneously because a description matched mid-conversation, the partition dissolves.

**Why:** Invoking a skill by `/name` is identical to invoking a command by `/name` from the CLI's perspective, so programmatic orchestration (ADW-style Python chaining, phase 2) sits unchanged above entrypoint skills: `ADW → entrypoint skill → agents → standards skills`. Orchestration assumed *stable invocable names*, not a commands directory — skills provide them.

## AD-10: `.claude-context/` — the artifact store

**Decision:** Process *definitions* live in `.claude/` (the runnable layer). Process *outputs* live in `.claude-context/` (the artifact store): bug trails, specs, and the templates that shape them. `local/` inside it is gitignored personal scratch.

**Why:** Later stages consume earlier stages' artifacts (`/implement` reads the plan; review reads the implementation), so artifact locations must be stable and predictable for both agents and humans. Keeping outputs out of `.claude/` keeps the deployable layer clean, and keeping them out of the repo root keeps projects clean. Invariant: artifacts live at the root the agent runs from.

## AD-11: Orchestration — lives in `.claude/`, targets by explicit path

**Decision:** Programmatic orchestration (the phase-2 ADW layer, AD-6/AD-9) lives in `.claude/orchestration/` — inside the monolithic `.claude/` per AD-1, never at the repo root. The orchestrator is invoked by path from this repo and takes its target repository as an explicit `--repo` absolute path: validated as a git repository, resolved once at launch, and checkpointed into run state so later phases and `--resume` read it from state rather than a re-passed flag. Every run uses single-repo semantics — the `claude` subprocess runs with cwd = the target repo, and artifacts land in the target's own `.claude-context/` (AD-10). Workspace-mode targeting (scanning repos under an `apps/` directory, prompt directives steering an agent at a subdirectory) is deferred behind a `resolve_target_repo()` seam until real cross-repo demand exists.

**Why:** The reference architecture derives its execution root from the orchestrator's own file location, which forces copying the layer into every project it serves — the drift AD-5 exists to avoid. Taking the execution root as input decouples where the code lives from where it runs: one canonical orchestrator serves N repos with zero deploys, and skills reach the target via the user-level layer (AD-5 mode 1). Rejected alternatives: a root-level `orchestration/` directory (breaks AD-1's single-deploy visibility), cwd inference (fragile headless), and an environment variable (grows the environment surface the safe-env design shrinks).

## AD-13: Reviewers cannot edit; a review fail is executable

**Decision:** Review runs in the `reviewer` agent, whose tools are Read, Grep, Glob, Bash, and Write, with no Edit. `/review-against-spec` forks into it (`context: fork`). `/quality-review` keeps its mechanical auto-fix loop in the main context and then dispatches `reviewer` for the judgment pass on the post-fix diff. A `fail` has exactly one executable output: a fix plan in `<trail>/fix-plans/<kind>-<N>.md`, which `/build-from-spec` executes within its file list before the review re-runs. The artifacts make attempts countable (`Attempt: N`). The attempt cap is orchestrator policy (phase 2), not skill logic. (AD-12 is reserved for merge.)

**Why:** "Fresh eyes" written as an instruction is a hope. A forked context with no history and no Edit tool makes it structural, and `git status --porcelain -- . ':!.claude-context'` staying empty after every review run is the proof (AD-7). The fix plan closes the dead end where a `fail` routed "back to `/implement`", a skill that consumes only the Gate 1 plan. It also keeps AD-6's partition intact: `/implement` executes the approved plan, and `/build-from-spec` executes an approved fix plan. Rejected: a `quality-reviewer` agent with Edit to own the auto-fix loop. It would re-prompt a skill in a second context, and Edit on a reviewer turns "report only" from a guarantee back into an instruction. Also rejected: forking all of `/quality-review`. Its mechanical fixes need the project's harness, which lives in the main context.

## AD-14: One ticket trail

**Decision:** Every ticket, bug or feature, gets one trail at `.claude-context/tickets/<ticket-id>/`; the separate `bugs/` and `specs/` directories are gone. Bug or feature is the `type` field in `00-ticket-details.md`, not a directory. The trail's skeleton is bundled with the skill that creates it, at `.claude/skills/start-ticket/ticket-template/`, and its README is the one description of the layout. Only the numbered files are copied at creation; subfolders (`scout/`, `fix-plans/`, `code-reviews/`, `decisions/`, `errors/`, `docs/`, `design/`, `evidence/`) are created by the stage that first writes into them. A file gets a number only when a later stage reads it by name (`00` through `06`); everything else lives in a subfolder. `00-ticket-details.md` is the only source of acceptance criteria — later artifacts cite `AC-n`, never restate it. Amends AD-10's directory list; the store's other rules stand.

**Why:** Two trails meant two places to look and two sets of names to keep in sync, for a difference — bug or feature — that changes one stage's discipline, not the artifact chain. Bundling the template keeps it with its consumer (AD-10's convention) so it travels with the skill to every machine and repo. On-demand subfolders are AD-8 applied to the trail: an empty `design/` in a backend ticket is scaffolding, not information. The numbering rule keeps the gate chain legible — a numbered file is a promise that something reads it — which is why a summary file no skill reads has no number and no place. A single home for acceptance criteria stops the criteria drifting between the ticket, the analysis and the plan; the plan maps to them, the spec review grades against them.
