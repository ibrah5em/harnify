#!/usr/bin/env bash
# Setup checks from docs/testing.md, scripted. Runs harnify headless in a scratch folder and
# checks what it wrote.
# Usage: run.sh [runs per mode, default 3] [modes, default "new existing"]
# Runs are sequential: global state is shared, so a parallel run would blame the wrong one.
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
plugin=$(cd "$here/../.." && pwd)
runs=${1:-3}; modes=${2:-new existing}
out=$here/results/$(date +%Y%m%dT%H%M%S); mkdir -p "$out"
budget=${BUDGET_PER_RUN:-2}
existing_src=${EXISTING_SRC:-$HOME/projects/draw-to-web}
idea="an Arabic-first recipe site where Syrian home cooks share family recipes, Next.js and Postgres"
away="I'm not at the keyboard: take your recommended option for every question and keep going to the end."

# Everything harnify must never touch outside the project.
snapshot() {
  { jq -S .enabledPlugins ~/.claude/settings.json 2>/dev/null || echo missing
    jq -S '.mcpServers // {}' ~/.claude.json 2>/dev/null || echo missing
    ls -A ~/.claude/skills ~/.claude/agents ~/.claude/commands 2>/dev/null || true; }
}

claude_run() { # trace, then claude args
  local trace=$1; shift
  claude "$@" --plugin-dir "$plugin" --permission-mode bypassPermissions \
    --output-format stream-json --verbose --max-budget-usd "$budget" < /dev/null >> "$trace" 2>>"${trace%.jsonl}.err" || true
}

# Bash commands with heredoc bodies removed: the session writes docs through heredocs, and a
# plan line like `pnpm build` is text, not a call.
run_cmds() {
  jq -j 'select(.type=="assistant").message.content[]? | select(.name=="Bash") | .input.command + "\u0000"' "$1" |
    perl -0 -ne 'chomp; s/<<-?\s*[\x27"]?(\w+)[\x27"]?([^\n]*)\n.*?^\s*\1\s*$/<<$1$2/gms; print "$_\n"'
}

check() { if eval "$2" >/dev/null 2>&1; then echo "PASS $1"; else echo "FAIL $1"; fi; }

# Every "- " item under "## Open" in plan.md, continuation lines included, has "Done when".
plan_items_ok() {
  awk '/^## /{open=($0=="## Open")} open && /^- /{if (item!="" && item !~ /Done when/) bad=1; item=$0; next}
       open && /^  /{item=item" "$0; gsub(/[ \t]+/, " ", item)} END{if (item!="" && item !~ /Done when/) bad=1; exit bad}' docs/agent/plan.md \
    && grep -q '^- ' <(awk '/^## /{open=($0=="## Open")} open' docs/agent/plan.md)
}

for mode in $modes; do
  for i in $(seq "$runs"); do
    id=$mode-$i; ws=$(mktemp -d); trace=$out/$id.jsonl; mkdir -p "$out/$id.ws"
    snapshot > "$out/$id.g-before"
    if [ "$mode" = new ]; then
      (cd "$ws" && git init -q -b main)
      (cd "$ws" && claude_run "$trace" -p "/harnify:init $idea. $away")
    else
      git clone -q "$existing_src" "$ws"
      cp "$existing_src/CLAUDE.md" "$ws/"   # gitignored there, so the clone lacks it
      (cd "$ws" && claude_run "$trace" -p "/harnify:init")
      # Headless stops at the interview; answer it in the same session.
      sid=$(jq -r 'select(.type=="result") | .session_id' "$trace" | tail -1)
      (cd "$ws" && claude_run "$trace" -p "$away" --resume "$sid")
    fi
    snapshot > "$out/$id.g-after"
    cmds=$(jq -r 'select(.type=="assistant").message.content[]? | select(.name=="Bash") | .input.command' "$trace")
    printf '%s\n' "$cmds" > "$out/$id.bash"
    (
      cd "$ws"
      files="AGENTS.md .claude/settings.json docs/agent/plan.md"
      [ "$mode" = new ] && files="$files .claude/CLAUDE.md"
      check files "for f in $files; do test -f \$f; done && ls docs/agent/logs/*-init.md"
      # Existing mode keeps the repo's own CLAUDE.md, so the cap covers what harnify generates.
      check lines "[ \$(cat AGENTS.md \$( [ $mode = new ] && echo .claude/CLAUDE.md) | wc -l) -lt 60 ]"
      check deny "jq -e '.permissions.deny | length > 0' .claude/settings.json"
      check plan-done-when plan_items_ok
      [ "$mode" = new ] && check rtl-skill "test -f .claude/skills/rtl-arabic-web/SKILL.md"
      check git-status "! git status --short -uall | grep -vE '^.. \"?(AGENTS\.md|\.claude/|\.mcp\.json|docs/agent/)'"
      check no-pkg-managers "! run_cmds '$trace' | grep -qE '(^|[;&|\`]|[\$][(]) *(sudo )?(npm|npx|pnpm|yarn|bunx?)( |$)'"
      check no-user-scope "! grep -q -- '--scope user' '$out/$id.bash'"
      check no-commit-or-init "! run_cmds '$trace' | grep -qE '(^|[;&|\`]|[\$][(]) *git( -C [^ ]+)? (commit|init)( |$)'"
      check global-unchanged "diff -q '$out/$id.g-before' '$out/$id.g-after'"
      git status --short -uall > "$out/$id.status"
    ) > "$out/$id.checks" 2>&1
    # Keep only what harnify wrote, for reading later.
    (cd "$ws" && cp -r --parents AGENTS.md CLAUDE.md .claude docs/agent .mcp.json "$out/$id.ws/" 2>/dev/null) || true
    cost=$(jq -s '[.[] | select(.type=="result") | .total_cost_usd] | add' "$trace")
    printf '%s cost=%s %s/%s %s\n' "$id" "$cost" "$(grep -c '^PASS' "$out/$id.checks")" \
      "$(grep -cE '^(PASS|FAIL)' "$out/$id.checks")" "$(grep '^FAIL' "$out/$id.checks" | cut -d' ' -f2 | tr '\n' ' ')"
    rm -rf "$ws"
  done
done
echo "Results: $out"
