---
name: branch
description: Create a work branch off the source branch before starting any work. Entrypoint skill; invoke explicitly. Never auto-triggers.
disable-model-invocation: true
argument-hint: "[ticket ref | short description] [--from <source-branch>]"
model: haiku
---

# /branch — stage 0: branch before work

Runs before any work starts. Mechanical by design (cheap model — token economics): it prepares a clean, up-to-date branch and stops.

## 1. Preflight

- Working tree must be clean. If there are uncommitted changes: **stop and ask** — stash, commit, or abort is the human's call. Never carry a dirty tree onto a new branch silently.

## 2. Resolve the source branch

- `--from <branch>` if given; otherwise the repo's default branch (`gh repo view --json defaultBranchRef` or `git symbolic-ref refs/remotes/origin/HEAD`).
- Sync it: `git fetch origin` then fast-forward only (`git pull --ff-only` on the source). If the source can't fast-forward, stop and report — never branch off a stale or diverged base.

## 3. Name the branch

Convention: `<type>/<ticket-id>-<slug>`

- `type`: `fix` (bug) | `feat` (feature) | `chore` | `docs` | `refactor` — from the ticket ref or description
- `ticket-id`: issue number if one exists (`fix/42-contact-form-timeout`); omit if none (`feat/lazy-load-recaptcha`)
- `slug`: 2–5 lowercase hyphenated words

If neither a ticket ref nor a description was given, ask — don't invent a name.

## 4. Create and switch

```
git switch -c <name> <source>
```

Do not push. Upstream is set on first push, at the PR stage — not here.

## 5. Stop

Report: branch name, source branch, and its sync state. Next step is `/start-ticket`.

## Exit criteria

- [ ] Clean tree confirmed (or the human resolved it)
- [ ] Source branch synced, fast-forward only
- [ ] Branch created with a conventional name; currently checked out
- [ ] Nothing pushed, nothing committed
