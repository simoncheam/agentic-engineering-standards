---
name: quality-review
description: Final quality gate for an implemented change — auto-fixes mechanical findings, reports judgment findings. Entrypoint skill; invoke explicitly after /review-against-spec. Never auto-triggers.
disable-model-invocation: true
argument-hint: "[path to artifact trail (defaults to the current change)]"
---

# /quality-review — is it built well?

Runs after `/review-against-spec`, and asks a different question: spec review asks *"did we build what we said?"* — this asks *"is it built to a senior engineer's standard?"* It reviews the change, not the repo.

## 1. Scope the review

Diff the implemented change (working tree, or the trail's `04-implementation.diff`). Only changed code and its immediate blast radius are in scope. Pre-existing issues outside the change: note them in the report as follow-ups — do not fix them.

## 2. Two classes of findings

**Mechanical — fix, then re-verify:**
- dead code, unused imports, commented-out blocks
- debug artifacts (console.log, debugger statements, temp files)
- TODO comments without a reference
- formatting, lint, or type errors
- obvious duplication of an existing utility

Auto-fix loop: fix → re-run the harness (format / lint / typecheck) → repeat until clean. Never write a finding into the report that a deterministic fix can clear.

**Judgment — report, never fix:**
- anti-patterns per the project's conventions (`CLAUDE.md`)
- error-handling gaps at async and API boundaries
- naming or altitude problems, unnecessary complexity
- duplication whose resolution requires a design decision
- missing or weak test coverage for the change

## 3. Write the report

→ `06-quality-review.md` in the trail:

- fixes applied (mechanical), each with a one-line what and why
- judgment findings, most severe first: `file:line`, the issue, a concrete suggestion
- verdict: **pass** | **pass with findings** | **fail** (a finding requires re-implementation)

## 4. Stop at Gate 2

Present the verdict alongside the spec-review result. **Do not ship, commit, or open a PR.** The human decides what proceeds.

## Exit criteria

- [ ] Mechanical findings fixed and harness re-verified clean
- [ ] Judgment findings reported with locations and suggestions — none silently fixed
- [ ] Verdict recorded in `06-quality-review.md`
- [ ] Stopped — no commit or PR
