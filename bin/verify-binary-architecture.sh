#!/usr/bin/env bash
set -xeuo pipefail

if [ $# -ne 2 ]; then
  echo "Usage: $0 <target-triple> <binary-path>"
  exit 1
fi
TARGET_TRIPLE="$1"
BINARY_PATH="$2"

# Extract and validate target architecture
TARGET_ARCHITECTURE=$(echo "${TARGET_TRIPLE}" | grep -Eo "x86_64|aarch64" || echo "unknown")
if [ "$TARGET_ARCHITECTURE" = "unknown" ]; then
  echo "Unknown target architecture in '${TARGET_TRIPLE}'"
  exit 1
fi

# Parse and normalize binary architecture
normalize_architecture() {
  local architecture="$1"
  case "$architecture" in
    "x86_64"|"x86-64") echo "x86_64" ;;
    "arm64"|"aarch64"|"Aarch64") echo "aarch64" ;;
    *) echo "unknown" ;;
  esac
}
file_output=$(file -b "${BINARY_PATH}")
BINARY_ARCHITECTURE=$(echo "${file_output}" | grep -Eo "x86_64|x86-64|arm64|aarch64|Aarch64" | head -n1)
BINARY_ARCHITECTURE=$(normalize_architecture "$BINARY_ARCHITECTURE")

# Verify that binary architecture matches target architecture
if [ "$BINARY_ARCHITECTURE" != "$TARGET_ARCHITECTURE" ]; then
  echo "Architecture mismatch for '${TARGET_TRIPLE}'"
  echo "Expected: '${TARGET_ARCHITECTURE}'"
  echo "Got: '${BINARY_ARCHITECTURE}'"
  exit 1
fi
