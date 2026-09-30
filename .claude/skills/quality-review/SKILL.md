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

**Judgment — reported by the `reviewer` agent (step 3), never fixed:**
- anti-patterns per the project's conventions (`CLAUDE.md`)
- error-handling gaps at async and API boundaries
- naming or altitude problems, unnecessary complexity
- duplication whose resolution requires a design decision
- missing or weak test coverage for the change

## 3. Dispatch the judgment pass to `reviewer`

Mechanical fixes run here, where the harness and project tooling live. Judgment runs in the [`reviewer`](../../agents/reviewer.md) agent — fresh context, no Edit tool — on the **post-fix** diff. Dispatch it (Agent tool, `subagent_type: reviewer`) with a task that stands on its own:

- the trail path, and the source branch to diff against
- the question — *is it built to a senior engineer's standard?* — and the judgment list above
- the mechanical fixes you applied, each with a one-line what and why
- the contract below, with `${CLAUDE_SKILL_DIR}/../build-from-spec/fix-plan-template.md` as the fix-plan template

The reviewer writes `06-quality-review.md` in the trail:

- header line `Attempt: N` — `N` = the number of `fix-plans/quality-*.md` already in the trail, plus 1
- fixes applied (mechanical), as you reported them
- judgment findings, most severe first: `file:line`, the issue, a concrete suggestion
- **last line**, exactly: `Verdict: pass`, `Verdict: pass-with-findings`, or `Verdict: fail` (a finding requires re-implementation)
- on `fail`: `fix-plans/quality-<N>.md` from the template, every section filled, each task naming its file

Read what it wrote before you report. If the artifact is missing or its last line isn't a `Verdict:` line, the review didn't happen — say so.

## 4. Stop at Gate 2

Present the verdict alongside the spec-review result. On fail: `Next: /build-from-spec <fix plan>, then re-run /quality-review`. **Do not ship, commit, or open a PR.** The human decides what proceeds.

## Exit criteria

- [ ] Mechanical findings fixed and harness re-verified clean
- [ ] Judgment pass run by `reviewer` on the post-fix diff — findings with locations and suggestions, none silently fixed
- [ ] `06-quality-review.md` carries `Attempt: N` and ends with the `Verdict:` line; on fail, a complete fix plan in `fix-plans/`
- [ ] Stopped — no commit or PR
