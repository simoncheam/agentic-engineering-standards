# Bug Resolution Workflow

> **Status:** 🚧 Being documented from daily practice.

The most bounded problem class — which is why it's the first workflow, and why chaining starts here (AD-6).

## The five-stage partition

Each stage runs as a standalone skill with a clear entry and exit. Stages are hardened individually before any chaining; chains grow two links at a time with deterministic validation between links.

| # | Stage | Skill | Exit criteria |
|---|---|---|---|
| 1 | Research & planning | `/bug` → `/plan` | reproduction confirmed; scout-grounded plan approved at the gate |
| 2 | Implementation | `/implement` | smallest change that fixes the cause; hooks green |
| 3 | Review against spec | `/review` | change matches the approved plan; no scope creep |
| 4 | QA validation | `/verify` | affected flow exercised at runtime; fix demonstrated against the original reproduction |
| 5 | PR & documentation | — | change packaged with its artifact trail |

## Stage notes (to document from practice)

- [ ] **Intake:** what a well-formed bug report contains before work starts
- [ ] **Reproduction:** the bug must be reproduced before it is diagnosed — no reproduction, no diagnosis
- [ ] **Investigation:** scout reconnaissance (`patterns/scout-recon.md`) — evidence before hypotheses
- [ ] **Plan + gate:** what the engineer approves, and what rejection routes back to
- [ ] **Implementation:** cause not symptom; no drive-by refactors
- [ ] **Review + gate:** review against the *approved plan*, not against taste
- [ ] **Verification:** runtime, against the original reproduction — not just tests passing (`patterns/harness.md`)
- [ ] **Artifact trail:** each stage leaves its artifact (issue, investigation, plan, diff, review, verification) — this is what `examples/` captures
