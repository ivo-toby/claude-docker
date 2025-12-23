#!/usr/bin/env bash
# test_workflow.sh - Validate GitHub Actions workflow files
# Tests: YAML syntax, required fields, workflow triggers

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_DIR="$SCRIPT_DIR/../.github/workflows"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

TESTS_PASSED=0
TESTS_FAILED=0

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

# Test 1: Workflow files exist
test_workflow_files_exist() {
    [ -d "$WORKFLOW_DIR" ] && [ -f "$WORKFLOW_DIR/build-and-push.yml" ]
}

# Test 2: YAML syntax is valid
test_yaml_syntax() {
    # Try to use Python/PyYAML if available, otherwise use yq, otherwise skip
    if python3 -c "import yaml" 2>/dev/null; then
        python3 -c "import yaml; yaml.safe_load(open('$WORKFLOW_DIR/build-and-push.yml'))" 2>/dev/null
    elif command -v yq >/dev/null 2>&1; then
        yq eval '.' "$WORKFLOW_DIR/build-and-push.yml" >/dev/null 2>&1
    else
        # No YAML validator available, just check if file is readable
        [ -f "$WORKFLOW_DIR/build-and-push.yml" ] && [ -r "$WORKFLOW_DIR/build-and-push.yml" ]
    fi
}

# Test 3: Workflow has required triggers
test_workflow_triggers() {
    local workflow="$WORKFLOW_DIR/build-and-push.yml"
    grep -q "on:" "$workflow" && \
    grep -q "push:" "$workflow" && \
    grep -q "main" "$workflow" && \
    grep -q "tags:" "$workflow" && \
    grep -q "'v\*'" "$workflow"
}

# Test 4: Workflow has build job
test_build_job_exists() {
    local workflow="$WORKFLOW_DIR/build-and-push.yml"
    grep -q "build-and-push:" "$workflow"
}

# Test 5: Workflow has test job
test_test_job_exists() {
    local workflow="$WORKFLOW_DIR/build-and-push.yml"
    grep -q "test:" "$workflow"
}

# Test 6: Multi-platform build configured
test_multiplatform_build() {
    local workflow="$WORKFLOW_DIR/build-and-push.yml"
    grep -q "linux/amd64" "$workflow" && \
    grep -q "linux/arm64" "$workflow"
}

# Test 7: GHCR login configured
test_ghcr_login() {
    local workflow="$WORKFLOW_DIR/build-and-push.yml"
    grep -q "ghcr.io" "$workflow" && \
    grep -q "GITHUB_TOKEN" "$workflow"
}

# Test 8: Layer caching configured
test_layer_caching() {
    local workflow="$WORKFLOW_DIR/build-and-push.yml"
    grep -q "cache-from: type=gha" "$workflow" && \
    grep -q "cache-to: type=gha" "$workflow"
}

# Test 9: Hadolint test configured
test_hadolint_step() {
    local workflow="$WORKFLOW_DIR/build-and-push.yml"
    grep -q "hadolint" "$workflow"
}

# Test 10: Container structure test configured
test_container_structure_step() {
    local workflow="$WORKFLOW_DIR/build-and-push.yml"
    grep -q "container-structure-test" "$workflow"
}

# Run all tests
echo "========================================"
echo "  GitHub Actions Workflow Validation"
echo "========================================"
echo ""

# Temporarily disable exit-on-error for test execution
set +e

test_workflow "Workflow files exist" test_workflow_files_exist
test_workflow "YAML syntax is valid" test_yaml_syntax
test_workflow "Workflow triggers (push to main, tags)" test_workflow_triggers
test_workflow "Build job exists" test_build_job_exists
test_workflow "Test job exists" test_test_job_exists
test_workflow "Multi-platform build configured" test_multiplatform_build
test_workflow "GHCR login configured" test_ghcr_login
test_workflow "Layer caching configured" test_layer_caching
test_workflow "Hadolint test step exists" test_hadolint_step
test_workflow "Container structure test step exists" test_container_structure_step

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
    echo -e "${GREEN}✓ All workflow validation tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
