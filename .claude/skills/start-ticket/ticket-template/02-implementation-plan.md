# Plan: <short title>

## Problem

<one paragraph — what is broken or missing, in terms of behavior>

## Evidence

<grounded file references from `01-context-analysis.md` — `path:line-range`, not prose>

-

## Proposed change

<the smallest change that fixes the cause — what changes, where, and why this approach>

## Files

<the file boundary `/implement` works within and `/review-against-spec` checks the diff against — a file in the diff that is on neither list is an unplanned change>

Files to modify:

- `path/to/file` — <what changes>

Files to create:

- `path/to/new-file` — <purpose> (or "none")

## AC coverage

<every `AC-n` from `00-ticket-details.md`; a criterion with no row is a plan gap>

| AC | Planned change | Verified by |
|---|---|---|
| AC-1 | | |

## Out of scope

<explicitly named — what this change will NOT touch, including tempting adjacent cleanups>

-

## Verification plan

<how the fix will be demonstrated against the original problem — the runtime check, not just tests>

## Risks

<what could break, and which harness layer would catch it>

---

*This is what the review gate evaluates. A plan a gate can't evaluate — no evidence, no out-of-scope, no verification plan — is not a plan.*
