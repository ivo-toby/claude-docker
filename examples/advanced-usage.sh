#!/usr/bin/env bash
# advanced-usage.sh - Advanced usage examples for claudedocker

set -euo pipefail

echo "=== Advanced Usage Examples ==="
echo ""

# Example 1: Custom Docker network
echo "1. Use custom Docker network:"
echo "   docker network create my-network"
echo "   claudedocker --docker-args \"--network my-network\""
echo ""

# Example 2: Expose ports
echo "2. Expose ports from container:"
echo "   claudedocker --docker-args \"-p 8080:8080 -p 3000:3000\""
echo ""

# Example 3: Mount additional volumes
echo "3. Mount additional volumes:"
echo "   claudedocker --docker-args \"-v /path/to/data:/data:ro\""
echo ""

# Example 4: Set environment variables
echo "4. Set environment variables:"
echo "   claudedocker --docker-args \"-e MY_VAR=value -e DEBUG=true\""
echo ""

# Example 5: Use specific image version
echo "5. Use specific Docker image version:"
echo "   claudedocker --image ghcr.io/username/claudedocker:v1.0.0"
echo ""

# Example 6: Local-only mode (no registry pull)
echo "6. Force local image only (fail if not found):"
echo "   claudedocker --local-only"
echo ""

# Example 7: Multiple Docker args
echo "7. Combine multiple Docker arguments:"
echo "   claudedocker --docker-args \"-p 8080:8080 --memory 4g --cpus 2\""
echo ""

# Example 8: Environment variables for claudedocker
echo "8. Use environment variables:"
echo "   export CLAUDEDOCKER_IMAGE=my-custom-image:latest"
echo "   export CLAUDEDOCKER_VOLUME=my-volume"
echo "   claudedocker"
echo ""

# Example 9: API key authentication
echo "9. Use API key instead of subscription:"
echo "   export ANTHROPIC_API_KEY=your-api-key"
echo "   claudedocker"
echo ""

echo "=== End of Advanced Examples ==="
