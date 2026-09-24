# Feature Development Workflow

> **Status:** 🚧 Being documented from daily practice. Stages 0–3 run on v0.1 skills; verification and PR stages are planned.

## Work Instruction for Claude Code

How to take a feature ticket from intake to a reviewed, shippable change using this layer's **entrypoint skills**. Each stage is a standalone skill you invoke by name (`/start-ticket`, `/implement`, …). Skills never auto-trigger and never chain themselves — you run them in order and you control the pace.

---

## How It Works

Each skill reads the artifacts the previous stage left and writes its own into the ticket's **artifact trail** (`.claude-context/specs/<slug>/`). Planning feeds implementation; implementation feeds review. A skill that finds its input missing or malformed stops and asks rather than guessing.

There are two **human gates**:

- **Gate 1 — plan approval.** Nothing is implemented until you approve the plan.
- **Gate 2 — review.** The spec-review and quality-review results are read together before anything leaves your machine.

---

## The Workflow

```
  0. /branch               Clean, synced work branch
         |
  1. /start-ticket         Ticket → scope → context → plan
         |
     ── Gate 1 ──          Approve the plan? No → revise and re-plan
         |
  2. /implement            Builds the approved plan, commits locally
         |
  3. /review-against-spec  Did we build what we said?   (report only)
         |
  4. /quality-review       Is it built well?            (auto-fix + report)
         |
     ── Gate 2 ──          Both pass? No → back to /implement, or to Gate 1
         |
  5. Verify                Exercise the feature at runtime   (/verify — planned)
         |
  6. PR                    Package the change with its trail (no skill yet)
```

---

## Step-by-Step

### Step 0: Branch

```
/branch <ticket ref | short description> [--from <source-branch>]
```

**What it does:** Confirms a clean working tree, fast-forwards the source branch, and creates a conventionally named work branch (`feat/<ticket-id>-<slug>`). Pushes nothing, commits nothing.

**Why:** Work never starts on the default branch or on a stale base. `/start-ticket` refuses to run on the default branch.

---

### Step 1: Start Ticket

```
/start-ticket <#12 | issue URL | path/to/local-ticket.md>
```

**What it does:**

1. Pulls the ticket (GitHub issue via `gh`, or a local file).
2. Enforces the intake contract: a feature ticket must state the desired outcome **with acceptance criteria**. If it doesn't, the skill stops and asks.
3. Restates scope in its own words and lists what is **explicitly out of scope**. Ambiguous criteria get asked about now, not discovered during implementation.
4. Runs scout reconnaissance (`patterns/scout-recon.md`) — parallel searches for affected surfaces, existing conventions, and tests — consolidated as `path:start-end` references.
5. Writes the plan from the skill's bundled `plan-template.md`.

**Why:** Every later stage reads from the plan. If the plan is wrong, everything downstream is wrong.

**Output:**

```
.claude-context/specs/<slug>/
  01-issue.md            # Resolved ticket
  02-investigation.md    # Confirmed scope, out-of-scope list, scout findings
  03-plan.md             # The spec: problem, evidence, proposed change,
                         #   out of scope, verification plan, risks
```

The skill stops here. It never implements.

---

### Gate 1: Approve the Plan

Read `03-plan.md`. Check that:

- every acceptance criterion from `01-issue.md` maps to part of the proposed change
- the out-of-scope list matches what you intend
- the verification plan would actually demonstrate the feature working

**Approve:** proceed to Step 2. Invoking `/implement` *is* the approval signal.

**Request changes:** tell Claude what's wrong and have it revise `03-plan.md`, or re-run `/start-ticket` if the scope or investigation itself was off. Don't implement from a plan you'd only half approve — an approval covers what was approved, nothing else.

**Reject:** stop. Fix the ticket first.

---

### Step 2: Implement

```
/implement .claude-context/specs/<slug>
```

**What it does:** Verifies the plan is complete and you're on a work branch. Reads `03-plan.md` **and** `02-investigation.md`. Implements the proposed change — and only that. Keeps hooks (format / lint / typecheck) and existing tests green. Captures the change and commits locally.

**Binding rules:**

- The plan's out-of-scope list is binding. Tempting refactors and adjacent fixes get noted, not done.
- If implementation shows the plan is wrong, the skill **stops and routes back to Gate 1** instead of improvising a different design under the old approval.

**Output:** a local commit on the work branch (nothing pushed), plus:

```
.claude-context/specs/<slug>/
  04-implementation.diff   # The change, with brief notes
```

---

### Step 3: Review Against Spec

```
/review-against-spec .claude-context/specs/<slug>
```

**What it does:** Compares the implementation to the **approved plan**. Classifies each planned element as *implemented*, *partial*, or *missing*. Walks the diff in reverse to flag *unplanned* changes and *scope violations*. Checks the verification plan still fits what was actually built.

**Why:** It answers *"did we build what we said?"* Clean code that doesn't meet the spec is still wrong.

