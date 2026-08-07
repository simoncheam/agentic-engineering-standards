# CLAUDE.md — Conventions Template

> This is the template other projects copy and adapt. It encodes the standards this repo documents.

## Workflow

- All non-trivial work follows a defined workflow (see `workflows/` in agentic-engineering-standards).
- Bugs: reproduce before diagnosing. Diagnose before fixing. Verify against the original reproduction.
- Plans are approved at a review gate before implementation begins.
- Verification is a required step: exercise the affected flow, don't just run the type checker.

## Change discipline

- Smallest change that fixes the cause, not the symptom.
- Match the surrounding code's idiom, naming, and comment density.
- No drive-by refactors inside a bug fix — note them, don't do them.

## Project specifics (adapt per project)

- Stack: <!-- e.g. Next.js 15, TypeScript strict, TailwindCSS -->
- Commands: <!-- build / test / lint commands -->
- Conventions: <!-- project-specific rules -->
