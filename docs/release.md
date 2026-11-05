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
- [x] `.claude-plugin/icon.png`, square, 512–2048 px. The directory keeps the first icon
      submitted, so this one is final. 1024 px, the open-frame mark
- [x] Re-run existing mode on a fresh draw-to-web clone with the toolbox Scope rule.
      Done when the log shows plugins at the scope the rule picks and global state unchanged
- [ ] Terminal recording of new mode for the top of the README. Deferred 2026-11-05. Draft
      tape: `docs/demo.tape`, never rendered. A probe tape with 3 min of unhidden waits made
      vhs's ffmpeg grow to 10 GB and OOM-killed WSL. Next try: `pgrep -af ffmpeg` first,
      foreground under `systemd-run --user --scope -p MemoryMax=4G`, every wait inside
      Hide/Show. The workspace trust dialog defaults to "No, exit"; the tape answers it

## 2. Evidence

`plugin eval` can't grade setup runs (it denies `.claude/` writes), and its with/without
ablation doesn't measure harnify. See `docs/testing.md`.

- [x] Setup checks per `docs/testing.md`, new and existing mode, 3 runs each, all checks pass.
      `tests/setup/run.sh`, 2026-11-05: new 3/3 ($0.39–0.52), existing 3/3 ($0.73–1.46)
- [x] Should-not-fire case `evals/02-no-setup-unasked` (pilot: 1.0)
- [x] Downstream: tinydb set up by `/init` and by `/init` + harnify, run headless by
      `tests/downstream/run.sh` (plugin eval loads no project CLAUDE.md). Results in
      `docs/downstream-results.md`
- [x] Results table in the README

## 3. Release

- [x] Public `ibrah5em/harnify`, push, `claude plugin tag` (harnify--v0.1.0, 2026-11-05)
- [ ] `validate --profile directory` clean, submit to the plugin directory
- [ ] Listings: claudepluginhub, awesome-claude-code from 2026-11-14 (14-day rule). Drafts in `docs/launch.md`
- [ ] Launch post with the eval table, recording optional (decided 2026-11-05): Show HN, r/ClaudeAI, X, Arabic dev
      communities (the RTL skill)
- [x] Archive vold with a pointer here (public, archived 2026-11-05)

## Status 2026-11-05

- Downstream comparison done: `docs/downstream-results.md`. The rules task is 0/12 with `/init`
  alone and 12/12 with harnify. Quality is equal on the coding task and the code question, and
  harnify costs 35% more overall.
- README states it: rules survive, quality equal, cost shown. Next: setup checks (3 runs per
  mode), the icon, the recording, then Phase 3.
