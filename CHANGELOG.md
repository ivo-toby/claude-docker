# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of Claude Code Docker Wrapper
- Docker container with Claude Code CLI pre-installed
- Wrapper script (`claudedocker`) for easy container management
- Persistent authentication via Docker volumes
- UID/GID remapping for correct file permissions
- Build automation script with multi-platform support
- Install script for system-wide installation
- Comprehensive test suite (BATS, GOSS, container-structure-test)
- GitHub Actions CI/CD pipeline
- Multi-platform support (linux/amd64, linux/arm64)
- GitHub Container Registry publishing
- Local development workflow support
- Documentation (README, CONTRIBUTING)

### Features

#### Container
- Node.js 18 slim base image
- Claude Code CLI from npm
- su-exec for runtime user switching
- Custom entrypoint with UID/GID remapping
- Optimized layer caching (13 layers, 572MB)
- Fast startup time (<5 seconds)

#### Wrapper Script
- `--image` flag for custom Docker images
- `--volume` flag for custom volume names
- `--copy-host-config` to import host .claude config
- `--work-dir` flag for custom working directory
- `--docker-args` for additional Docker run arguments
- `--local` flag to use locally built images
- `--local-only` flag to prevent registry pulls
- `--version` and `--help` flags
- Pass-through arguments with `--` separator
- Environment variable support (CLAUDEDOCKER_IMAGE, CLAUDEDOCKER_VOLUME)
- Pre-flight checks (Docker running, directory readable)
- Colored logging output

#### Build System
- Build script with `--dev`, `--tag`, `--platform`, `--no-cache`, `--push` flags
- Install script with `--dir` and `--uninstall` options
- Multi-platform builds with Docker Buildx
- Layer caching support

#### Testing
- BATS tests for wrapper script functionality
- Workflow validation tests for GitHub Actions
- Build script tests
- Local workflow integration tests
- GOSS runtime tests for container validation
- Container structure tests
- Hadolint Dockerfile linting

#### CI/CD
- GitHub Actions workflow for automated builds
- Test job (Hadolint, BATS, container-structure-test)
- Build-and-push job (multi-platform, GHCR)
- GitHub Actions layer caching
- Automated version tagging
- Pull request validation

## [1.0.0] - TBD

### Initial Release

First stable release of Claude Code Docker Wrapper with full feature set.

---

## Version History Template

## [X.Y.Z] - YYYY-MM-DD

### Added
- New features

### Changed
- Changes to existing functionality

### Deprecated
- Features that will be removed in future versions

### Removed
- Removed features

### Fixed
- Bug fixes

### Security
- Security improvements

[Unreleased]: https://github.com/username/claudedocker/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/username/claudedocker/releases/tag/v1.0.0
