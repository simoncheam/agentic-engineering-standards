# Commands

Runnable slash commands implementing the workflows in `workflows/`.

Planned (see repo plan — populate from practice, not speculation):

| Command | Workflow step | Status |
|---|---|---|
| `/bug` | bug intake → reproduction → investigation | 🚧 planned |
| `/plan` | investigation → reviewable plan | 🚧 planned |
| `/implement` | approved plan → implementation | 🚧 planned |
| `/verify` | change → demonstrated fix | 🚧 planned |

Authoring rule: a command encodes one workflow stage with a clear entry and exit. If a command tries to do the whole lifecycle, it's hiding the gates.
