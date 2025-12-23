#!/usr/bin/env bash
# local-development.sh - Local development workflow examples

set -euo pipefail

echo "=== Local Development Workflow ==="
echo ""

echo "Scenario: You want to modify the Dockerfile and test locally"
echo ""

# Step 1
echo "Step 1: Make changes to Dockerfile"
echo "   vim Dockerfile"
echo "   # (make your changes)"
echo ""

# Step 2
echo "Step 2: Build locally with development flag"
echo "   ./scripts/build.sh --dev"
echo "   # Fast build without pushing to registry"
echo ""

# Step 3
echo "Step 3: Test with local image"
echo "   cd ~/my-project"
echo "   claudedocker --local -- --version"
echo ""

# Step 4
echo "Step 4: Run tests"
echo "   npm test"
echo "   ./tests/test_local_workflow.sh"
echo ""

# Step 5
echo "Step 5: If tests pass, build production image"
echo "   ./scripts/build.sh --tag v1.1.0"
echo ""

echo "---"
echo ""

echo "Scenario: Testing without Docker registry access"
echo ""

# Step 1
echo "Step 1: Build image locally"
echo "   ./scripts/build.sh --dev"
echo ""

# Step 2
echo "Step 2: Use --local-only to prevent registry pulls"
echo "   claudedocker --local-only"
echo "   # Will fail if local image doesn't exist"
echo ""

echo "---"
echo ""

echo "Scenario: Contributing to the project"
echo ""

# Step 1
echo "Step 1: Fork and clone the repository"
echo "   git clone https://github.com/YOUR-USERNAME/claudedocker.git"
echo "   cd claudedocker"
echo ""

# Step 2
echo "Step 2: Install dependencies"
echo "   npm install"
echo ""

# Step 3
echo "Step 3: Make your changes"
echo "   # Edit files..."
echo ""

# Step 4
echo "Step 4: Run tests"
echo "   npm test"
echo "   ./tests/test_wrapper.bats"
echo "   ./tests/test_build.sh"
echo ""

# Step 5
echo "Step 5: Lint your code"
echo "   shellcheck claudedocker scripts/*.sh"
echo "   hadolint Dockerfile"
echo ""

# Step 6
echo "Step 6: Test local build workflow"
echo "   ./tests/test_local_workflow.sh"
echo ""

# Step 7
echo "Step 7: Commit and push"
echo "   git add ."
echo "   git commit -m \"feat: your feature description\""
echo "   git push origin feature/your-feature"
echo ""

# Step 8
echo "Step 8: Create pull request on GitHub"
echo ""

echo "=== End of Local Development Examples ==="
