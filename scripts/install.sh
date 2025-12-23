#!/usr/bin/env bash
# install.sh - Install claudedocker wrapper script to system
# Copies claudedocker to /usr/local/bin for global access

set -euo pipefail

# Default installation directory
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WRAPPER_SCRIPT="$PROJECT_ROOT/claudedocker"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[install]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[install]${NC} $*"
}

log_error() {
    echo -e "${RED}[install]${NC} $*" >&2
}

log_step() {
    echo -e "${BLUE}==>${NC} $*"
}

# Show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Install the claudedocker wrapper script to your system.

Options:
  --dir DIR           Installation directory (default: /usr/local/bin)
  --uninstall         Uninstall claudedocker
  --help              Show this help message

Examples:
  $0                          # Install to /usr/local/bin
  $0 --dir ~/.local/bin       # Install to user directory
  $0 --uninstall              # Remove installed script

Notes:
  - Installing to /usr/local/bin requires sudo
  - Make sure the installation directory is in your PATH
  - After installation, run 'claudedocker --help' to verify

EOF
}

# Check if installation directory is writable
check_install_dir() {
    if [ ! -d "$INSTALL_DIR" ]; then
        log_error "Installation directory does not exist: $INSTALL_DIR"
        log_info "Create it with: mkdir -p $INSTALL_DIR"
        exit 1
    fi

    if [ ! -w "$INSTALL_DIR" ]; then
        log_error "Installation directory is not writable: $INSTALL_DIR"
        log_info "Try running with sudo or choose a user-writable directory"
        exit 1
    fi
}

# Install the wrapper script
install_wrapper() {
    log_step "Installing claudedocker wrapper script"

    if [ ! -f "$WRAPPER_SCRIPT" ]; then
        log_error "Wrapper script not found: $WRAPPER_SCRIPT"
        log_info "Run this script from the project root or scripts/ directory"
        exit 1
    fi

    check_install_dir

    local target="$INSTALL_DIR/claudedocker"

    # Check if already installed
    if [ -f "$target" ]; then
        log_warn "claudedocker is already installed at $target"
        echo -n "Overwrite? [y/N] "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled"
            exit 0
        fi
    fi

    # Copy and set permissions
    log_info "Copying $WRAPPER_SCRIPT → $target"
    cp "$WRAPPER_SCRIPT" "$target"
    chmod +x "$target"

    log_info "✓ Installation complete!"
    echo ""
    log_step "Verify installation:"
    echo "  claudedocker --version"
    echo ""
    log_step "Get started:"
    echo "  cd /path/to/your/project"
    echo "  claudedocker"
}

# Uninstall the wrapper script
uninstall_wrapper() {
    log_step "Uninstalling claudedocker wrapper script"

    check_install_dir

    local target="$INSTALL_DIR/claudedocker"

    if [ ! -f "$target" ]; then
        log_error "claudedocker is not installed at $target"
        exit 1
    fi

    echo -n "Remove $target? [y/N] "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        log_info "Uninstall cancelled"
        exit 0
    fi

    rm "$target"
    log_info "✓ Uninstalled successfully"
}

# Parse arguments
UNINSTALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        --uninstall)
            UNINSTALL=true
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

# Main
if [ "$UNINSTALL" = true ]; then
    uninstall_wrapper
else
    install_wrapper
fi
