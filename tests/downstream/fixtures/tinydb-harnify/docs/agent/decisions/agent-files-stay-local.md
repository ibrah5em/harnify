---
description: harness files are never part of an upstream TinyDB branch or PR
---

# Harness files stay out of upstream

Settled 2026-11-05 at init (recommended option, Ibrahem away); reopen only with Ibrahem.

The repo belongs to msiemens and has many contributors. `AGENTS.md`, `CLAUDE.md`, `.claude/`
and `docs/agent/` are Ibrahem's working setup, not something upstream asked for, so they
never land in a PR branch. Preferred mechanism: list them in `.git/info/exclude`, which
keeps them out of `git status` without touching the tracked `.gitignore`.

Rejected: committing them on `master` (would leak into every branch cut from it) and adding
them to `.gitignore` (a tracked change upstream would have to accept).

Wrong if: upstream adopts its own agent files, or this becomes Ibrahem's own fork that
diverges for good.
