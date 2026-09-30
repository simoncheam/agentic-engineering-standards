# .claude-context/ — Artifact Store

Process **outputs** live here; process **definitions** live in `.claude/` (AD-10). Every workflow stage reads its input from and writes its artifact to this directory, so agents and humans always know where work products are.

## Structure

```
tickets/<id>/    # one directory per ticket, bug or feature — the full artifact trail
                 #   00-ticket-details.md … 06-verification.md, plus on-demand subfolders
                 #   (layout: .claude/skills/start-ticket/ticket-template/README.md)
templates/       # human-facing artifact shapes (bug report, PR); templates a
                 #   skill consumes travel bundled inside that skill's directory
local/           # personal scratch — gitignored, never committed
```

## Conventions

- **Artifacts live at the root the agent runs from.** Deployed alongside `.claude/`, whichever mode is used.
- **One ticket, one directory, numbered artifacts.** The trail is the record; later stages consume earlier files by name. Bug or feature is the `type` field in `00-ticket-details.md`, not a directory. Subfolders appear when a stage first writes into them, never before.
- **Start from a template.** Templates encode each artifact's required sections — a stage that receives a malformed artifact stops and asks rather than guessing.
- **One verdict line per review artifact.** The last line of `04`, `05` and `06` is exactly `Verdict: <verdict>` — `pass` or `fail`, and `05-quality-review.md` alone may say `pass-with-findings` — so gates read it with `tail -n1`, not by parsing prose. `04` and `05` also carry `Attempt: N` in their header: the count of that review's fix plans in `fix-plans/`, plus 1.
- **Only what's necessary.** Add subdirectories when a workflow actually produces that artifact class, not before (AD-8).
