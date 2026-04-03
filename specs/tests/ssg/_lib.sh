#!/usr/bin/env bash
#
# specs/tests/ssg/_lib.sh — Shared helpers for SSG smoke tests.
#
# Source this file at the top of each ssg/*/test.sh:
#   source "$(dirname "${BASH_SOURCE[0]}")/../_lib.sh"
#
# Build outputs are written to specs/tests/build/<ssg>/ (gitignored).
# Run with DEBUG=1 to keep build dirs after the test completes.

# Style helpers (match bin/dxbx palette)
_bold()   { printf '\033[1m%s\033[0m' "$*"; }
_green()  { printf '\033[32m%s\033[0m' "$*"; }
_yellow() { printf '\033[33m%s\033[0m' "$*"; }
_red()    { printf '\033[31m%s\033[0m' "$*"; }
_tick()   { printf '%s %s\n' "$(_green '✓')" "$*"; }
_fail()   { printf '%s %s\n' "$(_red '✗')" "$*"; }
_warn()   { printf '%s %s\n' "$(_yellow '⚠')" "$*"; }
_sep()    { printf '%s\n' "────────────────────────────────────────────────"; }
_info()   { printf '  %s\n' "$*"; }

# Per-test state (initialised by _test_start / _setup_test_dir).
SSG_NAME=""
TEST_DIR=""
_TEST_START=0
_EXIT_CODE=0

# _test_start "name"
#   Print a header and start the elapsed-time clock.
_test_start() {
  SSG_NAME="$1"
  _TEST_START=$(date +%s)
  printf '\n'
  _sep
  printf '%s\n' "$(_bold "▶ Testing: ${SSG_NAME}")"
  _sep
}

# _setup_test_dir
#   Create a temp work dir and provision DocOps Box config from local templates.
#   Sets $TEST_DIR. Each caller must register _cleanup with an EXIT trap.
#   Always removes any pre-existing volumes for this slug first so each run
#   starts from a clean state (important when DEBUG=1 skips cleanup on exit).
_setup_test_dir() {
  # specs/tests/ssg/_lib.sh is 3 levels deep; ../../.. reaches the repo root.
  REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
  # Pre-clean any volumes left over from a previous DEBUG run.
  local _slug="test-${SSG_NAME}"
  docker volume rm \
    "docops-${_slug}-bundle" \
    "docops-${_slug}-node" \
    "docops-${_slug}-python" \
    2>/dev/null || true
  TEST_DIR="${REPO_ROOT}/specs/tests/build/${SSG_NAME}"
  rm -rf "$TEST_DIR"
  mkdir -p "$TEST_DIR/.config"
  cp "$REPO_ROOT/templates/docopsbox.yml" "$TEST_DIR/.config/docopsbox.yml"
  cp "$REPO_ROOT/templates/.env" "$TEST_DIR/.config/.env"
  # Use a distinct PROJECT_SLUG per test so Docker volumes are isolated.
  sed -i "s/^PROJECT_SLUG=.*/PROJECT_SLUG=test-${SSG_NAME}/" "$TEST_DIR/.config/.env"
  _info "work dir  : $TEST_DIR"
}

# _cleanup
#   Remove the temp dir and associated Docker volumes (unless DEBUG=1).
#   Called from EXIT traps; always returns 0.
_cleanup() {
  if [[ "${DEBUG:-}" == "1" ]]; then
    _warn "DEBUG=1: keeping build dir: $TEST_DIR"
    return 0
  fi
  [[ -n "${TEST_DIR:-}" ]] && rm -rf "$TEST_DIR"
  # Remove per-project volumes created during this test run.
  # Volume names come from the 'name:' fields in templates/docopsbox.yml:
  #   docops-${PROJECT_SLUG}-bundle / -node / -python
  local slug="test-${SSG_NAME}"
  docker volume rm \
    "docops-${slug}-bundle" \
    "docops-${slug}-node" \
    "docops-${slug}-python" \
    2>/dev/null || true
}

# _dxbx_exec <cmd> [args...]
#   Run a `dxbx exec` command from TEST_DIR.
_dxbx_exec() {
  (cd "$TEST_DIR" && dxbx exec "$@")
}

# _step <cmd> [args...]
#   Run a command only if no prior step has failed.
#   Sets _EXIT_CODE on failure; subsequent _step calls are skipped.
_step() {
  [[ $_EXIT_CODE -eq 0 ]] || return 0
  "$@" || _EXIT_CODE=$?
}

# _assert_exists "relative/path" ["display label"]
#   Assert that a path exists under TEST_DIR.
#   Sets _EXIT_CODE=1 on failure.
_assert_exists() {
  local rel="$1" label="${2:-$1}"
  if [[ -e "$TEST_DIR/$rel" ]]; then
    _tick "output: $label"
    return 0
  else
    _fail "expected output not found: $label"
    _EXIT_CODE=1
    return 1
  fi
}

# _test_result $exit_code
#   Print pass/fail with elapsed time.
_test_result() {
  local code="${1:-$_EXIT_CODE}"
  local elapsed=$(( $(date +%s) - _TEST_START ))
  if [[ "$code" -eq 0 ]]; then
    _tick "$(_bold "$SSG_NAME") — PASSED (${elapsed}s)"
  else
    _fail "$(_bold "$SSG_NAME") — FAILED (${elapsed}s)"
  fi
  return "$code"
}
