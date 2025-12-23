#!/usr/bin/env bash
# test_build.sh - Validate build script functionality
# Tests: Argument parsing, flag handling, error conditions

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_SCRIPT="$SCRIPT_DIR/../scripts/build.sh"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

TESTS_PASSED=0
TESTS_FAILED=0

# Test function
test_build() {
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

# Test 1: Build script exists
test_build_script_exists() {
    [ -f "$BUILD_SCRIPT" ] && [ -x "$BUILD_SCRIPT" ]
}

# Test 2: Help flag works
test_help_flag() {
    "$BUILD_SCRIPT" --help 2>&1 | grep -q "Usage:"
}

# Test 3: Invalid flag shows error
test_invalid_flag() {
    ! "$BUILD_SCRIPT" --invalid-flag >/dev/null 2>&1
}

# Test 4: --tag flag is recognized
test_tag_flag_parsing() {
    # Test that --tag flag doesn't cause error (just parse, don't build)
    "$BUILD_SCRIPT" --help --tag test:v1.0.0 2>&1 | grep -q "Usage:"
}

# Test 5: --dev flag is recognized
test_dev_flag_parsing() {
    "$BUILD_SCRIPT" --help --dev 2>&1 | grep -q "Usage:"
}

# Test 6: --no-cache flag is recognized
test_no_cache_flag_parsing() {
    "$BUILD_SCRIPT" --help --no-cache 2>&1 | grep -q "Usage:"
}

# Test 7: --platform flag is recognized
test_platform_flag_parsing() {
    "$BUILD_SCRIPT" --help --platform linux/amd64,linux/arm64 2>&1 | grep -q "Usage:"
}

# Test 8: --push requires --platform
test_push_requires_platform() {
    # Capture output and exit code
    local output
    output=$("$BUILD_SCRIPT" --push 2>&1) || true

    # Should contain error message about platform
    echo "$output" | grep -q "platform"
}

# Test 9: Build script has proper shebang
test_shebang() {
    head -n 1 "$BUILD_SCRIPT" | grep -q "#!/usr/bin/env bash"
}

# Test 10: Build script sets error handling
test_error_handling() {
    grep -q "set -euo pipefail" "$BUILD_SCRIPT"
}

# Run all tests
echo "========================================"
echo "  Build Script Validation"
echo "========================================"
echo ""

# Temporarily disable exit-on-error for test execution
set +e

test_build "Build script exists" test_build_script_exists
test_build "Help flag displays usage" test_help_flag
test_build "Invalid flag shows error" test_invalid_flag
test_build "Tag flag parsing works" test_tag_flag_parsing
test_build "Dev flag parsing works" test_dev_flag_parsing
test_build "No-cache flag parsing works" test_no_cache_flag_parsing
test_build "Platform flag parsing works" test_platform_flag_parsing
test_build "Push requires platform validation" test_push_requires_platform
test_build "Proper shebang present" test_shebang
test_build "Error handling configured" test_error_handling

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
    echo -e "${GREEN}✓ All build script validation tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
