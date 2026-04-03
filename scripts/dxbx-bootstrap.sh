#!/bin/sh
# shellcheck shell=sh
# dxbx-bootstrap.sh: Verify prerequisites and install dxbx.
# Requires: curl (offered for install if absent); docker (warned if absent)
#
# Usage (piped; happy path only -- interactive prompts require file invocation):
#   curl -fsSL https://raw.githubusercontent.com/DocOps/box/latest/scripts/dxbx-bootstrap.sh | sh
#
# Usage (file; supports prompts for Homebrew/Bash auto-install):
#   curl -fsSL https://raw.githubusercontent.com/DocOps/box/latest/scripts/dxbx-bootstrap.sh -o dxbx-bootstrap.sh
#   ./dxbx-bootstrap.sh

set -eu  # -o pipefail omitted; not POSIX

# CONSTANTS
readonly DXBX_REPO_URL="${DXBX_REPO_URL:-https://raw.githubusercontent.com/DocOps/box/latest}"

# HELPERS
_info()  { printf '[INFO] %s\n' "$1"; }
_warn()  { printf '[WARN] %s\n' "$1" >&2; }
_error() { printf '[ERROR] %s\n' "$1" >&2; }

_die() {
  _error "$1"
  printf 'Please resolve the issue above and run this script again.\n' >&2
  exit 1
}

_cleanup() {
  [ -n "${TMP_DXBX:-}" ] && rm -f "$TMP_DXBX"
}

# Prompts for confirmation; returns 1 (skip) when stdin is not a terminal.
_confirm() {
  if [ ! -t 0 ]; then
    _warn "Non-interactive mode; skipping: $1"
    _info "Run this script from a file to enable interactive prompts."
    _info "  ./dxbx-bootstrap.sh"
    return 1
  fi
  printf '\n%s [y/N] ' "$1" >&2
  read -r _confirm_answer
  case "$_confirm_answer" in
    [yY]*) return 0 ;;
    *)     return 1 ;;
  esac
}

# CHECKS
check_curl() {
  command -v curl >/dev/null 2>&1 && return 0
  _confirm "curl is required to run this script. Install curl?" \
    || _die "curl is required. Please install curl and re-run this script."

  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y curl
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y curl
  elif command -v brew >/dev/null 2>&1; then
    brew install curl
  else
    _die "curl is missing and automatic installation failed. Please install curl manually."
  fi

  _info "curl installed."
}

check_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    _warn "Docker not found. Please install Docker Desktop (macOS/Windows) or Docker Engine (Linux)."
    return
  fi
  if ! docker compose version >/dev/null 2>&1; then
    _warn "Docker Compose (v2) not found. Please update Docker Desktop or install the Compose plugin."
    return
  fi
  _info "Docker and Docker Compose are present."
}

check_bash() {
  command -v bash >/dev/null 2>&1 || _die "Bash is not installed. Please install Bash 4.0+."

  BASH_VER=$(bash -c 'echo "${BASH_VERSINFO[0]}"')

  if [ "$BASH_VER" -ge 4 ]; then
    _info "Bash ${BASH_VER} detected; requirement satisfied."
    return
  fi

  _warn "Bash ${BASH_VER} detected; Bash 4.0+ is required."

  if [ "$(uname)" = "Darwin" ]; then
    _confirm "Install Bash 4+ via Homebrew on this Mac?" \
      || _die "Bash 4.0+ is required. Please install it manually and re-run."
    if ! command -v brew >/dev/null 2>&1; then
      _confirm "Homebrew is not installed. Install Homebrew now?" \
        || _die "Homebrew is required to install Bash on macOS. Please install both manually and re-run."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
    fi
    brew install bash
  elif command -v apt-get >/dev/null 2>&1; then
    _confirm "Install Bash 4+ via apt-get (requires sudo)?" \
      || _die "Bash 4.0+ is required. Please install it manually and re-run."
    sudo apt-get update && sudo apt-get install -y bash
  else
    _die "Bash 4.0+ is required and no package manager was found. Please install Bash manually."
  fi

  BASH_VER=$(bash -c 'echo "${BASH_VERSINFO[0]}"')
  [ "$BASH_VER" -lt 4 ] && _die "Bash upgrade did not succeed. Please install Bash 4.0+ manually."
  _info "Bash 4.0+ is now available."
}

# INSTALL
check_existing() {
  install_dir="${XDG_BIN_HOME:-$HOME/.local/bin}"
  existing_path=""
  existing_ver=""

  # Prefer the PATH-visible copy; fall back to the canonical install location.
  if command -v dxbx >/dev/null 2>&1; then
    existing_path="$(command -v dxbx)"
  elif [ -x "${install_dir}/dxbx" ]; then
    existing_path="${install_dir}/dxbx"
  else
    return 0
  fi

  existing_ver=$("$existing_path" --version 2>/dev/null || printf 'unknown')
  _warn "dxbx is already installed: ${existing_path} (${existing_ver})"
  _confirm "Reinstall dxbx?" || exit 0
}

install_dxbx() {
  TMP_DXBX=$(mktemp)
  trap _cleanup EXIT INT TERM

  _info "Downloading dxbx..."
  curl -fsSL "${DXBX_REPO_URL}/bin/dxbx" -o "$TMP_DXBX" \
    || _die "Failed to download dxbx. Check your connection or the repository URL."

  chmod +x "$TMP_DXBX"

  _info "Running dxbx install..."
  "$TMP_DXBX" install
}

# CLEANUP
cleanup_self() {
  [ -f "$0" ] || return 0
  _confirm "Remove the bootstrap script ($0)?" || return 0
  rm -f "$0"
  _info "Bootstrap script removed."
}

# MAIN
check_curl
check_docker
check_bash
check_existing
install_dxbx
cleanup_self

_info "Bootstrap complete. You can now run 'dxbx' from anywhere."