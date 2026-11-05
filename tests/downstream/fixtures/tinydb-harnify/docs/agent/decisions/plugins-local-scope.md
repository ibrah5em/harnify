---
description: plugins are enabled at local scope in this repo
---

# Plugins at local scope

Settled 2026-11-05 at init (recommended option, Ibrahem away); reopen only with Ibrahem.

Other people commit here, so plugin picks go in `.claude/settings.local.json` (gitignored by
Claude Code) instead of the shared `.claude/settings.json`. Enabled: `pyright-lsp`,
`context7`, `andrej-karpathy-skills`. Rejected: project scope, which would push personal
tool choices on every contributor.
