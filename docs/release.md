# Release plan

The competition is mostly from search snippets (2026-11-05). claudify (`/claudify:init`
from an existing repo), revfactory/harness, project-init (installs hooks), dotforge and
tyevans bootstrap. None of them start from an empty folder, and none publish a with/without
number. The ETH paper found that generated context files hurt agents, so a measured gain is
the pitch.

## 1. Installable

- [x] LICENSE, `.claude-plugin/marketplace.json`, CLAUDE.md moved to `.claude/`
- [x] working-style.md made an interview question
- [x] README. Done when `claude plugin validate . --profile directory` reports no README problem
- [ ] `.claude-plugin/icon.png`, square, 512–2048 px. The directory keeps the first icon
      submitted, so this one is final
- [x] Re-run existing mode on a fresh draw-to-web clone with the toolbox Scope rule.
      Done when the log shows plugins at the scope the rule picks and global state unchanged
- [ ] Terminal recording of new mode for the top of the README

## 2. Evidence

`plugin eval` can't grade setup runs (it denies `.claude/` writes), and its with/without
ablation doesn't measure harnify. See `docs/testing.md`.

- [ ] Setup checks per `docs/testing.md`, new and existing mode, 3 runs each, all checks pass
- [x] Should-not-fire case `evals/02-no-setup-unasked` (pilot: 1.0)
- [x] Downstream: tinydb set up by `/init` and by `/init` + harnify, run headless by
      `tests/downstream/run.sh` (plugin eval loads no project CLAUDE.md). Results in
      `docs/downstream-results.md`
- [ ] Results table in the README

## 3. Release

- [ ] Public `ibrah5em/harnify`, push. `claude plugin tag`
- [ ] `validate --profile directory` clean, submit to the plugin directory
- [ ] Listings: awesome-claude-code, claudepluginhub, skills.sh
- [ ] Launch post with the recording and the eval table: Show HN, r/ClaudeAI, X, Arabic dev
      communities (the RTL skill)
- [ ] Archive vold with a pointer here

## Status 2026-11-05

- Downstream comparison done: `docs/downstream-results.md`. The rules task is 0/12 with `/init`
  alone and 12/12 with harnify. Quality is equal on the coding task and the code question, and
  harnify costs 35% more overall.
- Next: decide how the README states it, then the icon, the recording, and Phase 3.
