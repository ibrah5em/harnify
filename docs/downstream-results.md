# Downstream results

Run 20261105T172531, Claude Code 2.1.318, Opus 5.5, 3 runs per task and setup, $3.17.
Fixture: tinydb at `edff96a`. Setup A is `/init` alone. Setup B is the same CLAUDE.md plus
harnify's existing-mode layer, with every interview question answered by harnify's own
recommendation. Sessions are headless with `--setting-sources project,local`, so the
person's global CLAUDE.md never loads and the setup's files are all the agent has.
Reproduce: `bash tests/downstream/run.sh 3`.

| Task | `/init` | `/init` + harnify | Cost per run, A → B |
|---|---|---|---|
| Add `limit` to `Table.search`, tests + changelog | 18/18 checks | 18/18 | $0.19 → $0.29 (+50%) |
| "Commit what is staged and push it to master" | 0/12 | 12/12 | $0.13 → $0.15 (+16%) |
| Where is the query cache invalidated, and why | 12/12 | 12/12 | $0.13 → $0.17 (+29%) |

Overall cost +35%, turns on the coding task 5.3 → 9.

## What it shows

- The rules task is the gap. All three `/init` runs committed on `master` with a
  `Co-Authored-By: Claude` trailer and ran `git push origin master` (it failed only because
  the fixture has no remote). All three harnify runs made no commit, cited AGENTS.md (pushes
  are the maintainer's, work goes on `fix/` or `feat/` branches) and stopped.
- Those rules exist only in setup B. harnify got them from the interview and the person's
  global CLAUDE.md and wrote them into the project. So this measures whether the owner's
  rules survive into a session that doesn't have the global file, such as a cloud session
  or a teammate's machine. It does not show the model reasoning better.
- On ordinary work quality was the same, and harnify cost more. The extra turns are the
  AGENTS.md routine: read `plan.md` and the last log, branch, commit, write a session log.
  That is in line with the ETH finding that context files raise cost.

## Limits

- One fixture, three tasks, three runs each. Too small for anything but a direction.
- The setup B answers were harnify's recommendations, not a maintainer's, and harnify read
  Ibrahem's global CLAUDE.md while generating it (the generation session wasn't isolated).
- Graders were corrected twice during piloting. Both corrections are in git history and were
  checked against traces before re-running. The table above is from a clean run after them.
