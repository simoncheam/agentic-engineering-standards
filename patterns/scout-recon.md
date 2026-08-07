# Pattern: Scout Reconnaissance

The weakest link in spec-driven work is usually not validation — it's reconnaissance. A planner working from thin or narrative context produces loosely-grounded plans, and every downstream gate ends up validating against a vague target. Fix the input, not the gate.

## The pattern

Replace a single explorer with **parallel scouts, each given one distinct search direction**:

- **Scout A — affected surfaces:** components, routes, APIs the change touches
- **Scout B — existing conventions:** patterns, shared utilities, prior art the change must match
- **Scout C — tests & validation:** test files, validation patterns, CI configuration

Outputs consolidate into **one structured context file with precise file references** (`path` with `offset:limit` line ranges) — not prose. The planner receives grounded locations instead of narrative, eliminating duplicate searches during planning and specs that hallucinate file paths.

## Scaling rules

- **Scout count scales with codebase complexity.** If 3 scouts find everything the planner needs, use 3. Add more only when they demonstrably miss things; then specialize scouts around critical domains of the codebase.
- **Model choice:** capable-but-cheap models for scouting is the default; the cheapest tier needs more directive prompts to hold up on reconnaissance. Reserve expensive calls for planning and judgment.
- **The consolidation step depends on scout output quality.** Scouts must emit a substantial, structured chunk; if scout output is thin, the planner has nothing to consolidate.

## Why it matters

The value of scouts increases with codebase size. Small codebases: a planner can find what it needs alone. At scale, scouts are the difference between grounded specs and specs that hallucinate file locations.
