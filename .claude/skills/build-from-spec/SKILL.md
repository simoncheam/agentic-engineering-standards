---
name: build-from-spec
description: Execute an approved fix plan with surgical precision — only the files it lists, then its validation commands. Entrypoint skill; invoke explicitly after a review writes a fix plan. Never auto-triggers.
disable-model-invocation: true
argument-hint: "<path to fix plan>"
---

# /build-from-spec — fix plan → fix

The executable half of a review `fail`. `/implement` builds the plan approved at Gate 1; this skill builds a **fix plan** a review wrote (`<trail>/fix-plans/spec-<N>.md` or `quality-<N>.md`, shaped by the `fix-plan-template.md` bundled in this skill's directory). Trust the fix plan. Execute it exactly — nothing more, nothing less.

## 1. Preflight

- The fix plan exists and every template section is present (`None` counts; a missing section does not). Otherwise stop: there is nothing executable.
- On a work branch, not the default branch.
- Read the review artifact the plan names in `Source:` — the findings are context for the tasks.

## 2. Execute the tasks — and only the tasks

- Follow **Step-by-Step Tasks** in order. Complete each before the next.
- **File boundary is binding:** modify only files under **Files to Modify**, create only files under **Files to Create**. A task that needs any other file means the plan is incomplete — stop and report it.
- **Out of Scope is binding.** Match the surrounding code — idiom, naming, comment density, project conventions per `CLAUDE.md`.

## 3. If the plan is unclear or contradicts the code — stop

Do not improvise or "fix" the fix plan. Report the step, what it says, and what the code shows. The human decides: correct the fix plan, or route back to Gate 1.

## 4. Validate

- Run every command under **Validation Commands**, then the project's tests if it has them. Hooks pass on every edit.
- A failing command is not done: fix it within the plan's files, or stop and report per step 3.

## 5. Record and commit locally

- Re-capture the change: `git diff <source>...HEAD` plus uncommitted work → `03-implementation.diff` in the trail, with a note naming the fix plan applied. The re-review reads it.
- Commit on the work branch with a conventional message. **Do not push.**

## 6. Stop

Report: tasks completed, files touched, validation results. Print the next step: `Next: /review-against-spec <trail>` for a `spec-*` plan, `/quality-review <trail>` for a `quality-*` plan. The re-review counts the attempt.

## Exit criteria

- [ ] Every task executed in order — or a clean stop naming the blocker
- [ ] Only listed files touched (`git diff --name-only` ⊆ Files to Modify ∪ Files to Create)
- [ ] Validation commands and existing tests pass
- [ ] `03-implementation.diff` re-captured; committed locally; nothing pushed
