#!/usr/bin/env bash
# basic-usage.sh - Basic usage examples for claudedocker

set -euo pipefail

echo "=== Basic Usage Examples ==="
echo ""

# Example 1: Simple run
echo "1. Basic run in current directory:"
echo "   claudedocker"
echo ""

# Example 2: Help
echo "2. Show help:"
echo "   claudedocker --help"
echo ""

# Example 3: Version
echo "3. Show version:"
echo "   claudedocker --version"
echo ""

# Example 4: Pass arguments to Claude
echo "4. Pass arguments to Claude Code:"
echo "   claudedocker -- --help"
echo "   claudedocker -- --version"
echo ""

# Example 5: Use local image
echo "5. Use locally built image:"
echo "   ./scripts/build.sh --dev"
echo "   claudedocker --local"
echo ""

# Example 6: First-time setup with host config
echo "6. First-time setup (copy host .claude config):"
echo "   claudedocker --copy-host-config"
echo ""

# Example 7: Custom volume
echo "7. Use custom volume name:"
echo "   claudedocker --volume my-project-claude-config"
echo ""

# Example 8: Custom working directory
echo "8. Override working directory:"
echo "   claudedocker --work-dir /project/src"
echo ""

echo "=== End of Basic Examples ==="
