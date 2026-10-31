# Templates

## AGENTS.md

Always loaded, by every harness. Project facts and the docs policy; nothing the global file,
`working-style.md` or the code already says. Don't list the installed skills or agents: they
describe themselves.

```markdown
# <Project name>

<What it is and who it's for, in two or three lines.>

## Stack
- <language + version>, <framework>, <package manager>. Runs on <target>.

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
- <project-specific only: source language for i18n, naming, data rules, what not to touch>
```

Existing mode with a CLAUDE.md already there: write only Docs and Conventions.

## .claude/CLAUDE.md

```markdown
@../AGENTS.md

## Claude
- <Claude-only lines: a gotcha, what to ask before doing, which agent to hand what to.>
```

## docs/agent/plan.md

```markdown
# Plan

v1 is done when <one concrete, checkable sentence>.

## Open
- short-links: short links survive a restart. Done when: `POST /links` returns 201 and a
  7-char code, and the code still redirects after the service restarts.
- link-store: after short-links. Done when: …
- deploy: blocked on the Cloudflare account ID from the person. Done when: …

## Later
- <one-line ideas that aren't v1>
```

The top item is next. Order is dependency order; say `after <slug>` or `blocked on <what>`
when it isn't obvious. A slug never changes: commits and logs find the item by it. An item
needing more than three lines gets a note, linked from its line.

## docs/agent/logs/YYYY-MM-DD-slug.md

Use only the lines that apply.

```markdown
# 2026-10-31 link store on SQLite

- Did: <what changed, one or two lines>
- Closed:
  - short-links: short links survive a restart. Done when: … Proof: `curl -sI
    localhost:8787/abc1234` after a restart → `301`
- Decided: <a call and its reason, or "assumed X, because Y">
- Found: <what wasn't written down, or what a doc had wrong>
- Commits: a1b2c3d, d4e5f6a
- Next: <what the next session should pick up, or what it's blocked on>
```

The first is `<date>-init.md`: what harnify wrote and the items it opened.

## docs/agent/decisions/slug.md

```markdown
---
description: the site runs no code at request time
---

# The site runs no code at request time

Settled 2026-10-31 by <the person>; don't reopen without them.

<What was decided and why. What was rejected, and why. How to tell if it's ever wrong.>
```

## docs/agent/notes/slug.md

```markdown
---
description: queue retries double-charge unless the job key is set
---

# <Topic>

<The fact, how it was found, and what it depends on. Point at the command or file that
produces a number instead of copying the number.>
```

## .claude/agents/name.md

```markdown
---
name: <kebab-name>
description: <when to delegate, with concrete triggers; Claude decides from this line alone>
tools: <minimal list; read-only roles get no Edit or Write>
model: sonnet
---

You are the <role> for <project>.

<3-8 imperative steps specific to this project and stack.>

<What to return: a short structured result, not a transcript.>
```

`model: opus` only for judgment-heavy roles: security, architecture, design review.

## .claude/rules/area.md

Loads only when a session touches a matching path.

```markdown
---
paths:
  - "<glob, e.g. src/i18n/**>"
---

# <Area>

<Short imperative rules, each with its reason.>
```

## .claude/settings.json

Merge into what's there with `jq`, starting from `{}`. `enabledPlugins` is written by the
`claude plugin … --scope project` commands, not by hand.

```json
{
  "attribution": {"commit": "", "pr": "", "sessionUrl": false},
  "includeCoAuthoredBy": false,
  "skillOverrides": {"<unrelated skill>": "off"},
  "permissions": {"deny": ["<from toolbox.md, Deny rules>"]}
}
```

Drop `attribution` and `includeCoAuthoredBy` if the person is fine with AI trailers.
