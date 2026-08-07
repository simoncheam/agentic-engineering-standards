# Agents

Subagents are the *implementations* that consume skill *capabilities* (AD-3). An agent's frontmatter names the skills it carries; scaling happens by running agents in parallel; cross-domain agents are made by stacking skills, not by writing new rules.

## Planned roster

| Agent | Role | Consumes | Status |
|---|---|---|---|
| `scout` | reconnaissance — one search direction, structured output with file refs (`path:offset-limit`) | — | 🚧 planned |
| `planner` | consolidates scout output into a grounded, gate-ready plan | `writing-plans` | 🚧 planned |
| `reviewer` | reviews an implementation against its approved spec | `validating-code-cleanup` | 🚧 planned |
| `verifier` | re-runs claims: exercises the affected flow, confirms the fix against the reproduction | `verifying-completion` | 🚧 planned |

## Patterns

- **Scouts run in parallel with distinct search directions** (affected surfaces / existing conventions / tests & validation). See `patterns/scout-recon.md`.
- **Cheap models for reconnaissance, expensive models for planning and judgment.** Token economics is part of the design, not an afterthought.
- **The verifier is not the reviewer.** Review checks the change against the spec; verification checks the running behavior against the original problem.
