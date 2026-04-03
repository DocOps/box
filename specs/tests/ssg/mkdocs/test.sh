#!/usr/bin/env bash
# tests/ssg/mkdocs/test.sh — Smoke test: MkDocs static site generation.
#
# Verifies that a MkDocs project can be installed and built inside
# DocOps Box using `dxbx exec`. MkDocs installs into the container's
# Python venv (/opt/venv), which is backed by a named Docker volume.
#
# Requirements: dxbx installed, Docker running, internet access (pip packages).
set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../_lib.sh"
FIXTURE_DIR="$(dirname "${BASH_SOURCE[0]}")"

_test_start "mkdocs"
_setup_test_dir

_on_exit() { _test_result "$_EXIT_CODE"; _cleanup; }
trap _on_exit EXIT

# Populate work dir with fixture files
cp "$FIXTURE_DIR/requirements.txt" "$TEST_DIR/"
cp "$FIXTURE_DIR/mkdocs.yml"       "$TEST_DIR/"
mkdir -p "$TEST_DIR/docs"
cp "$FIXTURE_DIR/docs/index.md"    "$TEST_DIR/docs/"

_info "image     : max:work (default)"
_info ""

_info "Step 1/2  : pip install"
_step _dxbx_exec pip install -r requirements.txt

_info "Step 2/2  : mkdocs build"
_step _dxbx_exec mkdocs build

_assert_exists "site/index.html" "site/index.html"

exit "$_EXIT_CODE"
