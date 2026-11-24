#!/usr/bin/env bash
# Generate initial states for all 90 xSokoban mazes, sequentially, on this machine.
#
# Usage: scripts/run_xsokoban.sh [ORDERING] [TIME_SECONDS] [RUN_IDS...]
#   ORDERING      ordering passed to bin/LocalSearch (default: wpdb4r_4ocr_pdb4r)
#   TIME_SECONDS  time limit per maze (default: 3600, as in the paper)
#   RUN_IDS       labels for repeated runs; each gets its own Results/<RUN_ID>/ folder
#                 (default: 01)
#
# Example: scripts/run_xsokoban.sh wpdb4r_4ocr_pdb4r 60 01 02 03 04 05
set -euo pipefail

cd "$(dirname "$0")/.."

ORDERING="${1:-wpdb4r_4ocr_pdb4r}"
LIMIT_TIME="${2:-3600}"
shift $(( $# > 2 ? 2 : $# ))
RUNS=("${@:-01}")

for run in "${RUNS[@]}"; do
  for i in $(seq -w 1 90); do
    name="instance_${i}"
    echo "run ${run}  ${name}  ${ORDERING}  ${LIMIT_TIME}s"
    ./bin/LocalSearch "${name}" "${ORDERING}" "${LIMIT_TIME}" "${run}"
  done
done
