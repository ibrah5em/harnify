# Plan

v1 is done when Ibrahem has an upstream PR open whose branch passes `uv run pytest` and the
mypy check, with a test that fails on `master` and a changelog entry.

## Open
- baseline: the suite and type check pass on a clean `master` here. Done when:
  `rm -f .coverage && uv run pytest -q` and `uv run pytest --mypy -m mypy tinydb tests`
  both exit 0.
- first-issue: blocked on Ibrahem picking an upstream issue. Done when: the issue number is
  on this line and a `fix/<n>-…` branch has a test that fails (`uv run pytest <test id>`
  exits 1) on `master`'s code.
- first-pr: after first-issue. Done when: the `tinydb-reviewer` agent returns "ready" and
  `git diff master...HEAD --name-only` lists no agent files.

## Later
- Look for open upstream issues touching the query cache or `CachingMiddleware`; recent
  fixes cluster there.
