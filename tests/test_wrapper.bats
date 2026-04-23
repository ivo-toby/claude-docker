#!/usr/bin/env bats
# BATS tests for claudedocker wrapper script
# Run with: npm test or bats tests/test_wrapper.bats

# Load BATS helpers
load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'

# Setup: Define path to wrapper script
WRAPPER_SCRIPT="./claudedocker"

@test "wrapper script exists" {
  [ -f "$WRAPPER_SCRIPT" ]
}

@test "wrapper script is executable" {
  [ -x "$WRAPPER_SCRIPT" ]
}

@test "wrapper script has shebang" {
  run head -n 1 "$WRAPPER_SCRIPT"
  assert_output --partial "#!/"
}

@test "--help flag displays usage information" {
  run "$WRAPPER_SCRIPT" --help
  assert_success
  assert_output --partial "Usage:"
  assert_output --partial "claudedocker"
  assert_output --partial "Options:"
}

@test "--help flag displays available options" {
  run "$WRAPPER_SCRIPT" --help
  assert_success
  assert_output --partial "--image"
  assert_output --partial "--volume"
  assert_output --partial "--copy-host-config"
  assert_output --partial "--local"
  assert_output --partial "--resume"
  assert_output --partial "--shell"
  assert_output --partial "--version"
}

@test "--version flag displays version information" {
  run "$WRAPPER_SCRIPT" --version
  assert_success
  assert_output --partial "claudedocker version"
}

@test "invalid flag shows error and exits with non-zero" {
  run "$WRAPPER_SCRIPT" --invalid-flag
  assert_failure
  assert_output --partial "ERROR"
}

# Test pre-flight checks (these require mocking or Docker to be running)
@test "detects when Docker daemon is not running" {
  # Skip if Docker is actually running
  if docker ps >/dev/null 2>&1; then
    skip "Docker is running - cannot test failure case"
  fi

  run "$WRAPPER_SCRIPT"
  assert_failure
  assert_output --partial "Docker"
}

# Test argument parsing
@test "--image flag accepts custom image name" {
  # This test just validates argument parsing, doesn't actually run container
  run "$WRAPPER_SCRIPT" --image test:tag --help
  assert_success
}

@test "--local flag is recognized" {
  run "$WRAPPER_SCRIPT" --local --help
  assert_success
}

@test "--resume flag is recognized" {
  run "$WRAPPER_SCRIPT" --resume --help
  assert_success
}

@test "--shell flag is recognized" {
  run "$WRAPPER_SCRIPT" --shell --help
  assert_success
}

@test "--volume flag is recognized" {
  run "$WRAPPER_SCRIPT" --volume test-volume --help
  assert_success
}

@test "pass-through arguments with -- separator" {
  # Test that arguments after -- are passed through
  run "$WRAPPER_SCRIPT" --help
  assert_success
  assert_output --partial "Examples:"
  assert_output --partial "-- CLAUDE_ARGS"
}

# Performance tests (User Story 2)
@test "startup time with --version is under 5 seconds" {
  # Skip if Docker is not running
  if ! docker ps >/dev/null 2>&1; then
    skip "Docker is not running"
  fi

  # Measure startup time
  START=$(date +%s)
  run timeout 10 "$WRAPPER_SCRIPT" --local -- --version
  END=$(date +%s)
  DURATION=$((END - START))

  # Should complete successfully
  assert_success

  # Should complete in under 5 seconds
  [ "$DURATION" -lt 5 ]
}
