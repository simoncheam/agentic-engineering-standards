# .claude-context/ — Artifact Store

Process **outputs** live here; process **definitions** live in `.claude/` (AD-10). Every workflow stage reads its input from and writes its artifact to this directory, so agents and humans always know where work products are.

## Structure

```
bugs/<id>/       # one directory per bug — the full artifact trail
                 #   01-issue.md … 07-verification.md (see workflows/bug-resolution.md)
                 #   fix-plans/spec-<N>.md, quality-<N>.md — written by a review on fail
specs/           # feature specs and their plans (feature-development workflow)
templates/       # human-facing artifact shapes (bug report, PR); templates a
                 #   skill consumes travel bundled inside that skill's directory
local/           # personal scratch — gitignored, never committed
```

## Conventions

- **Artifacts live at the root the agent runs from.** Deployed alongside `.claude/`, whichever mode is used.
- **One bug, one directory, numbered artifacts.** The trail is the record; later stages consume earlier files by name.
- **Start from a template.** Templates encode each artifact's required sections — a stage that receives a malformed artifact stops and asks rather than guessing.
- **One verdict line per review artifact.** The last line of `05`, `06` and `07` is exactly `Verdict: <verdict>` — `pass` or `fail`, and `06` alone may say `pass-with-findings` — so gates read it with `tail -n1`, not by parsing prose. `05` and `06` also carry `Attempt: N` in their header: the count of that review's fix plans in `fix-plans/`, plus 1.
- **Only what's necessary.** Add subdirectories when a workflow actually produces that artifact class, not before (AD-8).
