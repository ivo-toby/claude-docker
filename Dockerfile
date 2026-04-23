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

# Enable pipefail so pipes in RUN steps fail fast
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install system dependencies tailored for a coding agent experience
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gcc \
        git \
        g++ \
        jq \
        less \
        libc-dev \
        make \
        nano \
        openssh-client \
        patch \
        procps \
        python3 \
        python3-pip \
        sudo \
        unzip \
        wget \
        zip && \
    curl -fsSL "https://github.com/ncopa/su-exec/archive/refs/tags/v${SU_EXEC_VERSION}.tar.gz" | \
    tar -xz && \
    make -C "su-exec-${SU_EXEC_VERSION}" && \
    mv "su-exec-${SU_EXEC_VERSION}/su-exec" /usr/local/bin/ && \
    rm -rf "su-exec-${SU_EXEC_VERSION}" && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI from npm (version controlled via build arg)
RUN npm install -g "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}"

# Copy custom entrypoint script (do this before user creation for better caching)
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Create default user 'claude' (UID 9999, GID 9999) and setup entrypoint
# Entrypoint script will remap this to match host UID/GID at runtime
RUN groupadd -g 9999 claude && \
    useradd -u 9999 -g claude -m -s /bin/bash claude && \
    mkdir -p /home/claude/.claude && \
    chown -R claude:claude /home/claude && \
    chmod +x /usr/local/bin/entrypoint.sh

# Allow the claude user to install additional packages without a password
RUN echo "claude ALL=(ALL) NOPASSWD: /usr/bin/apt-get, /usr/bin/apt, /usr/bin/dpkg" >> /etc/sudoers.d/claude && \
    chmod 0440 /etc/sudoers.d/claude

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
