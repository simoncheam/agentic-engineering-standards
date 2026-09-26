# .claude-context/ — Artifact Store

Process **outputs** live here; process **definitions** live in `.claude/` (AD-10). Every workflow stage reads its input from and writes its artifact to this directory, so agents and humans always know where work products are.

## Structure

```
bugs/<id>/       # one directory per bug — the full artifact trail
                 #   01-issue.md … 07-verification.md (see workflows/bug-resolution.md)
specs/           # feature specs and their plans (feature-development workflow)
templates/       # human-facing artifact shapes (bug report, PR); templates a
                 #   skill consumes travel bundled inside that skill's directory
local/           # personal scratch — gitignored, never committed
```

## Conventions

- **Artifacts live at the root the agent runs from.** Deployed alongside `.claude/`, whichever mode is used.
- **One bug, one directory, numbered artifacts.** The trail is the record; later stages consume earlier files by name.
- **Start from a template.** Templates encode each artifact's required sections — a stage that receives a malformed artifact stops and asks rather than guessing.
- **Only what's necessary.** Add subdirectories when a workflow actually produces that artifact class, not before (AD-8).
