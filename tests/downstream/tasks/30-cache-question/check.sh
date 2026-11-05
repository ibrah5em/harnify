. "$(dirname "$0")/../../lib.sh"
check names-table-py 'final | grep -q "table\.py"'
check names-clear-cache 'final | grep -q "clear_cache"'
check names-update-table 'final | grep -q "_update_table"'
