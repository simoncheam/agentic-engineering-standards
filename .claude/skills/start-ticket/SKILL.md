---
name: start-ticket
description: Start work on a ticket — pull details, gather grounded context, and produce a plan for approval. Entrypoint skill; invoke explicitly. Never auto-triggers.
disable-model-invocation: true
argument-hint: "<github issue ref (#12 | URL) | path to local ticket file>"
model: opus
---

# /start-ticket — intake → context → plan

Stage 1 of the ticket workflow. This skill ends at **Gate 1: a plan awaiting human approval.** It never implements.

## 0. Preflight — on a work branch?

If the current branch is the repo's default branch, **stop** and ask the human to run `/branch` first. Work never starts on the default branch.

## 1. Resolve the ticket

- **GitHub issue ref** (`#12`, `owner/repo#12`, or URL): pull with `gh issue view <ref> --json title,body,labels,comments`.
- **Local file path**: read it (typically written from `.claude-context/templates/bug-report-template.md`).
- **Intake contract:** the ticket must state expected vs. actual behavior (bug) or the desired outcome with acceptance criteria (feature). If it doesn't, stop and ask — do not guess the requirement.

## 2. Create the artifact trail

Create `.claude-context/bugs/<id>/` (bug) or `.claude-context/specs/<slug>/` (feature).
Save the resolved ticket as `01-issue.md`.

## 3. Classify and apply the right discipline

- **Bug:** reproduce before diagnosing. Run the app or test and confirm the failure exists as described. No reproduction, no investigation — if it can't be reproduced, stop and report exactly what was tried. Capture evidence in `02-investigation.md`.
- **Feature:** restate the scope in your own words and list what is explicitly out of scope. Ambiguity in acceptance criteria gets asked about now, not discovered during implementation.

## 4. Gather grounded context (scout reconnaissance)

Per `patterns/scout-recon.md`: dispatch parallel scouts with distinct search directions — affected surfaces / existing conventions / tests & validation. Consolidate into `02-investigation.md` as structured references (`path:start-end`), not prose.

## 5. Write the plan

From the `plan-template.md` bundled in this skill's directory → `03-plan.md` in the trail. Every section filled: problem, evidence (file refs from step 4), proposed change, out of scope, verification plan, risks.

## 6. Stop at Gate 1

Present the plan summary and the trail location. **Do not implement.** The human approves, requests changes, or rejects; an approved plan is the input to `/implement`.

## Exit criteria

- [ ] Ticket resolved and saved (`01-issue.md`)
- [ ] Bug reproduced with evidence, or feature scope confirmed (`02-investigation.md`)
- [ ] Plan complete per template (`03-plan.md`)
- [ ] Stopped — no implementation performed
