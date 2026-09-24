# Architecture Decisions

Distilled from practice and mentor guidance. Each decision records what was chosen, what was rejected, and why — so the structure doesn't drift back toward rejected patterns.

## AD-1: Monolithic `.claude/`, never plugins

**Decision:** All skills, agents, and hooks live in one `.claude/` directory. No plugin split, no marketplace fragmentation.

**Why:** Commands, skills, and agents reference each other through relative paths and shared discovery. Splitting them into plugins breaks path resolution, cross-agent discovery, and single-deploy workflows — and there is no dependency system between plugins. This was proven empirically: a plugin refactor of a large agentic layer broke the daily workflow chain and required a manual restore script, which itself proved the model couldn't stand alone.

**The properties to preserve:** *visibility* (agents must be able to see everything) and *minimum distance to an update*.

## AD-2: Skills only — no separate commands directory

**Decision:** One asset class. Workflow stages are user-invoked skills (`/bug`, `/plan`, `/implement`, `/verify`); standards are auto-activating skills. There is no `.claude/commands/`.

**Why:** A skill is a superset of a command: invocable by name, auto-activating by trigger description, with frontmatter controlling model, tools, and behavior. Maintaining two asset classes doubles authoring rules, deploy logic, and sync surface. The convention is converging here anyway — "over time everything will be a skill and the frontmatter will customize it."

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

**Why:** Later stages consume earlier stages' artifacts (`/plan` reads the investigation; review reads the plan), so artifact locations must be stable and predictable for both agents and humans. Keeping outputs out of `.claude/` keeps the deployable layer clean, and keeping them out of the repo root keeps projects clean. Invariant: artifacts live at the root the agent runs from.

## AD-11: Orchestration — lives in `.claude/`, targets by explicit path

**Decision:** Programmatic orchestration (the phase-2 ADW layer, AD-6/AD-9) lives in `.claude/orchestration/` — inside the monolithic `.claude/` per AD-1, never at the repo root. The orchestrator is invoked by path from this repo and takes its target repository as an explicit `--repo` absolute path: validated as a git repository, resolved once at launch, and checkpointed into run state so later phases and `--resume` read it from state rather than a re-passed flag. Every run uses single-repo semantics — the `claude` subprocess runs with cwd = the target repo, and artifacts land in the target's own `.claude-context/` (AD-10). Workspace-mode targeting (scanning repos under an `apps/` directory, prompt directives steering an agent at a subdirectory) is deferred behind a `resolve_target_repo()` seam until real cross-repo demand exists.

**Why:** The reference architecture derives its execution root from the orchestrator's own file location, which forces copying the layer into every project it serves — the drift AD-5 exists to avoid. Taking the execution root as input decouples where the code lives from where it runs: one canonical orchestrator serves N repos with zero deploys, and skills reach the target via the user-level layer (AD-5 mode 1). Rejected alternatives: a root-level `orchestration/` directory (breaks AD-1's single-deploy visibility), cwd inference (fragile headless), and an environment variable (grows the environment surface the safe-env design shrinks).
