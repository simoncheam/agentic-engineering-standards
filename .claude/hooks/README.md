# Hooks

Deterministic enforcement — checks that run automatically on tool events, so the standards hold even when nobody remembers to invoke them.

**No hooks exist yet** — this directory holds only this README. Planned (general-purpose; each detects the project's tooling rather than assuming a stack):

| Hook | Event | Enforces | Status |
|---|---|---|---|
| format | PostToolUse (Edit/Write) | consistent formatting on every change | 🚧 planned |
| lint | PostToolUse (Edit/Write) | lint clean before work continues | 🚧 planned |
| typecheck | PostToolUse (Edit/Write) | types hold on every change | 🚧 planned |

Hooks are the cheapest reliability layer: they catch mechanical drift so review gates can spend human attention on judgment, not formatting.
