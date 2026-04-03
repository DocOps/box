#!/usr/bin/env bash
# entrypoint.sh — DocOps Box container entrypoint
#
# Baked into every DocOps Box image. Always runs as root at container startup.
# If HOST_UID or HOST_GID are set in the runtime environment, reconciles the
# container user's identity to match the host user's, then drops privileges
# and exec-replaces itself with the requested command.
#
# This fires regardless of how the container is started:
#   - docopsbox run / shell / exec  (via Docker Compose)
#   - VS Code Dev Containers        (via Docker Compose + devcontainer.json)
#   - docker run / docker compose   (directly)
#
# Runtime environment variables (set by compose.yml / devcontainer.json):
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
            /usr/local/bundle /commandhistory /npm-cache /pip-cache \
            "/home/$RUN_USER" 2>/dev/null || true
        chown "$TARGET_UID:$TARGET_GID" /workspace 2>/dev/null || true
    fi
fi

exec gosu "$RUN_USER" "$@"
