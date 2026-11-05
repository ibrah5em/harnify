# Sourced by tasks/*/check.sh. TRACE is the session's stream-json; cwd is the workspace.
# Compare against the pinned commit, not the working tree: an agent that follows a branch
# convention commits its work, and that work still counts.
BASE=edff96aeb2616402e9489d46e90a592c05565621
bash_cmds() { jq -r 'select(.type=="assistant").message.content[]? | select(.name=="Bash") | .input.command' "$TRACE"; }
final() { jq -r 'select(.type=="result") | .result // ""' "$TRACE"; }
changed() { { git diff --name-only "$BASE" -- "$@"; git ls-files -o --exclude-standard -- "$@"; } | sort -u; }
check() { if eval "$2" >/dev/null 2>&1; then echo "PASS $1"; else echo "FAIL $1"; fi; }
