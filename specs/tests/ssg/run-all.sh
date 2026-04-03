#!/usr/bin/env bash
# tests/ssg/run-all.sh — Run all SSG smoke tests and report a summary.
#
# Usage:
#   ./tests/ssg/run-all.sh                  # run all six SSGs
#   ./tests/ssg/run-all.sh antora mkdocs    # run specific SSGs
#   DEBUG=1 ./tests/ssg/run-all.sh          # keep temp dirs on failure/success
set -uo pipefail
# Ensure DEBUG is explicitly exported so each test subshell inherits it.
export DEBUG="${DEBUG:-}"
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALL_SSGS=(antora docusaurus astro eleventy sphinx mkdocs)
SSGS_TO_RUN=("${@:-${ALL_SSGS[@]}}")

PASSED=()
FAILED=()

for ssg in "${SSGS_TO_RUN[@]}"; do
  script="$TESTS_DIR/$ssg/test.sh"
  if [[ ! -f "$script" ]]; then
    printf '\033[31m✗\033[0m  %s (test.sh not found)\n' "$ssg"
    FAILED+=("$ssg")
    continue
  fi
  if bash "$script"; then
    PASSED+=("$ssg")
  else
    FAILED+=("$ssg")
  fi
done

printf '\n'
printf '%s\n' "────────────────────────────────────────────────"
printf '%s\n' "$(printf '\033[1mResults\033[0m'): ${#PASSED[@]} passed, ${#FAILED[@]} failed"
printf '%s\n' "────────────────────────────────────────────────"
for p in "${PASSED[@]}"; do printf '\033[32m✓\033[0m  %s\n' "$p"; done
for f in "${FAILED[@]}"; do printf '\033[31m✗\033[0m  %s\n' "$f"; done
printf '\n'

if [[ "${DEBUG:-}" == "1" ]]; then
  BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/build"
  mapfile -t _lingering < <(find "$BUILD_DIR" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort)
  if [[ ${#_lingering[@]} -gt 0 ]]; then
    printf '\033[33m⚠\033[0m  DEBUG=1: build dirs kept at %s:\n' "$BUILD_DIR"
    printf '     %s\n' "${_lingering[@]##"$BUILD_DIR"/}"
    printf '\n'
  fi
fi

[[ ${#FAILED[@]} -eq 0 ]]
