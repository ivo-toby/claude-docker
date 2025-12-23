#!/bin/sh
# Entrypoint script to remap UID/GID to match host user

set -e

# Get target UID/GID from environment (default to claude's UID/GID if not set)
TARGET_UID="${FIXUID:-9999}"
TARGET_GID="${FIXGID:-9999}"

# Get current claude UID/GID
CURRENT_UID=$(id -u claude)
CURRENT_GID=$(id -g claude)

# Only remap if different
if [ "$CURRENT_UID" != "$TARGET_UID" ] || [ "$CURRENT_GID" != "$TARGET_GID" ]; then
    echo "[entrypoint] Remapping claude user from UID:GID $CURRENT_UID:$CURRENT_GID to $TARGET_UID:$TARGET_GID" >&2

    # Change the claude user's UID
    if [ "$CURRENT_UID" != "$TARGET_UID" ]; then
        usermod -o -u "$TARGET_UID" claude
    fi

    # For GID, we need to find the group with TARGET_GID and add claude to it
    # or change claude's primary group GID if no conflict
    if [ "$CURRENT_GID" != "$TARGET_GID" ]; then
        # Check if a group with TARGET_GID already exists
        EXISTING_GROUP=$(getent group "$TARGET_GID" | cut -d: -f1 || true)

        if [ -n "$EXISTING_GROUP" ]; then
            # Group exists, add claude to it and make it primary
            usermod -g "$TARGET_GID" claude
        else
            # No conflict, change claude group's GID
            groupmod -g "$TARGET_GID" claude
        fi
    fi

    # Note: We do NOT chown /home/claude recursively because it may contain
    # mounted volumes (like ~/Documents) that we should not modify.
    # The mounted ~/.claude directory already has correct ownership from the host.
else
    echo "[entrypoint] UID/GID already correct ($TARGET_UID:$TARGET_GID)" >&2
fi

# Switch to claude user and execute command
# Set HOME to claude's home directory (not the host's)
HOME=/home/claude exec su-exec claude "$@"
