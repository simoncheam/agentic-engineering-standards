---
name: review-against-spec
description: Review the implemented change against the approved plan — did we build what we said? Report only; never fixes. Entrypoint skill; invoke explicitly after /implement. Never auto-triggers.
disable-model-invocation: true
argument-hint: "<path to artifact trail>"
---

# /review-against-spec — did we build what we said?

Stage 3, first half. This review compares the implementation to the **approved plan** — not to taste, not to general quality (that's `/quality-review`). It reports; it never fixes. Fixes route back through `/implement`.

## 1. Load both sides

- The spec side: `03-plan.md` (proposed change, out-of-scope list, verification plan).
- The implementation side: `04-implementation.diff` and the actual working tree — trust the tree over the artifact if they differ, and flag the mismatch.

**Fresh eyes principle:** this review should not share context with the implementation. Run it in a fresh session, or delegate to the reviewer agent once it exists. A reviewer that watched the implementation inherits its blind spots.

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

- the per-item table (planned elements → verdicts; unplanned changes → flagged)
- scope violations, if any — these are automatic failures
- overall verdict: **pass** | **fail** (any missing item, unexplained unplanned change, or scope violation)

## 5. Stop

Report the verdict. Next step is `/quality-review`; both results are reviewed together at **Gate 2**. On fail, the human decides: route back to `/implement`, or back to Gate 1 if the plan itself was the problem.

## Exit criteria

- [ ] Every plan element classified; every diff change accounted for
- [ ] Scope violations surfaced, not rationalized
- [ ] Verdict recorded in `05-spec-review.md`
- [ ] No fixes made — report only
