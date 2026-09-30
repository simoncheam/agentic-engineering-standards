# Ticket trail — layout

One directory per ticket at `.claude-context/tickets/<ticket-id>/`, where `<ticket-id>` is `<issue-number>-<slug>` (the suffix `/branch` gives the branch, e.g. `42-contact-form-timeout`), or `<slug>` alone when there is no issue. `/start-ticket` copies the three numbered files below from this directory; everything after that is written by the stage that owns it. This README is the one description of the trail — other docs link here.

## Numbered files — the gate chain

A number means a later stage reads the file by name. Nothing else gets a number.

| File | Written by | Read by | Feeds |
|---|---|---|---|
| `00-ticket-details.md` | `/start-ticket` | `/start-ticket` (scope), Gate 1, `/review-against-spec` (AC coverage) | the only source of acceptance criteria |
| `01-context-analysis.md` | `/start-ticket` | `/start-ticket` (plan evidence), `/implement` | Gate 1 |
| `02-implementation-plan.md` | `/start-ticket` | `/implement`, `/review-against-spec` | **Gate 1** — human approval before any code |
| `03-implementation.diff` | `/implement`; re-captured by `/build-from-spec` | `/review-against-spec`, `/quality-review` | review |
| `04-spec-review.md` | `reviewer` via `/review-against-spec` | Gate 2 | verdict: `pass` \| `fail` |
| `05-quality-review.md` | `reviewer` via `/quality-review` | Gate 2 | verdict: `pass` \| `pass-with-findings` \| `fail` |
| `06-verification.md` | verification stage (`/verify`, planned; by hand until then) | Gate 2 | verdict: `pass` \| `fail` |

Each review artifact ends with its verdict line and carries `Attempt: N` (see `.claude-context/README.md`, Conventions).

## Subfolders — created on demand

None exist when the trail is created. The first writer creates the folder (AD-8).

| Folder | Holds | Written by | File names |
|---|---|---|---|
| `scout/` | raw scout reports, one per search direction, before consolidation into `01` | `/start-ticket` | `<direction>.md` — `affected-surfaces.md`, `existing-conventions.md`, `tests-and-validation.md` |
| `fix-plans/` | the executable output of a failing review (AD-13) | `reviewer` | `spec-<N>.md`, `quality-<N>.md` — `N` counts attempts of that kind |
| `code-reviews/` | PR review feedback pulled from GitHub, and the responses to it | the human, or a later `/pr` stage | `<date>-<reviewer-handle>.md` |
| `decisions/` | one file per choice made after Gate 1 that the plan did not settle | the human | `<short-kebab-title>.md` |
| `errors/` | errors hit during implementation or verification — cause and resolution | `/implement`, verification stage, the human | `<short-kebab-title>.md` |
| `docs/` | external library or API documentation fetched for this ticket | `/start-ticket`, the human | `<library-or-api>.md` |
| `design/` | design references and UI specs the ticket depends on | the human | `<screen-or-component>.md` |
| `evidence/` | screenshots, logs and command output that prove verification | verification stage | `<check>.<ext>`, cited from `06-verification.md` |