**Run it with fresh eyes:** use a new session (or the reviewer agent, once it exists). A reviewer that watched the implementation inherits its blind spots.

**Report only — never fixes.** Fixes route back through `/implement`.

**Output:**

```
.claude-context/specs/<slug>/
  05-spec-review.md   # Per-item table, scope violations, verdict: pass | fail
```

A missing item, an unexplained unplanned change, or any scope violation is a **fail**.

---

### Step 4: Quality Review

```
/quality-review [.claude-context/specs/<slug>]
```

**What it does:** Reviews the change (not the repo) to a senior engineer's standard, with two classes of findings:

- **Mechanical — auto-fixed:** dead code, unused imports, debug artifacts, unreferenced TODOs, format/lint/type errors, obvious duplication. It fixes, re-runs the harness, and repeats until clean.
- **Judgment — reported, never fixed:** anti-patterns per the project's `CLAUDE.md`, error-handling gaps at async/API boundaries, naming and complexity, missing test coverage.

Pre-existing issues outside the change are noted as follow-ups, not fixed.

**Why:** It answers *"is it built well?"* Code that meets the spec but fails the project's standards still won't merge.

**Output:**

```
.claude-context/specs/<slug>/
  06-quality-review.md   # Fixes applied, judgment findings (file:line),
                         #   verdict: pass | pass with findings | fail
```

The skill stops at Gate 2. It does not commit, push, or open a PR.

---

### Gate 2: Review Both Results Together

Read `05-spec-review.md` and `06-quality-review.md` side by side.

| Spec review | Quality review | Next |
| ----------- | -------------- | ---- |
| pass | pass | Proceed to verification |
| pass | pass with findings | Decide per finding: accept, or back to `/implement` |
| fail — implementation gap | any | Back to `/implement`, then re-run both reviews |
| fail — the plan was wrong | any | Back to Gate 1 — revise the plan first |
| pass | fail | Back to `/implement` for the flagged findings |

If the same gap keeps surviving the loop, stop looping. Read the reports and decide whether the plan was unrealistic or the approach needs to change. This is where human judgment matters.

---

### Step 5: Verify *(planned: `/verify`)*

Exercise the feature end to end at runtime against the plan's verification plan — not just tests and type checks passing (`patterns/verification.md`). Until `/verify` exists, do this by hand and record what you did in `07-verification.md`.

---

### Step 6: Pull Request *(no skill yet)*

Only after Gate 2 and verification pass. Push the branch and open the PR from `.claude-context/templates/pr-template.md`, linking the artifact trail so reviewers can see the plan, the reviews, and the verification evidence.

---

## Quick Reference

| Step | Skill | Question it answers |
| ---- | ----- | ------------------- |
| 0 | `/branch <ref>` | Am I on a clean, current branch? |
| 1 | `/start-ticket <ref>` | What needs to be built, and how? |
| Gate 1 | — (human) | Is the plan good enough to build? |
| 2 | `/implement <trail>` | Build exactly the approved plan. |
| 3 | `/review-against-spec <trail>` | Did we build what we said? |
| 4 | `/quality-review [trail]` | Is it built well? |
| Gate 2 | — (human) | Does this ship? |
| 5 | `/verify` *(planned)* | Does it work at runtime? |
| 6 | — | Package it for review. |

---

## Where Files Live

```
.claude-context/specs/<slug>/
  01-issue.md               # Resolved ticket              (Step 1)
  02-investigation.md       # Scope + scout findings       (Step 1)
  03-plan.md                # The spec, approved at Gate 1 (Step 1)
  04-implementation.diff    # The change + notes           (Step 2)
  05-spec-review.md         # Did we build what we said?   (Step 3)
  06-quality-review.md      # Is it built well?            (Step 4)
  07-verification.md        # Runtime evidence             (Step 5)
```

One ticket, one directory, numbered artifacts. Every stage reads from and writes to the same trail, so later stages consume earlier files by name.

---

## When Things Go Wrong

**The ticket has no acceptance criteria:** `/start-ticket` stops and asks. Answer the question or fix the ticket. Don't let it guess.

**The plan is wrong:** fix it at Gate 1. Don't implement from a bad plan.

**Implementation hits a wall:** `/implement` stops and routes back to Gate 1. That's the intended behavior, not a failure. Revise the plan with what was learned.

**Spec review keeps failing:** check whether the gap is in the code (back to `/implement`) or in the plan (back to Gate 1). Re-running implementation against an unrealistic plan won't converge.

**A skill produces unexpected results:** check that the trail's earlier artifacts exist and are complete. A skill can only be as good as the context it reads.

---

## Key Principle

The plan is the thread. It starts as the output of `/start-ticket`, becomes the contract for `/implement`, and ends as the yardstick for `/review-against-spec`. Skip planning and there's nothing to review against. Skip review and there's no proof the work is correct.

Plan it. Approve it. Build it. Check it. Ship it.
