#!/usr/bin/env bash
# test_goss.sh - Run GOSS runtime tests on Docker image
# Tests container runtime configuration using GOSS

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
IMAGE="${1:-claudedocker:local}"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[goss]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[goss]${NC} $*"
}

log_error() {
    echo -e "${RED}[goss]${NC} $*" >&2
}

log_step() {
    echo -e "${BLUE}==>${NC} $*"
}

# Show usage
show_usage() {
    cat << EOF
Usage: $0 [IMAGE]

Run GOSS runtime tests on a Docker image.

Arguments:
  IMAGE              Docker image to test (default: claudedocker:local)

Examples:
  $0                          # Test claudedocker:local
  $0 claudedocker:v1.0.0      # Test specific version

Requirements:
  - Docker installed and running
  - dgoss installed (https://github.com/aelsabbahy/goss)
    Install with: curl -L https://goss.rocks/install | sudo sh

EOF
}

# Check if dgoss is installed
check_dgoss_installed() {
    if ! command -v dgoss >/dev/null 2>&1; then
        log_error "dgoss is not installed"
        echo ""
        echo "Install dgoss with:"
        echo "  curl -L https://goss.rocks/install | sudo sh"
        echo ""
        echo "Or on macOS with Homebrew:"
        echo "  brew install goss"
        echo "  brew install dgoss"
        echo ""
        return 1
    fi
    log_info "dgoss found: $(command -v dgoss)"
    return 0
}

# Check if image exists
check_image_exists() {
    if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
        log_error "Docker image not found: $IMAGE"
        echo "  → Build the image first with: ./scripts/build.sh"
        return 1
    fi
    log_info "Image found: $IMAGE"
    return 0
}

# Parse arguments
if [[ "${1:-}" == "--help" ]]; then
    show_usage
    exit 0
fi

# Main
log_step "Running GOSS runtime tests"
echo ""

# Pre-flight checks
check_dgoss_installed || exit $?
check_image_exists || exit $?

# Run dgoss tests
log_info "Running dgoss with goss.yaml..."
cd "$SCRIPT_DIR"

# Set GOSS_FILES_STRATEGY to allow missing files (for optimization checks)
export GOSS_FILES_STRATEGY=cp

if GOSS_SLEEP=1 dgoss run "$IMAGE"; then
    echo ""
    log_step "✓ All GOSS runtime tests passed!"
    exit 0
else
    echo ""
    log_error "Some GOSS tests failed"
    exit 1
fi
