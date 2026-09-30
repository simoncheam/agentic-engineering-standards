---
name: start-ticket
description: Start work on a ticket — fetch the GitHub issue, gather grounded context, and produce a plan for approval. Entrypoint skill; invoke explicitly. Never auto-triggers.
disable-model-invocation: true
argument-hint: "<github issue ref (#12 | URL) | path to local ticket file>"
model: opus
---

# /start-ticket — intake → context → plan

Stage 1 of the ticket workflow. This skill ends at **Gate 1: a plan awaiting human approval.** It never implements.

## 0. Preflight — on a work branch?

If the current branch is the repo's default branch, **stop** and ask the human to run `/branch` first. Work never starts on the default branch.

## 1. Resolve the ticket

- **GitHub issue ref** (`#12`, `owner/repo#12`, or URL): `gh issue view <ref> --json number,title,body,labels,comments,url`.
- **Local file path**: read it (typically written from `.claude-context/templates/bug-report-template.md`).
- **Intake contract:** the ticket must state expected vs. actual behavior (bug) or the desired outcome with acceptance criteria (feature). If it doesn't, stop and ask — do not guess the requirement.

## 2. Create the trail

- `<ticket-id>` = `<issue-number>-<slug>` (the suffix `/branch` used), or `<slug>` alone with no issue.
- Create `.claude-context/tickets/<ticket-id>/` and copy `00-ticket-details.md`, `01-context-analysis.md` and `02-implementation-plan.md` into it from `${CLAUDE_SKILL_DIR}/ticket-template/`. Copy only those three files — not the README — and create no subfolders; each is created by the stage that first writes into it (layout: `${CLAUDE_SKILL_DIR}/ticket-template/README.md`).
- Fill `00-ticket-details.md`: frontmatter (`ticket`, `source`, `type: bug | feature`, `fetched`), the issue body verbatim, the acceptance criteria as `AC-n` — extracted, never invented — labels, condensed comments (quote anything that changes scope), links. This file is the only source of acceptance criteria; nothing downstream restates them.

## 3. Classify and apply the right discipline

- **Bug:** reproduce before diagnosing. Run the app or test and confirm the failure exists as described. No reproduction, no investigation — if it can't be reproduced, stop and report exactly what was tried. Record the steps and observed failure under `## Reproduction` in `01-context-analysis.md`.
- **Feature:** restate the scope in your own words and list what is explicitly out of scope. Ambiguity in acceptance criteria gets asked about now, not discovered during implementation.

## 4. Gather grounded context (scout reconnaissance)

Per `patterns/scout-recon.md`: dispatch parallel scouts with distinct search directions — affected surfaces / existing conventions / tests & validation. Each scout's raw report goes to `scout/<direction>.md` in the trail (this creates the folder). Consolidate into `01-context-analysis.md` as structured references (`path:start-end`), not prose — findings by direction, integration points, risks, open questions. A question that blocks the plan is asked now.

## 5. Write the plan

Fill `02-implementation-plan.md`. Every section: problem, evidence (file refs from step 4), proposed change, files to modify / create, AC coverage (every `AC-n` from `00`), out of scope, verification plan, risks.

## 6. Stop at Gate 1

Present the plan summary and the trail location. **Do not implement.** The human approves, requests changes, or rejects; an approved plan is the input to `/implement`.

## Exit criteria

- [ ] Ticket resolved and saved (`00-ticket-details.md`), criteria as `AC-n`
- [ ] Bug reproduced with evidence, or feature scope confirmed (`01-context-analysis.md`)
- [ ] Plan complete per template, every `AC-n` covered (`02-implementation-plan.md`)
- [ ] Stopped — no implementation performed
