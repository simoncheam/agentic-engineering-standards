---
name: review-against-spec
description: Review the implemented change against the approved plan — did we build what we said? Report only; never fixes. Entrypoint skill; invoke explicitly after /implement. Never auto-triggers.
disable-model-invocation: true
argument-hint: "<path to artifact trail>"
context: fork
agent: reviewer
background: false
---

# /review-against-spec — did we build what we said?

Stage 3, first half. This review compares the implementation to the **approved plan** — not to taste, not to general quality (that's `/quality-review`). It reports; it never fixes. A fail it can pin on the implementation becomes a fix plan for `/build-from-spec`.

## 1. Load both sides

- The spec side: `03-plan.md` (proposed change, out-of-scope list, verification plan).
- The implementation side: `04-implementation.diff` and the actual working tree — trust the tree over the artifact if they differ, and flag the mismatch.

**Fresh eyes, by construction:** this skill runs inside the [`reviewer`](../../agents/reviewer.md) agent (`context: fork`) — no conversation history, no Edit tool. A reviewer that watched the implementation inherits its blind spots. Everything you need is in the trail passed as the argument and in git.

## 2. Compare systematically

Walk the plan item by item and classify each element of the proposed change:

| Verdict | Meaning |
|---|---|
| **implemented** | present in the change, as planned |
| **partial** | present but incomplete or altered — describe the delta |
| **missing** | planned but not implemented |

Then walk the diff the other direction and flag:

- **unplanned** — changes present in the diff that the plan never proposed
- **scope violations** — anything touching the plan's explicit out-of-scope list

## 3. Check the verification plan still holds

The plan named how the fix would be demonstrated. Confirm that verification is still applicable to what was actually built; if the implementation drifted, the verification plan may test the wrong thing.

## 4. Write the report

→ `05-spec-review.md` in the trail:

- header line `Attempt: N` — `N` = the number of `fix-plans/spec-*.md` already in the trail, plus 1
- the per-item table (planned elements → verdicts; unplanned changes → flagged)
- scope violations, if any — these are automatic failures
- **last line**, exactly: `Verdict: pass` or `Verdict: fail` (fail = any missing item, unexplained unplanned change, or scope violation)

## 5. On fail — write the fix plan

- **The implementation missed the plan** (missing, partial, unplanned, scope violation): write `fix-plans/spec-<N>.md` in the trail from `${CLAUDE_SKILL_DIR}/../build-from-spec/fix-plan-template.md`, every section filled. Each task names its file under **Files to Modify** / **Files to Create**; an unplanned change is fixed by reverting it.
- **The plan itself was wrong:** write no fix plan. Say so in the report — that fail routes back to Gate 1.

## 6. Stop

Report the verdict and the paths written. On pass, next step is `/quality-review`. On fail with a fix plan: `Next: /build-from-spec <fix plan>, then re-run /review-against-spec`. Everything is reviewed together at **Gate 2**.

## Exit criteria

- [ ] Every plan element classified; every diff change accounted for
- [ ] Scope violations surfaced, not rationalized
- [ ] `05-spec-review.md` carries `Attempt: N` and ends with the `Verdict:` line
- [ ] On an implementation fail, a complete fix plan in `fix-plans/`
- [ ] No fixes made — only the trail changed
