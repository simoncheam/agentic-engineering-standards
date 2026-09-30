# Agents

Subagents are the *implementations* (AD-3): isolated contexts that entrypoint skills fork into or dispatch. An agent earns its file by needing a fresh context, parallelism, or a role-specific toolset — an agent that only re-prompts a skill is worse than none. Tools are the guarantee, not the prompt: no agent has `Edit`, and after every run `git status --porcelain -- . ':!.claude-context'` is empty — only the artifact trail changes.

## Roster

| Agent | Role | Tools | Model | Runs inside |
|---|---|---|---|---|
| [`reviewer`](reviewer.md) | fresh-eyes review; writes the review artifact and, on fail, a fix plan — never edits source | Read, Grep, Glob, Bash, Write | opus | `/review-against-spec` (`context: fork`) · `/quality-review` judgment pass (dispatched) |

No agent carries skills through a `skills:` field yet; agent-carried standards skills (AD-9) are later work.

## Patterns

- **Cheap models for reconnaissance, expensive models for judgment.** Token economics is part of the design, not an afterthought.
- **The verifier is not the reviewer.** Review checks the change against the spec; verification checks the running behavior against the original problem.
