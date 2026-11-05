. "$(dirname "$0")/../../lib.sh"
check limit-in-signature '.venv/bin/python -c "import inspect, tinydb.table as t; assert \"limit\" in inspect.signature(t.Table.search).parameters"'
check suite-passes-now '.venv/bin/pytest -q -p no:cacheprovider'
check test-added 'changed tests/ | grep -q .'
check changelog-entry 'git diff "$BASE" -- docs/changelog.rst | grep -qi "^+.*limit"'
check no-commit-on-master 'test "$(git rev-parse master)" = "$BASE"'
