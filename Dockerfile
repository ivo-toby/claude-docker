# Claude Code Docker Wrapper - Optimized for fast startup and cross-platform compatibility
# Base image: node:22-slim (current LTS, reasonable size)
FROM node:22-slim

# Build arguments for version pinning
ARG CLAUDE_CODE_VERSION=latest
ARG SU_EXEC_VERSION=0.2

# Metadata labels
LABEL org.opencontainers.image.title="Claude Code Docker Wrapper" \
      org.opencontainers.image.description="Isolated Docker environment for Claude Code CLI with full autonomy" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.vendor="Claude Docker Wrapper Project" \
      org.opencontainers.image.source="https://github.com/ivo-toby/claude-docker" \
      com.claudedocker.claude-version="${CLAUDE_CODE_VERSION}" \
      com.claudedocker.node-version="22" \
      com.claudedocker.base-image="node:22-slim"

# Install su-exec for runtime user switching (lightweight alternative to gosu)
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates && \
    curl -fsSL https://github.com/ncopa/su-exec/archive/refs/tags/v0.2.tar.gz | \
    tar -xz && \
    cd su-exec-0.2 && \
    apt-get install -y --no-install-recommends gcc libc-dev make && \
    make && \
    mv su-exec /usr/local/bin/ && \
    cd .. && \
    rm -rf su-exec-0.2 && \
    apt-get purge -y gcc libc-dev make && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI from npm
RUN npm install -g @anthropic-ai/claude-code

# Copy custom entrypoint script (do this before user creation for better caching)
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Create default user 'claude' (UID 9999, GID 9999) and setup entrypoint
# Entrypoint script will remap this to match host UID/GID at runtime
RUN groupadd -g 9999 claude && \
    useradd -u 9999 -g claude -m -s /bin/bash claude && \
    mkdir -p /home/claude/.claude && \
    chown -R claude:claude /home/claude && \
    chmod +x /usr/local/bin/entrypoint.sh

# Set working directory
WORKDIR /project

# Set HOME to claude's home directory and Claude config directory
ENV HOME=/home/claude
ENV CLAUDE_CONFIG_DIR=/home/claude/.claude

# Use custom entrypoint script to remap UID/GID and switch to claude user
# NOTE: No USER directive here - entrypoint needs root to modify /etc/passwd
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Default command: launch Claude Code with dangerously-skip-permissions
CMD ["claude", "--dangerously-skip-permissions"]
