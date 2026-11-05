## Docs

Project memory is `docs/agent/`. At the start of a session read
[plan.md](docs/agent/plan.md) and the newest log (`ls docs/agent/logs | tail -1`). To find a
note or decision, `grep -r '^description:' docs/agent/notes docs/agent/decisions` and open
only what matches.

What goes where:
- `plan.md` holds open work only. Edit an item's own lines. Never delete an open item: mark
  it `dropped: <why>` and let the closing session move it out.
- An item closes when its Done when is shown by running something. Cut it from plan.md and
  paste it into this session's log with a `Proof:` line: the command and what it printed.
- A call the person settled gets `decisions/<slug>.md`. Never edit one; a new decision that
  replaces it says so, and the old one gets one line: `Superseded by <slug>`.
- A fact that cost time to find gets `notes/<slug>.md`, edited in place while it holds.
- A standing instruction for working here is one line under Conventions below.
- Every session that changed files writes `logs/<YYYY-MM-DD>-<slug>.md` before it ends,
  once. Never edit an earlier log; if one was wrong, the next one says so.
- Commit subjects for an item end in `(<item slug>)`, so `git log --grep <slug>` finds them.

## Conventions
- This is a clone of upstream TinyDB (msiemens). Work happens on a `fix/…` or `feat/…`
  branch off `master`, one issue per branch; never commit on `master`.
- Upstream's CONTRIBUTING wins over global habits: issue text, PR descriptions and review
  replies are written by Ibrahem. Draft code and tests only; offer bullet facts, not prose.
- Every fix ships with a test that fails before it and an entry in `docs/changelog.rst`.
- Agent files (`AGENTS.md`, `CLAUDE.md`, `.claude/`, `docs/agent/`) never go into an
  upstream branch or PR.
- Pushes are denied to the agent; Ibrahem runs pushes (`! git push`).
