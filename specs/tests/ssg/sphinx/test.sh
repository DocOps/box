#!/usr/bin/env bash
# tests/ssg/sphinx/test.sh — Smoke test: Sphinx static site generation.
#
# Verifies that a Sphinx project can be installed and built inside
# DocOps Box using `dxbx exec`. Sphinx installs into the container's
# Python venv (/opt/venv), which is backed by a named Docker volume.
#
# Requirements: dxbx installed, Docker running, internet access (pip packages).
set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../_lib.sh"
FIXTURE_DIR="$(dirname "${BASH_SOURCE[0]}")"

_test_start "sphinx"
_setup_test_dir

_on_exit() { _test_result "$_EXIT_CODE"; _cleanup; }
trap _on_exit EXIT

# Populate work dir with fixture files
cp "$FIXTURE_DIR/requirements.txt" "$TEST_DIR/"
cp "$FIXTURE_DIR/conf.py"          "$TEST_DIR/"
cp "$FIXTURE_DIR/index.rst"        "$TEST_DIR/"

_info "image     : max:work (default)"
_info ""

_info "Step 1/2  : pip install"
_step _dxbx_exec pip install -r requirements.txt

_info "Step 2/2  : sphinx-build"
_step _dxbx_exec sphinx-build -b html . _build/html

_assert_exists "_build/html/index.html" "_build/html/index.html"

exit "$_EXIT_CODE"
