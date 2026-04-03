#!/usr/bin/env bash
# tests/ssg/eleventy/test.sh — Smoke test: Eleventy (11ty) static site generation.
#
# Verifies that an Eleventy project can be installed and built inside
# DocOps Box using `dxbx exec`.
#
# Requirements: dxbx installed, Docker running, internet access (npm packages).
set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../_lib.sh"
FIXTURE_DIR="$(dirname "${BASH_SOURCE[0]}")"

_test_start "eleventy"
_setup_test_dir

_on_exit() { _test_result "$_EXIT_CODE"; _cleanup; }
trap _on_exit EXIT

# Populate work dir with fixture files
cp "$FIXTURE_DIR/package.json" "$TEST_DIR/"
cp "$FIXTURE_DIR/index.md"     "$TEST_DIR/"

_info "image     : max:work (default)"
_info ""

_info "Step 1/2  : npm install"
_step _dxbx_exec npm install

_info "Step 2/2  : eleventy build"
_step _dxbx_exec npm run build

_assert_exists "_site/index.html" "_site/index.html"

exit "$_EXIT_CODE"
