# Skills

The single asset class of this agentic layer (see AD-2). Two kinds, one directory:

- **Workflow-stage skills** — user-invoked by name (`/start-ticket`, `/implement`). Each encodes one stage with a clear entry and exit. If a skill tries to do the whole lifecycle, it's hiding the gates.
- **Standards skills** — auto-activating via trigger description. Each enforces one documented pattern while work happens.

## Planned roster (populate from practice, not speculation)

### Workflow stages (user-invoked)

| Skill | Stage | Status |
|---|---|---|
| [`branch`](branch/SKILL.md) | stage 0 — clean, synced work branch off the source branch, before any work | ✅ v0.1 |
| [`start-ticket`](start-ticket/SKILL.md) | intake → context → plan, ends at Gate 1 (absorbs the earlier `bug`/`plan` split) | ✅ v0.1 |
| [`implement`](implement/SKILL.md) | approved plan → implementation, committed locally | ✅ v0.1 |
| [`review-against-spec`](review-against-spec/SKILL.md) | implementation vs. the approved plan — report only | ✅ v0.1 |
| [`quality-review`](quality-review/SKILL.md) | anti-patterns & best practices — auto-fix + report, ends at Gate 2 | ✅ v0.1 |
| [`build-from-spec`](build-from-spec/SKILL.md) | review `fail` → the fix plan it wrote, executed within its file list, committed locally | ✅ v0.1 |
| `verify` | change → demonstrated fix (runtime, not just types) | 🚧 planned |
| `deploy-config` | sync this layer to `~/.claude/` or a target repo, with selective flags | 🚧 planned |

Human gates: **Gate 1** — the plan is approved before `/implement` runs. **Gate 2** — spec-review + quality-review results are reviewed together before anything ships.

### Standards (auto-activating)

| Skill | Enforces | Status |
|---|---|---|
| `debugging` | reproduce → isolate → hypothesize → verify discipline | 🚧 planned |
| `verifying-completion` | verification as a step, not an assumption | 🚧 planned |
| `clarifying-requirements` | scope agreed before implementation | 🚧 planned |
| `handling-errors` | defensive patterns at async/API boundaries | 🚧 planned |
| `validating-code-cleanup` | no dead code, debug artifacts, or drive-by changes | 🚧 planned |
| `writing-plans` | plans that a gate can actually evaluate | 🚧 planned |

## Consumption model (AD-9)

Three paths, one asset class:

- **Entrypoint skills** (the workflow-stage table above) — invoked explicitly by a human (`/start-ticket`) or by orchestration (`claude -p "/start-ticket <ref>"`). Frontmatter: `disable-model-invocation: true` + `argument-hint`. **Never allowed to auto-trigger.**
- **Standards skills** (the standards table above) — auto-activate via trigger description.
- **Agent-carried skills** — referenced in an agent's frontmatter; the agent brings the capability wherever it runs.

## Authoring rules

1. One skill = one capability. Composition happens by stacking skills on agents (AD-3), not by growing a skill.
2. The trigger description is the contract: specific enough to activate reliably, honest enough not to over-trigger.
3. Every skill maps to a documented workflow stage or pattern in this repo. A skill with no backing doc is a prompt, not a standard.
4. Stack-specific conventions do not live here — they belong in each project's `CLAUDE.md`. This layer stays general.
