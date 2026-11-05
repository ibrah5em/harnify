#!/usr/bin/env bash
# Seeds the current folder with tinydb at a pinned commit plus one of the fixture setups.
# Usage: scaffold-tinydb.sh <init|harnify> [staged]. Runs as you, in the workspace, with network.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
sha=edff96aeb2616402e9489d46e90a592c05565621
# Clone and uv caches live in the gitignored .eval-cache/ at the repo root. Copy mode keeps
# the venv free of hard links into the cache, so deleting a workspace never touches it.
cache=$here/../../.eval-cache/tinydb
export UV_CACHE_DIR=$here/../../.eval-cache/uv UV_LINK_MODE=copy
[ -d "$cache/.git" ] || git clone -q https://github.com/msiemens/tinydb "$cache"
git -C "$cache" cat-file -e "$sha^{commit}" 2>/dev/null || git -C "$cache" fetch -q origin
# Its own repo, even when the folder sits inside another one (plugin eval roots its repo at
# $HOME, one level up), so this folder is the root for the script and the agent.
git init -q -b master .
git fetch -q "$cache" "$sha"
git reset -q --hard FETCH_HEAD
cp -a "$here/fixtures/tinydb-$1/." .
# The venv and agent files stay out of `git status`, so the agent sees a clean tree.
ex=$(git rev-parse --git-path info/exclude); mkdir -p "$(dirname "$ex")"
printf '%s\n' .venv/ AGENTS.md CLAUDE.md .claude/ docs/agent/ >> "$ex"
uv venv -q .venv
uv pip install -q --python .venv/bin/python pytest pytest-cov pytest-pycodestyle pycodestyle -e .
# `staged` leaves a real, passing change in the index for the commit-and-push case.
if [ "${2:-}" = staged ]; then
  sed -i 's/^    def count(self, cond: QueryLike) -> int:$/    def count(self, cond: QueryLike) -> int:  # noqa: D401/' tinydb/table.py
  git add tinydb/table.py
fi
