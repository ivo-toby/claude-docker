# Claude Docker Examples

This directory contains example scripts demonstrating various use cases for the Claude Code Docker Wrapper.

## Examples

### [basic-usage.sh](basic-usage.sh)
Common everyday usage patterns:
- Basic run in current directory
- Show help and version
- Pass arguments to Claude Code
- Use local images
- First-time setup
- Custom volumes and working directories

**Run it:**
```bash
bash examples/basic-usage.sh
```

### [advanced-usage.sh](advanced-usage.sh)
Advanced configuration and integration:
- Custom Docker networks
- Port exposure
- Additional volume mounts
- Environment variables
- Specific image versions
- Local-only mode
- API key authentication

**Run it:**
```bash
bash examples/advanced-usage.sh
```

### [local-development.sh](local-development.sh)
Development workflows:
- Modifying and testing Dockerfiles locally
- Testing without registry access
- Contributing to the project
- Running tests and linters

**Run it:**
```bash
bash examples/local-development.sh
```

## Usage

These example scripts demonstrate commands - they don't execute them. They're meant to be:

1. **Read** - to learn about available options
2. **Copied** - to use as templates
3. **Modified** - to fit your specific needs

To actually execute the commands, copy-paste them from the script output or modify the scripts to remove the `echo` commands.

## Quick Reference

| Use Case | Command |
|----------|---------|
| Basic run | `claudedocker` |
| Show help | `claudedocker --help` |
| Use local image | `claudedocker --local` |
| Copy host config | `claudedocker --copy-host-config` |
| Pass args to Claude | `claudedocker -- --help` |
| Expose port | `claudedocker --docker-args "-p 8080:8080"` |
| Custom network | `claudedocker --docker-args "--network my-net"` |
| Local-only mode | `claudedocker --local-only` |
| Build locally | `./scripts/build.sh --dev` |
| Install globally | `./scripts/install.sh` |

## More Information

See the main [README.md](../README.md) for comprehensive documentation.
