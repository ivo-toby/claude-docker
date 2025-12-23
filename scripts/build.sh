#!/usr/bin/env bash
# build.sh - Build script for Claude Code Docker Wrapper
# Supports local builds, version tagging, and multi-platform builds

set -euo pipefail

# Default values
IMAGE_NAME="claudedocker"
TAG="local"
PLATFORMS=""
NO_CACHE=false
DEV_MODE=false
PUSH=false

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[build]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[build]${NC} $*"
}

log_error() {
    echo -e "${RED}[build]${NC} $*" >&2
}

# Show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Build the Claude Code Docker Wrapper image.

Options:
  --tag TAG           Image tag (default: local)
  --platform PLATFORMS Multi-platform build (e.g., linux/amd64,linux/arm64)
  --no-cache          Build without using cache
  --dev               Development build (fast, local only)
  --push              Push image to registry (requires --platform)
  --help              Show this help message

Examples:
  $0                                    # Build local image
  $0 --tag v1.0.0                       # Build with specific tag
  $0 --platform linux/amd64,linux/arm64 # Multi-platform build
  $0 --dev                              # Fast development build
  $0 --tag v1.0.0 --push --platform linux/amd64,linux/arm64  # Build and push

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --tag)
            TAG="$2"
            shift 2
            ;;
        --platform)
            PLATFORMS="$2"
            shift 2
            ;;
        --no-cache)
            NO_CACHE=true
            shift
            ;;
        --dev)
            DEV_MODE=true
            shift
            ;;
        --push)
            PUSH=true
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validation
if [ "$PUSH" = true ] && [ -z "$PLATFORMS" ]; then
    log_error "--push requires --platform to be specified"
    exit 1
fi

# Start build
log_info "Building Claude Code Docker Wrapper"
log_info "Image: $IMAGE_NAME:$TAG"

# Record start time
START_TIME=$(date +%s)

# Determine build command
BUILD_CMD="docker"
BUILD_ARGS=()

if [ -n "$PLATFORMS" ]; then
    # Multi-platform build requires buildx
    log_info "Multi-platform build: $PLATFORMS"
    BUILD_CMD="docker buildx build"
    BUILD_ARGS+=(--platform "$PLATFORMS")

    if [ "$PUSH" = true ]; then
        BUILD_ARGS+=(--push)
        log_warn "Image will be pushed to registry"
    else
        BUILD_ARGS+=(--load)
    fi
else
    BUILD_CMD="docker build"
fi

# Add cache options
if [ "$NO_CACHE" = true ]; then
    BUILD_ARGS+=(--no-cache)
    log_info "Building without cache"
elif [ "$DEV_MODE" = false ] && [ -z "$PLATFORMS" ]; then
    # Use local cache for faster rebuilds (single-platform only)
    BUILD_ARGS+=(--cache-from "$IMAGE_NAME:$TAG")
fi

# Add tag
BUILD_ARGS+=(-t "$IMAGE_NAME:$TAG")

# Add latest tag if not dev mode
if [ "$DEV_MODE" = false ] && [ "$TAG" != "local" ]; then
    BUILD_ARGS+=(-t "$IMAGE_NAME:latest")
fi

# Build
log_info "Running: $BUILD_CMD ${BUILD_ARGS[*]} ."
if eval "$BUILD_CMD ${BUILD_ARGS[*]} ."; then
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))

    log_info "✓ Build completed successfully in ${DURATION}s"
    log_info "Image: $IMAGE_NAME:$TAG"

    # Show image size (if not multi-platform)
    if [ -z "$PLATFORMS" ]; then
        SIZE=$(docker images "$IMAGE_NAME:$TAG" --format "{{.Size}}")
        log_info "Size: $SIZE"
    fi

    exit 0
else
    log_error "Build failed"
    exit 1
fi
