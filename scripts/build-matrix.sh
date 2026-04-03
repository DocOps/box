#!/usr/bin/env bash
# scripts/build-matrix.sh — Build the full DocOps Box image matrix.
#
# For every combination of Ruby version × variant × context, this script:
#   1. Runs `docker build` with the right --build-arg and --tag flags.
#   2. Optionally pushes all tags to the registry (--push).
#
# Tag scheme:
#   {registry}/box-{variant}:{context}-{ruby}   versioned tag (every build)
#   {registry}/box-{variant}:{context}          alias for the primary Ruby version
#
# GitHub Actions calls this script rather than encoding matrix logic in YAML.
# The matrix is defined at the top of this file; edit it to add/remove versions.
#
# Usage: ./scripts/build-matrix.sh [--dry-run] [--push] [--registry NAME] [-h]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# MATRIX — sourced from bin/dxbx (canonical source of truth).
# Edit DXBX_* constants in bin/dxbx to add/remove versions/variants/contexts.
# shellcheck source=../bin/dxbx
source "${SCRIPT_DIR}/../bin/dxbx"
RUBY_VERSIONS=("${DXBX_RUBY_VERSIONS[@]}")
PRIMARY_RUBY="$DXBX_PRIMARY_RUBY"  # Receives the unversioned tag alias ({context} only)
VARIANTS=("${DXBX_VARIANTS[@]}")   # max = +Node +Python; min = Pandoc + Vale only
CONTEXTS=("${DXBX_CONTEXTS[@]}")   # work = interactive Zsh; live = minimal, for CI
REGISTRY="${REGISTRY:-docopslab}"

# FLAGS
DRY_RUN=false
PUSH=false
LOAD=false
GHA_CACHE=false
# Default: build both architectures. Override with --platforms or $PLATFORMS.
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64}"

# tag::universal-style-helpers[]
_bold() { printf '\033[1m%s\033[0m' "$*"; }
_green() { printf '\033[32m%s\033[0m' "$*"; }
_yellow() { printf '\033[33m%s\033[0m' "$*"; }
_red() { printf '\033[31m%s\033[0m' "$*"; }
_tick() { printf '%s %s\n' "$(_green '✓')" "$*"; }
_warn() { [[ "${DXBX_SHOW_WARNINGS:-true}" == true ]] && printf '%s %s\n' "$(_yellow '⚠')" "$*"; }
_fail() { printf '%s %s\n' "$(_red '✗')" "$*"; }
_info() { printf '  %s\n' "$*"; }
_sep() { printf '%s\n' "────────────────────────────────────────────────"; }
_run_echo() { [[ "${DXBX_SHOW_COMMANDS:-true}" == true ]] && printf '\n%s %s\n\n' "$(_bold '▶')" "$(_bold "$*")"; }
# end::universal-style-helpers[]

# Run a command, printing it first for transparency.
# In dry-run mode, prints the command but does not execute it (returns 0).
_run() {
  if [[ "$DRY_RUN" == true ]]; then
    printf '  %s  %s\n' "$(_bold '[dry-run]')" "$*"
    return 0
  fi
  printf '\n  %s  %s\n\n' "$(_bold '▶')" "$*"
  "$@"
}

# tag::matrix-usage[]
_usage() {
  # Variables used in the heredoc are only available after parse; show defaults.
  cat <<HELP

$(_bold 'build-matrix.sh'): Build the full DocOps Box image matrix

$(_bold 'Usage:')
  ./scripts/build-matrix.sh [options]

$(_bold 'Options:')
  $(_bold '--dry-run')              Print all commands without executing
  $(_bold '--push')                 Build multi-platform and push all tags to the registry
  $(_bold '--load')                 Build native platform only and load into local daemon
                           (incompatible with --push; useful for local testing)
  $(_bold '--gha-cache')            Enable GitHub Actions layer cache (type=gha, per-image scope)
                           Pass this in CI to avoid full rebuilds on every push.
  $(_bold '--platforms SPEC')       Override target platforms (default: linux/amd64,linux/arm64)
                           Also honoured as the \$PLATFORMS environment variable.
  $(_bold '--registry NAME')        Override the registry prefix (default: docopslab)
                           Also honoured as the \$REGISTRY environment variable.
  $(_bold '-h, --help')             Show this help and exit

$(_bold 'Tag scheme:')
  {registry}/box-{variant}:{context}-{ruby}   versioned (every build)
  {registry}/box-{variant}:{context}          alias tag for primary Ruby only

$(_bold 'Examples:')
  ./scripts/build-matrix.sh --dry-run
  ./scripts/build-matrix.sh --push
  ./scripts/build-matrix.sh --load
  ./scripts/build-matrix.sh --load --platforms linux/arm64
  ./scripts/build-matrix.sh --registry myorg --push
  REGISTRY=myorg PLATFORMS=linux/arm64 ./scripts/build-matrix.sh --push

HELP
}
# end::matrix-usage[]

# Maps a Ruby major.minor version to the appropriate Debian base distro tag.
# All supported Ruby versions (3.2+) have slim-bookworm images available.
# Update this function whenever RUBY_VERSIONS is expanded.
_ruby_distro() {
  printf 'slim-bookworm'
}

