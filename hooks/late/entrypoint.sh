#!/usr/bin/env bash
# entrypoint.sh: DocOps Box container entrypoint
#
# Baked into every DocOps Box image. Always runs as root at container startup.
# If HOST_UID or HOST_GID are set in the runtime environment, reconciles the
# container user's identity to match the host user's, then drops privileges
# and exec-replaces itself with the requested command.
#
# This fires regardless of how the container is started:
#   - dxbx run / shell / exec  (via Docker Compose)
#   - VS Code Dev Containers        (via Docker Compose + devcontainer.json)
#   - docker run / docker compose   (directly)
#
# Runtime environment variables (set by docopsbox.yml / devcontainer.json):
#   HOST_UID    Host user numeric ID.  If unset or empty, reconciliation is skipped.
#   HOST_GID    Host user numeric GID. If unset or empty, reconciliation is skipped.
#   RUN_USER    Container username. Defaults to "appuser".
#
# On macOS with Docker Desktop the VM layer provides transparent file ownership
# mapping, so HOST_UID/HOST_GID need not be set — the entrypoint becomes a no-op.
# On Linux, HOST_UID/HOST_GID should always be set to avoid permission mismatches.

set -e

RUN_USER="${RUN_USER:-appuser}"

if [ -n "${HOST_UID:-}" ] || [ -n "${HOST_GID:-}" ]; then
  CURRENT_UID=$(id -u "$RUN_USER")
  CURRENT_GID=$(id -g "$RUN_USER")
  TARGET_UID="${HOST_UID:-$CURRENT_UID}"
  TARGET_GID="${HOST_GID:-$CURRENT_GID}"

  if [ "$TARGET_UID" != "$CURRENT_UID" ] || [ "$TARGET_GID" != "$CURRENT_GID" ]; then
    # groupmod before usermod — usermod references the group by GID.
    groupmod --gid "$TARGET_GID" "$RUN_USER" 2>/dev/null || true
    usermod --uid "$TARGET_UID" --gid "$TARGET_GID" "$RUN_USER" 2>/dev/null || true
    # Repair ownership of container-managed paths.
    # /workspace is a bind mount — files there are already owned by the host user.
    # Chown only the directory entry (non-recursive) in case there is no bind mount.
    chown -R "$TARGET_UID:$TARGET_GID" \
        /usr/local/bundle /commandhistory /npm-cache /pip-cache /opt/venv \
        "/home/$RUN_USER" 2>/dev/null || true
    chown "$TARGET_UID:$TARGET_GID" /workspace /workspace/node_modules 2>/dev/null || true
  fi
fi

# Bootstrap the Python venv on first start (named volume starts empty).
# Guards: python3 must exist (ADD_PYTHON=true) and VIRTUAL_ENV must be set.
# Runs as root so we can chown immediately after; only fires on first start
# (when the volume is fresh and /opt/venv/bin/python does not yet exist).
if [ -n "${VIRTUAL_ENV:-}" ] && [ ! -f "${VIRTUAL_ENV}/bin/python" ] && command -v python3 > /dev/null 2>&1; then
  python3 -m venv "$VIRTUAL_ENV" 2>/dev/null || true
  chown -R "${TARGET_UID:-$(id -u $RUN_USER)}:${TARGET_GID:-$(id -g $RUN_USER)}" "$VIRTUAL_ENV" 2>/dev/null || true
fi

# print the name, tags, context, and key labels of the current image for ID purposes
if [ -f /etc/os-release ]; then
  . /etc/os-release
  image_ref="${DOCOPS_IMAGE_REF:-${IMAGE_REGISTRY:-docopslab}/box-${IMAGE_VARIANT:-${VARIANT:-max}}:${IMAGE_CONTEXT:-${CONTEXT:-work}}} (version ${DOCOPSBOX_VERSION:-unknown}"
  if [ -n "${DOCOPSBOX_IMAGE_ID:-}" ]; then
    image_ref+="; id: ${DOCOPSBOX_IMAGE_ID}"
  fi
  if [ -n "${DOCOPSBOX_IMAGE_DIGEST:-}" ]; then
    # Truncate to 12 chars after sha256: for readability
    clean_digest="${DOCOPSBOX_IMAGE_DIGEST#*sha256:}"
    image_ref+="; digest: ${clean_digest:0:12}"
  else
    image_ref+="; digest: none"
  fi
  echo "Starting DocOps Box container from: $image_ref)"
else
  echo "Starting DocOps Box container: unknown image (missing /etc/os-release)"
fi

exec gosu "$RUN_USER" "$@"
