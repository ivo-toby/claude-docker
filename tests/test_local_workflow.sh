#!/usr/bin/env bash
# test_local_workflow.sh - Test local build and run workflow
# Validates: Build script → Local image → claudedocker --local
# This is an integration test for the local development workflow

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

TESTS_PASSED=0
TESTS_FAILED=0

log_info() {
    echo -e "${GREEN}[workflow]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[workflow]${NC} $*"
}

log_error() {
    echo -e "${RED}[workflow]${NC} $*" >&2
}

log_step() {
    echo -e "${BLUE}==>${NC} $*"
}

# Test function
test_workflow() {
    local test_name="$1"
    local test_fn="$2"

    echo -n "Testing: $test_name... "
    if $test_fn; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test 1: Build script exists and is executable
test_build_script_exists() {
    [ -f "$PROJECT_ROOT/scripts/build.sh" ] && [ -x "$PROJECT_ROOT/scripts/build.sh" ]
}

# Test 2: Wrapper script exists and is executable
test_wrapper_script_exists() {
    [ -f "$PROJECT_ROOT/claudedocker" ] && [ -x "$PROJECT_ROOT/claudedocker" ]
}

# Test 3: Can build image with --dev flag
test_build_dev_image() {
    log_info "Building image with --dev flag (this may take a moment)..."
    cd "$PROJECT_ROOT"
    # Build and check exit code
    if ./scripts/build.sh --dev --tag local-test >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Test 4: Built image exists locally
test_built_image_exists() {
    docker image inspect claudedocker:local-test >/dev/null 2>&1
}

# Test 5: Can run wrapper with --local-only flag
test_wrapper_local_only() {
    cd "$PROJECT_ROOT"
    # Use the locally built image
    if ./claudedocker --image claudedocker:local-test --local-only -- --version 2>&1 | grep -q "claude"; then
        return 0
    else
        return 1
    fi
}

# Test 6: Cleanup - remove test image
test_cleanup() {
    docker rmi claudedocker:local-test >/dev/null 2>&1 || true
    return 0
}

# Main
echo "========================================"
echo "  Local Build & Run Workflow Test"
echo "========================================"
echo ""
log_warn "This test will build a Docker image - may take 20-30 seconds"
echo ""

# Temporarily disable exit-on-error for test execution
set +e

test_workflow "Build script exists" test_build_script_exists
test_workflow "Wrapper script exists" test_wrapper_script_exists
test_workflow "Build with --dev flag" test_build_dev_image
test_workflow "Built image exists locally" test_built_image_exists
test_workflow "Run with --local-only" test_wrapper_local_only
test_workflow "Cleanup test image" test_cleanup

# Re-enable exit-on-error
set -e

# Summary
echo ""
echo "========================================"
echo "  Summary"
echo "========================================"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    log_step "✓ Local development workflow is working!"
    echo ""
    echo "You can now:"
    echo "  1. Make changes to Dockerfile"
    echo "  2. Run: ./scripts/build.sh --dev"
    echo "  3. Test: ./claudedocker --local"
    echo ""
    exit 0
else
    log_error "Some tests failed"
    exit 1
fi
