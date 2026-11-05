# harnify

A Claude Code plugin that sets up a project's `.claude/` from an idea. You describe what
you're building, answer a short interview, and it writes the files later sessions start from:

- `AGENTS.md`: what the project is, its conventions, and where sessions write what they learn
- `.claude/`: rules, the specialist agents you picked, skills that fit the stack, and
  `settings.json` with `permissions.deny` entries for the rules that would cost the most to break
- `docs/agent/`: `plan.md` with the open items, each with a checkable *Done when*, plus
  `decisions/` and a session log

Claude Code's `/init` reads existing code, so it has nothing to work with in an empty folder.
harnify covers that case. In a repo that already has a CLAUDE.md, it leaves that file alone
and adds only its own layer.

## Install

```sh
claude plugin marketplace add ibrah5em/harnify --scope project
claude plugin install harnify@harnify --scope project
```

Or load it for one session without installing:

```sh
git clone https://github.com/ibrah5em/harnify ~/harnify
claude --plugin-dir ~/harnify
```

## Use

In an empty folder, or a repo that already has a CLAUDE.md:

```
/harnify:init a recipe site where people share family recipes in Arabic and English
```

It asks 5–8 questions, writes the files, checks them, and ends with proposed commits. It
doesn't commit for you.

## What it won't do

- Write anything outside the project. Every plugin and MCP install it runs gets
  `--scope project` (or `local`), and it diffs your global settings before and after.
- Install hooks, scripts or any code. harnify is markdown only, so there's nothing to upgrade
  or keep in sync later.
- Run `npm`, `npx`, formatters or builds, scaffold code, or run `git init`.
- Touch a project that already has `docs/agent/plan.md`.

## Does it help?

Your rules reach sessions that never load your global CLAUDE.md: a cloud session, a
teammate's machine, a fresh clone. Code quality was the same as with `/init` alone, and it
costs more.

Measured on [tinydb](https://github.com/msiemens/tinydb), 3 headless runs per cell, with the
global CLAUDE.md kept out so each setup's own files are all the agent sees:

| Task | `/init` | `/init` + harnify | Cost per run |
|---|---|---|---|
| Add `limit` to `Table.search`, with tests and a changelog entry | 18/18 | 18/18 | $0.19 → $0.29 |
| "Commit what is staged and push it to master" | 0/12 | 12/12 | $0.13 → $0.15 |
| Where is the query cache invalidated, and why | 12/12 | 12/12 | $0.13 → $0.17 |

With `/init` alone, every run committed on `master` with an AI co-author trailer and tried to
push. With harnify, every run cited the project's branch and push rules and stopped. Those
rules came from the setup interview, so this measures whether they survive, not whether the
model reasons better. The extra cost is the session routine: reading the plan, branching and
writing a log. One fixture and three tasks is a small sample; the details and limits are in
[docs/downstream-results.md](docs/downstream-results.md), and `tests/downstream/run.sh`
reruns it.

## Why there are no hooks

harnify replaces an earlier tool of mine, vold, which grew to about 1,400 lines of hooks and
scripts installed into every project. Each piece of code needed another one to keep it working:
upgrade tracking, a state generator, a checker. None of it changed what the setup picked for
a project. Those picks come from the model's judgment, and the markdown is where that judgment
lives.

The trade-off: rules are advice, except the deny entries. And nothing checks `docs/agent/`
for drift.

Generated context files can also make agents worse when they restate the code (see
arXiv:2602.11988), so harnify keeps `AGENTS.md` plus `.claude/CLAUDE.md` under about 60 lines
and writes only what the code can't show.

## Library

The `library/` folder holds the extras harnify can copy into a project: a working-style rule
(ask instead of guessing, push back, plain voice), which it offers as one interview question,
and skills for RTL/Arabic web UI and web accessibility, which it picks when the project needs
them.

## License

MIT
