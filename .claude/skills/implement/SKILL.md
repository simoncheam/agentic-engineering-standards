---
name: implement
description: Execute an approved implementation plan against the target repo. Entrypoint skill; invoke explicitly after Gate 1 approval. Never auto-triggers.
disable-model-invocation: true
argument-hint: "<path to ticket trail (containing the approved 02-implementation-plan.md)>"
---

# /implement — approved plan → implementation

Stage 2. Input is a plan the human approved at Gate 1; being invoked **is** the approval signal, but verify the artifacts anyway.

## 1. Preflight

- The trail contains a complete `02-implementation-plan.md` (every template section filled). Missing or skeletal → stop; there is nothing approved to implement.
- On a work branch, not the default branch.
- Read the plan **and** `01-context-analysis.md` — the evidence behind the plan is context, not decoration.

## 2. Execute the plan — and only the plan

- Implement the **proposed change** as written: the smallest change that fixes the cause.
- The plan's **Files** lists and **out-of-scope list are binding.** Touch only the files it names to modify or create; adjacent cleanups, tempting refactors, unrelated fixes: note them for the review report, do not do them. A change that needs a file the plan doesn't list is a plan gap — step 3.
- Match the surrounding code — idiom, naming, comment density, project conventions per `CLAUDE.md`.

## 3. If reality contradicts the plan — stop

When implementation reveals the plan is wrong (the evidence was misread, the approach doesn't work, the real cause is elsewhere): **stop and route back to Gate 1** with what was learned. Do not improvise a different fix under an approved plan — an approval covers what was approved, nothing else.

## 4. Harness green

- Hooks pass on every edit (format / lint / typecheck).
- Run the project's tests if it has them. A change that breaks existing tests is not done — fix the change or stop and report, per step 3.

## 5. Record and commit locally

- Capture the change: `git diff <source>...HEAD` plus uncommitted work → `03-implementation.diff` in the trail, with brief notes (what changed, anything surprising).
- Commit on the work branch with a conventional message. **Do not push** — nothing leaves the machine before Gate 2.

## 6. Stop

Report: what was implemented, harness/test status, and the trail location. Next step is `/review-against-spec`.

## Exit criteria

- [ ] Plan executed as approved — no scope creep, or a clean stop-and-route-back
- [ ] Harness green; existing tests pass
- [ ] `03-implementation.diff` captured with notes
- [ ] Committed locally on the work branch; nothing pushed
