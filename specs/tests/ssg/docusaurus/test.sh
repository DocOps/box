#!/usr/bin/env bash
# tests/ssg/docusaurus/test.sh — Smoke test: Docusaurus static site generation.
#
# Verifies that a Docusaurus project can be installed and built inside
# DocOps Box using `dxbx exec`.
#
# Requirements: dxbx installed, Docker running, internet access (npm packages).
set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../_lib.sh"
FIXTURE_DIR="$(dirname "${BASH_SOURCE[0]}")"

_test_start "docusaurus"
_setup_test_dir

_on_exit() { _test_result "$_EXIT_CODE"; _cleanup; }
trap _on_exit EXIT

# Populate work dir with fixture files
cp "$FIXTURE_DIR/package.json"          "$TEST_DIR/"
cp "$FIXTURE_DIR/docusaurus.config.js"  "$TEST_DIR/"
mkdir -p "$TEST_DIR/docs" "$TEST_DIR/src/css"
cp "$FIXTURE_DIR/docs/intro.md"         "$TEST_DIR/docs/"
cp "$FIXTURE_DIR/src/css/custom.css"    "$TEST_DIR/src/css/"

_info "image     : max:work (default)"
_info ""

_info "Step 1/2  : npm install"
_step _dxbx_exec npm install

_info "Step 2/2  : docusaurus build"
_step _dxbx_exec npm run build

_assert_exists "build/index.html" "build/index.html"

exit "$_EXIT_CODE"
