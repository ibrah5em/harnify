---
name: init
description: Set up a project for Claude Code from an idea in an empty folder, or add harnify's layer to a repo that already has a CLAUDE.md. Interviews you, then writes AGENTS.md, .claude/ (CLAUDE.md, working style, rules, agents, settings, picked skills) and docs/agent/. Writes nothing outside the project and commits nothing.
disable-model-invocation: true
argument-hint: "[project idea]"
---

# harnify init

Set the project up so every later session starts oriented: it knows the goal, what's open,
what was settled, and where to write what it learns.

Idea from the person: $ARGUMENTS

Files next to this one: `interview.md`, `toolbox.md`, `templates.md`. The person's library is
`${CLAUDE_PLUGIN_ROOT}/library/`.

**Writes only:** `AGENTS.md`, `.claude/`, `.mcp.json` (if an MCP server is picked),
`docs/agent/`. No code, no scaffold, no dependency installs, no `git init`, no commits. It
runs nothing from the project or the registry: no `npm`, `npx`, formatters or builds. If the
repo's lint would reformat the new files, say so in the report.

## Mode

- **new:** the folder holds nothing but a `.git` with no commits, a README and a LICENSE:
  `ls -A | grep -vxiE '\.git|readme(\.[a-z]+)?|license(\.[a-z]+)?'` prints nothing.
- **existing:** anything else. Needs a `CLAUDE.md` or `AGENTS.md` already. If there's
  neither, stop and tell the person to run `/init` first: it reads code better than this
  skill, and harnify only adds its layer on top.
- **already set up:** `docs/agent/plan.md` exists. Stop, say so, and offer to do what
  `$ARGUMENTS` asks as ordinary work. harnify doesn't upgrade a project in place.

## Nothing global

Everything lands in the project and loads only in sessions started there. These CLIs default
to a global scope, so always pass the flag:

| Command | Always use |
|---|---|
| `claude plugin install` / `enable` / `disable` | `--scope project`, or `local` in a shared repo (`toolbox.md`, Scope) |
| `claude plugin marketplace add` | the same scope as the plugin |
| `claude mcp add` | `--scope project` (writes `.mcp.json`) |

Never write under `~/.claude/` or to `~/.claude.json`.

## 0. Preflight

Stop if `pwd` is `$HOME`, `/` or inside `~/.claude`: `.claude/` there is the global config.

Existing mode: if `git status --short` shows changes to `AGENTS.md`, `CLAUDE.md`, `.claude/`
or `.gitignore`, stop and ask. Other uncommitted files are the person's work: leave them alone
and keep them out of the proposed commits.

Snapshot global state for the check in step 4:

```bash
s=$(mktemp -d); jq -S '.enabledPlugins' ~/.claude/settings.json > $s/before-plugins
jq -S '.mcpServers' ~/.claude.json > $s/before-mcp; echo $s
```

Read `~/.claude/CLAUDE.md` if it exists. Don't ask what it already answers. Don't copy it into
the project except through `working-style.md`.

## 1. Interview

Follow `interview.md`. Existing mode: read the README, manifests, `git log --oneline -15`, the
CLAUDE.md or AGENTS.md and any `docs/` first, and ask only what they leave open.

## 2. Toolbox

Follow `toolbox.md`: pick from the library and the person's plugins, ask the one optional
question about plugins and MCP servers, install what they approve, trim what's unrelated.

## 3. Write

From `templates.md`:

- `AGENTS.md`. New mode: write it. Existing mode: if the project has only a CLAUDE.md,
  leave that file's text alone, create `AGENTS.md` with just the Docs section and
  Conventions, and add `@AGENTS.md` as the CLAUDE.md's first line. If `AGENTS.md` exists,
  add the sections it's missing.
- `.claude/CLAUDE.md` (new mode only; an existing root CLAUDE.md already does its job).
- `.claude/rules/working-style.md`, if the person said yes or the interview skipped the
  question: copy `${CLAUDE_PLUGIN_ROOT}/library/rules/working-style.md` unchanged. It lives in
  the project because cloud sessions and other contributors never load the global file.
- `.claude/rules/<area>.md` for area knowledge the interview turned up, each with `paths:`.
- `.claude/agents/<name>.md` for the agents the person picked.
- `.claude/settings.json`: merge with `jq` into whatever is there, never overwrite. Add keys
  and append to arrays in place; don't reorder or sort. A value already set that conflicts
  with the person's rules (say `autoMemoryEnabled: true`) stays as it is and goes in the
  report as a proposed change.
- `docs/agent/plan.md` with one open item per v1 outcome, `docs/agent/decisions/` with one
  file per call the interview settled, and the first log, `docs/agent/logs/<today>-init.md`.
  `notes/` only if there's a note to put in it.

Keep `AGENTS.md` and `.claude/CLAUDE.md` under ~60 lines together: both load every turn, and
a generated context file that restates the code makes agents worse, not better. Only write
what the person said and what the code can't show. New mode has no code yet, so leave
commands and layout out until the session that writes them.

## 4. Verify

Run each and fix what fails:

- `jq empty .claude/settings.json` (and `.mcp.json` if written) exits 0.
- `claude plugin list --json | jq -r '.[] | select(.enabled and (.projectPath == null or .projectPath == env.PWD)) | .id' | sort -u`
  prints exactly the plugins picked. Don't filter on `.scope=="project"`: that lists every
  project's installs, and enabling an already-installed plugin only writes `settings.json`.
- `wc -l AGENTS.md .claude/CLAUDE.md` is under ~60 combined. Existing mode: the cap covers
  only what this run wrote; an existing CLAUDE.md that's already long is a report line, not
  something to trim.
- Every item in `plan.md` has a `Done when` a stranger could check by running something.
- `git status --short` (if there's a repo) lists only the paths in **Writes only** above.
- Global state is unchanged: rerun the snapshot into `after-*` files and `diff` each pair.
  Another session can change global settings at the same time, so before undoing anything,
  check it was this run's command. Undo only what this run wrote.

## 5. Report

Short:
- proposed commits, split by concern, explicit paths, conventional messages
  (`chore(claude): …`, `docs(agent): …`)
- what was installed, with sources; what was trimmed; what the person turned down
- the permission deny rules that are on
- the open items in `plan.md`
- what the person must do: `git init -b main` if there's no repo, approving `.mcp.json`
  servers on the next start, stack lines for `.gitignore` once code exists

End with: "Next: commit, then ask for <first open item>."
