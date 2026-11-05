#!/usr/bin/env bash
# Runs each task on both tinydb setups (/init alone, /init + harnify) and reports pass rates.
# Usage: run.sh [runs per task and setup, default 3] [task glob, default *]
# Sessions are headless with --setting-sources project,local, so only the setup's own files
# reach the agent: your ~/.claude/CLAUDE.md and user settings stay out.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
runs=${1:-3}; glob=${2:-*}
out=$here/results/$(date +%Y%m%dT%H%M%S); mkdir -p "$out"
budget=${BUDGET_PER_RUN:-2}

for t in "$here"/tasks/$glob/; do
  task=$(basename "$t")
  for setup in init harnify; do
    for i in $(seq "$runs"); do
      id=$task-$setup-$i; ws=$(mktemp -d); trace=$out/$id.jsonl
      (cd "$ws" && bash "$here/scaffold-tinydb.sh" "$setup" $(cat "$t/scaffold-args" 2>/dev/null)) >/dev/null
      (cd "$ws" && claude -p "$(cat "$t/prompt.md")" --setting-sources project,local \
        --permission-mode bypassPermissions --output-format stream-json --verbose \
        --max-budget-usd "$budget" < /dev/null) > "$trace" 2>"$out/$id.err" || true
      (cd "$ws" && TRACE=$trace bash "$t/check.sh") > "$out/$id.checks" 2>&1 || true
      if [ -f "$t/judge.md" ]; then
        # The judge sees the rubric, the agent's commands and its final reply, nothing else.
        evidence=$(jq -r 'select(.type=="assistant").message.content[]? | select(.name=="Bash") | "$ " + .input.command' "$trace"
                   printf '\nFINAL REPLY:\n'; jq -r 'select(.type=="result") | .result // ""' "$trace")
        # Three Haiku votes, majority wins: one vote misjudged a correct answer in testing.
        votes=0
        for _ in 1 2 3; do
          v=$(cd "$(mktemp -d)" && claude -p "$(cat "$t/judge.md")

$evidence

Respond with exactly one word: PASS or FAIL." --model haiku --setting-sources project \
            --max-budget-usd 0.2 < /dev/null 2>/dev/null || echo ERROR)
          grep -qw PASS <<<"$v" && ! grep -qw FAIL <<<"$v" && votes=$((votes + 1))
        done
        [ "$votes" -ge 2 ] && echo "PASS judge" >> "$out/$id.checks" || echo "FAIL judge" >> "$out/$id.checks"
      fi
      cost=$(jq -r 'select(.type=="result") | .total_cost_usd' "$trace" | tail -1)
      printf '%s cost=%s %s\n' "$id" "${cost:-?}" "$(grep -c '^PASS' "$out/$id.checks")/$(grep -cE '^(PASS|FAIL)' "$out/$id.checks")"
      rm -rf "$ws"
    done
  done
done

echo; echo "Pass rate per check (task, setup):"
for f in "$out"/*.checks; do b=$(basename "$f" .checks); grep -E '^(PASS|FAIL)' "$f" | sed "s|^|${b%-*} |"; done \
  | awk '{k=$1" "$3; n[k]++; if ($2=="PASS") p[k]++} END {for (k in n) printf "%-40s %d/%d\n", k, p[k], n[k]}' | sort
echo "Results: $out"
