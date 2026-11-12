#!/usr/bin/env bash
# Makes every .sh file in the current directory executable — no hardcoded
# file names, so it works as a generic helper from any directory.
#
# Usage:
#   cd scripts && bash chmod-scripts.sh    # first run (before it is executable)
#   ./chmod-scripts.sh                     # afterwards
#
# Idempotent: re-running is safe, and chmod-ing itself is harmless.
set -euo pipefail
shopt -s nullglob

scripts=(*.sh)
if [ ${#scripts[@]} -eq 0 ]; then
    echo "No .sh files in $(pwd); nothing to do."
    exit 0
fi

for script in "${scripts[@]}"; do
    chmod +x "$script"
    echo "executable: $script"
done
