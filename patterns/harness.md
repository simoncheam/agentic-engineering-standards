# Pattern: The Harness

A programmatic verification layer that sits **outside the agent** and checks its output. No LLM tokens in the check itself — exit code 0 or 1. The philosophy: **the agent cannot self-certify.**

## The layers

| Layer | When it runs | What it catches |
|---|---|---|
| **Hooks** (format / lint / typecheck) | on every file edit | mechanical drift, immediately |
| **Validation gates** | between workflow stages | a stage's output failing its exit criteria before the next stage consumes it |
| **Test execution** | in the pipeline, not on request | regressions the change introduced |
| **Runtime verification** | before "done" | whether the app actually works after the change — the layer most setups are missing |

## Principles

- **Deterministic checks are the cheapest reliability.** They catch mechanical problems so review gates can spend human attention on judgment.
- **Auto-fix loops belong inside the harness.** A lint failure that can be fixed mechanically should be fixed mechanically, then re-checked — the agent shouldn't burn judgment tokens on formatting.
- **The common gaps are runtime verification and test execution in the pipeline.** Hooks and lint gates are table stakes; whether the app runs and behaves is the check that actually corresponds to "done." Focus energy on closing those gaps rather than adopting frameworks that add vocabulary without adding capability.
- **Every deterministic check added to the pipeline is budget well spent** — more scouts, more reviewers, a verifier re-running claims, end-to-end checks. Closing loops is where additional capacity goes (AD-6, AD-7).
