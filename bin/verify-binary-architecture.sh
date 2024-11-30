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
parse_and_normalize_architecture() {
  local binary_path="$1"
  local file_output=$(file -b "${binary_path}")
  local binary_architecture=$(echo "$file_output" | grep -Eo "x86_64|x86-64|arm64|aarch64|Aarch64" | head -n1)
  case "$binary_architecture" in
    "x86_64"|"x86-64") echo "x86_64" ;;
    "arm64"|"aarch64"|"Aarch64") echo "aarch64" ;;
    *) echo "unknown" ;;
  esac
}
BINARY_ARCHITECTURE=$(parse_and_normalize_architecture "${BINARY_PATH}")

# Verify that binary architecture matches target architecture
if [ "$BINARY_ARCHITECTURE" != "$TARGET_ARCHITECTURE" ]; then
  echo "Architecture mismatch for '${TARGET_TRIPLE}'"
  echo "Expected: '${TARGET_ARCHITECTURE}'"
  echo "Got: '${BINARY_ARCHITECTURE}'"
  exit 1
fi