# ARGUMENT PARSING
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)    DRY_RUN=true;         shift   ;;
    --push)       PUSH=true;            shift   ;;
    --load)       LOAD=true;            shift   ;;
    --gha-cache)  GHA_CACHE=true;       shift   ;;
    --platforms)  PLATFORMS="$2";       shift 2 ;;
    --registry)   REGISTRY="$2";        shift 2 ;;
    -h|--help)    _usage;               exit 0  ;;
    *)
      _fail "Unknown option: $1"
      _usage
      exit 1
      ;;
  esac
done

# Validate flag combinations.
if [[ "$PUSH" == true && "$LOAD" == true ]]; then
  _fail "--push and --load are mutually exclusive."
  exit 1
fi
# --load only supports a single platform; if the user hasn't overridden,
# default to the native architecture so the image is actually usable.
if [[ "$LOAD" == true && "$PLATFORMS" == "linux/amd64,linux/arm64" ]]; then
  native_os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  native_arch="$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')"
  PLATFORMS="${native_os}/${native_arch}"
fi

# HEADER
printf '\n%s\n' "$(_bold 'DocOps Box — Build Matrix')"
_sep
printf '%-22s %s\n' "Registry:"      "$REGISTRY"
printf '%-22s %s\n' "Ruby versions:" "${RUBY_VERSIONS[*]}"
printf '%-22s %s\n' "Primary Ruby:"  "$PRIMARY_RUBY"
printf '%-22s %s\n' "Variants:"      "${VARIANTS[*]}"
printf '%-22s %s\n' "Contexts:"      "${CONTEXTS[*]}"
printf '%-22s %s\n' "Platforms:"     "$PLATFORMS"
printf '%-22s %s\n' "GHA cache:"     "$GHA_CACHE"
printf '%-22s %s\n' "Dry run:"       "$DRY_RUN"
printf '%-22s %s\n' "Push:"          "$PUSH"
printf '%-22s %s\n' "Load (local):"  "$LOAD"
_sep
printf '\n'

# BUILD MATRIX
built=0
failed=0
pushed=0

for ruby in "${RUBY_VERSIONS[@]}"; do
  distro="$(_ruby_distro "$ruby")"
  for variant in "${VARIANTS[@]}"; do
    for context in "${CONTEXTS[@]}"; do

      versioned_tag="${REGISTRY}/box-${variant}:${context}-${ruby}"
      alias_tag="${REGISTRY}/box-${variant}:${context}"

      printf '%s  %s\n' "$(_bold '▸')" "$(_bold "$versioned_tag")"
      if [[ "$ruby" == "$PRIMARY_RUBY" ]]; then
        printf '    %s %s\n' "alias:" "$alias_tag"
      fi

      # Assemble --build-arg list from matrix dimensions + variant definition.
      build_args=(
        "--build-arg" "RUBY_VERSION=${ruby}"
        "--build-arg" "DISTRO=${distro}"
        "--build-arg" "IMAGE_CONTEXT=${context}"
      )
      while IFS= read -r arg; do
        build_args+=("--build-arg" "$arg")
      done < <(_variant_build_args "$variant" "$context")

      # Assemble --tag list; primary Ruby also gets the unversioned alias.
      tag_flags=("--tag" "$versioned_tag")
      if [[ "$ruby" == "$PRIMARY_RUBY" ]]; then
        tag_flags+=("--tag" "$alias_tag")
      fi

      # Compose the full buildx invocation.
      # --push: build multi-platform and push all tags atomically.
      # --load: build native platform only and import into the local daemon.
      # Neither: build to the BuildKit cache only (useful with --dry-run).
      buildx_flags=("--platform" "$PLATFORMS")
      if [[ "$PUSH" == true ]];  then buildx_flags+=("--push"); fi
      if [[ "$LOAD" == true ]];  then buildx_flags+=("--load"); fi

      # Per-image GitHub Actions cache. Scope key matches the versioned tag name
      # (registry-free) so each image variant gets its own independent cache.
      if [[ "$GHA_CACHE" == true ]]; then
        cache_scope="box-${variant}-${context}-${ruby}"
        buildx_flags+=("--cache-from" "type=gha,scope=${cache_scope}")
        buildx_flags+=("--cache-to"   "type=gha,mode=max,scope=${cache_scope}")
      fi

      # Build — failure is tracked rather than aborting immediately, so the full
      # matrix result is visible even when individual builds fail.
      if _run docker buildx build "${build_args[@]}" "${tag_flags[@]}" "${buildx_flags[@]}" "$PROJECT_ROOT"; then
        _tick "Built: $versioned_tag"
        built=$((built + 1))
        [[ "$PUSH" == true ]] && pushed=$((pushed + 1))
        [[ "$PUSH" == true && "$ruby" == "$PRIMARY_RUBY" ]] && pushed=$((pushed + 1))
      else
        _fail "Build failed: $versioned_tag"
        failed=$((failed + 1))
      fi

      printf '\n'
    done
  done
done

# SUMMARY
_sep
if [[ "$failed" -gt 0 ]]; then
  _fail "Matrix complete with errors — built: $built  pushed: $pushed  failed: $failed"
  printf '\n'
  exit 1
else
  _tick "Matrix complete — built: $built  pushed: $pushed"
  printf '\n'
fi
