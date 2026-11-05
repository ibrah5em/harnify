# Release plan

The competition is mostly from search snippets (2026-11-05). claudify (`/claudify:init`
from an existing repo), revfactory/harness, project-init (installs hooks), dotforge and
tyevans bootstrap. None of them start from an empty folder, and none publish a with/without
number. The ETH paper found that generated context files hurt agents, so a measured gain is
the pitch.

## 1. Installable

- [x] LICENSE, `.claude-plugin/marketplace.json`, CLAUDE.md moved to `.claude/`
- [x] working-style.md made an interview question
- [ ] README. Done when `claude plugin validate . --profile directory` reports no README problem
- [ ] `.claude-plugin/icon.png`, square, 512–2048 px. The directory keeps the first icon
      submitted, so this one is final
- [ ] Re-run existing mode on a fresh draw-to-web clone with the toolbox Scope rule.
      Done when the log shows plugins at the scope the rule picks and global state unchanged
- [ ] Terminal recording of new mode for the top of the README

## 2. Evidence

- [ ] `evals/` setup cases (new and existing mode). Graders: AGENTS.md + .claude/CLAUDE.md
      ≤ 60 lines, nothing under `~/.claude`, deny entries present, every plan item has *Done when*
- [ ] Downstream cases: the same task after harnify and after a bare `/init`, run with
      `claude plugin eval --ablation with-without --max-cost-usd <n>`
- [ ] Results table in the README, whatever the numbers come out as

## 3. Release

- [ ] Public `ibrah5em/harnify`, push. `claude plugin tag`
- [ ] `validate --profile directory` clean, submit to the plugin directory
- [ ] Listings: awesome-claude-code, claudepluginhub, skills.sh
- [ ] Launch post with the recording and the eval table: Show HN, r/ClaudeAI, X, Arabic dev
      communities (the RTL skill)
- [ ] Archive vold with a pointer here
