# Contributing to Claude Code Docker Wrapper

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Testing](#testing)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

This project follows a standard code of conduct:

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on constructive feedback
- Assume good intentions

## Getting Started

### Prerequisites

- Docker 20.10+
- Bash 4.0+ or Zsh 5.0+
- Node.js 18+ (for testing)
- Git

### Optional Tools

- `hadolint` - Dockerfile linter
- `shellcheck` - Shell script linter
- `dgoss` - Docker GOSS testing
- `container-structure-test` - Container validation

### Fork and Clone

```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/YOUR-USERNAME/claudedocker.git
cd claudedocker

# Add upstream remote
git remote add upstream https://github.com/username/claudedocker.git
```

### Install Dependencies

```bash
# Install npm test dependencies
npm install

# Install linters (optional)
brew install hadolint shellcheck  # macOS
# Or use Docker versions (see Dockerfile)
```

## Development Workflow

### 1. Create a Branch

```bash
# Update main
git checkout main
git pull upstream main

# Create feature branch
git checkout -b feature/your-feature-name
# Or for bug fixes
git checkout -b fix/bug-description
```

### 2. Make Changes

Follow the project structure:

```
claudedocker/
├── Dockerfile              # Container definition
├── entrypoint.sh           # Container entrypoint
├── claudedocker            # Main wrapper script
├── scripts/
│   ├── build.sh            # Build automation
│   └── install.sh          # Installation script
├── tests/
│   ├── test_wrapper.bats   # Wrapper tests
│   ├── test_workflow.sh    # CI/CD tests
│   ├── test_build.sh       # Build script tests
│   ├── test_local_workflow.sh  # Integration tests
│   ├── test_goss.sh        # Runtime tests
│   ├── goss.yaml           # GOSS test spec
│   └── structure.yaml      # Container structure tests
└── .github/workflows/
    └── build-and-push.yml  # GitHub Actions
```

### 3. Test Your Changes

```bash
# Run all tests
npm test

# Test specific components
./tests/test_wrapper.bats
./tests/test_build.sh
./tests/test_local_workflow.sh

# Test local build
./scripts/build.sh --dev
./claudedocker --local -- --version

# Lint Dockerfile
hadolint Dockerfile

# Lint shell scripts
shellcheck claudedocker scripts/*.sh tests/*.sh
```

### 4. Commit Your Changes

```bash
# Stage changes
git add .

# Commit with descriptive message
git commit -m "feat: add support for custom network configuration"

# See Commit Guidelines below for message format
```

### 5. Push and Create PR

```bash
# Push to your fork
git push origin feature/your-feature-name

# Create pull request on GitHub
# Fill out the PR template with description and test results
```

## Testing

### Running Tests

```bash
# All tests
npm test

# Individual test suites
npm run test:wrapper        # BATS wrapper tests
npm run test:workflow       # Workflow validation
npm run test:build          # Build script tests

# Manual tests
./tests/test_local_workflow.sh
./tests/test_goss.sh
```

### Writing Tests

#### Wrapper Script Tests (BATS)

```bash
# tests/test_wrapper.bats
@test "wrapper script exists" {
  [ -f "./claudedocker" ]
}

@test "help flag displays usage" {
  run ./claudedocker --help
  assert_success
  assert_output --partial "Usage:"
}
```

#### Validation Tests (Bash)

```bash
# tests/test_*.sh
test_something() {
    if some_command; then
        return 0  # Pass
    else
        return 1  # Fail
    fi
}
```

### Test Coverage

Aim for:
- All new flags/options have tests
- Error conditions are tested
- Integration workflow is validated

## Coding Standards

### Shell Scripts

- **POSIX Compatible**: Use Bash 4.0+ features, avoid Bash 5.0+ only features
- **Set Strict Mode**: Always use `set -euo pipefail`
- **Quote Variables**: Always quote: `"$variable"` not `$variable`
- **Use Functions**: Break complex logic into functions
- **Error Handling**: Check exit codes and provide helpful error messages
- **Shellcheck Clean**: Code must pass `shellcheck` with no warnings

Example:
```bash
#!/usr/bin/env bash
set -euo pipefail

my_function() {
    local arg="$1"

    if [ -z "$arg" ]; then
        echo "Error: argument required" >&2
        return 1
    fi

    echo "Processing: $arg"
}
```

### Dockerfile

- **Hadolint Clean**: Must pass `hadolint` with no warnings
- **Layer Optimization**: Minimize layers, combine RUN commands
- **Cache-Friendly**: Order commands from least to most frequently changed
- **Clean Up**: Remove apt cache, build dependencies
- **Pin Versions**: Use specific versions for critical dependencies

Example:
```dockerfile
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        package1=version1 \
        package2=version2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

### Documentation

- **README**: Update for new features
- **Code Comments**: Explain "why", not "what"
- **Examples**: Add usage examples for new flags
- **Help Text**: Update `--help` output

## Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style (formatting, no logic change)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Build process, dependencies, etc.

### Examples

```bash
feat(wrapper): add --network flag for custom Docker networks

Allows users to specify a Docker network for the container.

Closes #42
```

```bash
fix(entrypoint): correct UID remapping for groups

The previous implementation didn't handle existing groups correctly.
Now checks if target GID exists before modifying.

Fixes #38
```

```bash
docs(readme): add troubleshooting section for auth issues

Users were confused about authentication persistence.
Added clear examples and explanation.
```

## Pull Request Process

### Before Submitting

- [ ] Tests pass (`npm test`)
- [ ] Code is shellcheck clean
- [ ] Dockerfile is hadolint clean
- [ ] Documentation is updated
- [ ] Commit messages follow guidelines
- [ ] Branch is up to date with main

### PR Template

When creating a PR, include:

1. **Description**: What does this PR do?
2. **Motivation**: Why is this change needed?
3. **Testing**: How did you test this?
4. **Screenshots**: (if applicable)
5. **Breaking Changes**: (if any)

### Review Process

1. Automated checks must pass (CI/CD)
2. At least one maintainer approval required
3. Address review feedback
4. Squash commits if requested
5. Maintainer will merge

### After Merge

- Delete your feature branch
- Update your fork's main branch
- Celebrate! 🎉

## Release Process

Maintainers follow semantic versioning:

- **Major** (1.0.0): Breaking changes
- **Minor** (0.1.0): New features, backwards compatible
- **Patch** (0.0.1): Bug fixes

## Getting Help

- **Issues**: Search existing issues first
- **Discussions**: Ask questions in GitHub Discussions
- **Documentation**: Check README.md and docs/

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md (if created)
- Mentioned in release notes
- Credited in commit co-author tags

Thank you for contributing! 🙏
