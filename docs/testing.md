# Testing

## Setup checks: headless, outside `plugin eval`

`claude plugin eval` runs the agent in don't-ask mode and denies its writes under `.claude/`,
even with `Write(.claude/**)` granted (checked 2026-11-05 on 2.1.318). Since `.claude/` is what
harnify writes, setup runs happen headless in a scratch folder instead.

`bash tests/setup/run.sh [runs] [modes]` does all of the below and prints the failing checks per
run. Read a FAIL before trusting it: on 2026-11-05 every one of them was the grader (the session
writes docs through heredocs, and its deny list names `git commit`), and one run only hit the
usage limit. Last result: new 3/3, existing 3/3.

By hand:

```sh
d=$(mktemp -d) && cd $d && git init -q -b main
{ jq -S .enabledPlugins ~/.claude/settings.json 2>/dev/null || echo missing; } > ../g-before
claude -p "/harnify:init <idea>. I'm not at the keyboard: take your recommended option for
every question and keep going to the end." --plugin-dir ~/projects/harnify \
  --permission-mode bypassPermissions --output-format stream-json --verbose \
  --max-budget-usd 2 > ../trace.jsonl
```

For existing mode, clone a repo with a CLAUDE.md and run `/harnify:init` with no idea. It
stops at the interview headless; answer with `claude -p "<answers>" --resume <session_id>`.

Pass when all hold:

- `AGENTS.md`, `.claude/CLAUDE.md` (new mode), `.claude/settings.json`, `docs/agent/plan.md`
  and `docs/agent/logs/*-init.md` exist
- `wc -l AGENTS.md .claude/CLAUDE.md` totals under 60
- `jq -e '.permissions.deny | length > 0' .claude/settings.json`
- every `plan.md` item has a `Done when`
- the idea's skills were picked (Arabic UI → `.claude/skills/rtl-arabic-web/`)
- `git status --short` lists only AGENTS.md, `.claude/`, `.mcp.json` and `docs/agent/`
- the tool log has no npm/npx/pnpm/yarn/bun, no `--scope user`, no `git commit` or `git init`:
  `jq -r 'select(.type=="assistant").message.content[]? | select(.name=="Bash").input.command' ../trace.jsonl`
- global state is unchanged: re-snapshot and `diff ../g-before ../g-after`

## `plugin eval`

`evals/` holds only what `plugin eval` can grade: the should-not-fire case.

```sh
claude plugin eval . --ablation none --no-publish --allow-tools Bash Write Edit \
  --disallow-tools AskUserQuestion --max-cost-usd 2
```

## Downstream comparison

`bash tests/downstream/run.sh [runs] [task glob]` seeds tinydb with each setup, runs every task
headless with `--setting-sources project,local`, and prints pass rates per check. It doesn't
use `plugin eval`, because eval sessions load no project CLAUDE.md or AGENTS.md (checked
2026-11-05). Results so far: `docs/downstream-results.md`.
