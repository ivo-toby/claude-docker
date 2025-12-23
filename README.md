# Claude Code Docker Wrapper

Run [Claude Code CLI](https://github.com/anthropics/claude-code) in an isolated Docker container with full autonomy and persistent authentication.

## Features

- **Isolated Environment**: Run Claude Code in a Docker container, keeping your host system clean
- **Persistent Authentication**: Your Claude subscription credentials are preserved across runs
- **File Access**: Mount your project directory for Claude to read and modify files
- **Cross-Platform**: Works on macOS (Intel & Apple Silicon) and Linux (amd64 & arm64)
- **Fast Startup**: Optimized Docker image with layer caching (<5 second startup)
- **Local Development**: Build and test images locally without CI/CD
- **UID/GID Remapping**: Automatically matches container user to your host user for correct file permissions

## Quick Start

### Prerequisites

- Docker installed and running
- Claude Code subscription or API key

### Installation

```bash
# Clone the repository
git clone https://github.com/username/claudedocker.git
cd claudedocker

# Install the wrapper script
./scripts/install.sh

# Or run directly without installation
./claudedocker
```

### Basic Usage

```bash
# Navigate to your project
cd /path/to/your/project

# Run Claude Code in Docker
claudedocker

# First run: Copy your host ~/.claude config (optional)
claudedocker --copy-host-config

# Subsequent runs: Use persisted authentication
claudedocker --local
```

### Authentication

Claude Code requires authentication. Choose one method:

**Option 1: Subscription Authentication (Recommended)**

```bash
# First run - authenticates through browser
claudedocker

# Follow the OAuth flow in your browser
# Credentials are saved to a Docker volume
```

**Option 2: Copy Host Config**

```bash
# If you already have Claude configured on your host
claudedocker --copy-host-config

# This copies ~/.claude/* to the container volume
# Only needed once
```

**Option 3: API Key**

```bash
# Set your Anthropic API key
export ANTHROPIC_API_KEY="your-api-key"
claudedocker
```

## Usage

### Command Line Options

```bash
Usage: claudedocker [OPTIONS] [-- CLAUDE_ARGS...]

Options:
  --image IMAGE          Docker image to use (default: ghcr.io/ivo-toby/claudedocker:latest)
  --volume NAME          Docker volume name for Claude home directory (default: claudedocker-config)
  --copy-host-config     Copy host ~/.claude config to volume on first run
  --work-dir PATH        Override working directory in container (default: /project)
  --docker-args ARGS     Additional arguments to pass to docker run
  --local                Use locally built image (claudedocker:local)
  --local-only           Use local image only, fail if not found (no registry pull)
  --version              Show version and exit
  --help                 Show this help message

Environment Variables:
  CLAUDEDOCKER_IMAGE     Override default image
  CLAUDEDOCKER_VOLUME    Override default volume name
  ANTHROPIC_API_KEY      Claude API key (if using API key auth)
```

### Examples

```bash
# Basic usage
claudedocker

# Use specific Docker image version
claudedocker --image ghcr.io/ivo-toby/claudedocker:v1.0.0

# Use locally built image
claudedocker --local

# Pass arguments to Claude Code
claudedocker -- --help
claudedocker -- --version

# Expose a port from the container
claudedocker --docker-args "-p 8080:8080"

# Use custom working directory
claudedocker --work-dir /app/src

# Use custom volume name
claudedocker --volume my-claude-config
```

## Local Development

### Building the Image

```bash
# Development build (fast, local only)
./scripts/build.sh --dev

# Production build with version tag
./scripts/build.sh --tag v1.0.0

# Multi-platform build
./scripts/build.sh --platform linux/amd64,linux/arm64

# Build without cache
./scripts/build.sh --no-cache
```

### Testing

```bash
# Run all tests
npm test

# Run specific test suites
./tests/test_wrapper.bats          # Wrapper script tests
./tests/test_workflow.sh           # GitHub Actions workflow validation
./tests/test_build.sh              # Build script tests
./tests/test_local_workflow.sh     # Local build → run workflow
./tests/test_goss.sh               # GOSS runtime tests (requires dgoss)

# Run container structure tests
container-structure-test test --image claudedocker:local --config tests/structure.yaml
```

### Local Build Workflow

```bash
# 1. Make changes to Dockerfile
vim Dockerfile

# 2. Build locally
./scripts/build.sh --dev

# 3. Test with local image
./claudedocker --local

# 4. Run tests
npm test
```

## Architecture

### Container Structure

```
claudedocker:latest
├── Node.js 18 (slim base image)
├── Claude Code CLI (from npm)
├── su-exec (for UID/GID remapping)
├── Custom entrypoint.sh
└── Default user 'claude' (UID 9999, GID 9999)
```

### Volume Mounts

- **Project Directory**: `$(pwd):/project` (read/write)
- **Claude Config**: Docker volume → `/home/claude` (persistent)

### UID/GID Remapping

The entrypoint script automatically remaps the container user to match your host UID/GID, ensuring files created by Claude have the correct ownership.

## CI/CD

The project uses GitHub Actions for automated builds:

- **Triggers**: Push to main, tags (v\*), pull requests
- **Platforms**: linux/amd64, linux/arm64
- **Registry**: GitHub Container Registry (ghcr.io)
- **Tests**: Hadolint, BATS, container-structure-test
- **Caching**: GitHub Actions layer caching for faster builds

### Publishing Images

```bash
# Create a version tag
git tag v1.0.0
git push origin v1.0.0

# GitHub Actions will automatically:
# - Run tests
# - Build multi-platform images
# - Push to ghcr.io/username/claudedocker:v1.0.0
# - Update :latest tag
```

## Troubleshooting

### Docker daemon not running

```
Error: Cannot connect to Docker daemon
→ Start Docker Desktop or run: sudo systemctl start docker
```

### Permission denied errors

```bash
# Make sure you're in a directory you own
cd ~/projects/myproject
claudedocker
```

### Authentication not persisting

```bash
# Use --local flag after first authentication
claudedocker --local

# Or copy host config
claudedocker --copy-host-config
```

### Image not found

```bash
# For local development, build first
./scripts/build.sh --dev
claudedocker --local

# Or use --local-only to prevent registry pull
claudedocker --local-only
```

### File ownership issues

```bash
# Files should have your UID/GID automatically
# If not, check that UID/GID remapping is working:
docker run --rm -it claudedocker:local id
# Should show: uid=<your-uid> gid=<your-gid>
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

## License

MIT License - see LICENSE file for details

## Links

- [Claude Code CLI](https://github.com/anthropics/claude-code)
- [Docker Documentation](https://docs.docker.com/)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)

## Acknowledgments

- Built with [Claude Code CLI](https://github.com/anthropics/claude-code) by Anthropic
- Uses [su-exec](https://github.com/ncopa/su-exec) for user switching
- Inspired by best practices from the Docker community
