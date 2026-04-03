#!/usr/bin/env bash
# tests/ssg/antora/test.sh — Smoke test: Antora static site generation.
#
# Verifies that an Antora-based docs project can be installed and built inside
# DocOps Box using `dxbx exec`. Antora reads content from a git repository, so
# this test initialises a local git repo inside the container before building.
#
# Requirements: dxbx installed, Docker running, internet access (npm packages +
# Antora UI bundle download from GitLab).
set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../_lib.sh"
FIXTURE_DIR="$(dirname "${BASH_SOURCE[0]}")"

_test_start "antora"
_setup_test_dir

_on_exit() { _test_result "$_EXIT_CODE"; _cleanup; }
trap _on_exit EXIT

# Populate work dir with fixture files
cp "$FIXTURE_DIR/package.json"          "$TEST_DIR/"
cp "$FIXTURE_DIR/antora-playbook.yml"   "$TEST_DIR/"
cp -r "$FIXTURE_DIR/docs"               "$TEST_DIR/"

_info "image     : max:work (default)"
_info ""

# Step 1: Initialise a git repository.
# Antora requires the local-path content source to be a git repo with at least
# one commit. Git user config is set inline because this is a fresh container.
_info "Step 1/3  : initialising git repository"
_step _dxbx_exec bash -c "git config --global user.email 'ci@example.com' && git config --global user.name 'CI' && git init && git add . && git commit -q -m init"

# Step 2: Install Antora CLI and site generator into node_modules volume.
_info "Step 2/3  : npm install"
_step _dxbx_exec npm install

# Step 3: Generate the site.
_info "Step 3/3  : antora build"
_step _dxbx_exec npm run build

# Verify output
_assert_exists "build/site/index.html" "build/site/index.html"

exit "$_EXIT_CODE"
