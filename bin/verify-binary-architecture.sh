#!/usr/bin/env bash
set -xeuo pipefail

if [ $# -ne 2 ]; then
  echo "Usage: $0 <target-triple> <binary-path>"
  exit 1
fi

TARGET_TRIPLE="$1"
BINARY_PATH="$2"

# Extract target architecture and OS
TARGET_ARCHITECTURE=$(echo "${TARGET_TRIPLE}" | grep -o 'x86_64\|aarch64' || echo "unknown")
TARGET_OS=$(echo "${TARGET_TRIPLE}" | grep -o 'darwin\|linux\|windows' || echo "unknown")

# Validate inputs
if [ "$TARGET_ARCHITECTURE" = "unknown" ]; then
  echo "Unknown target architecture in '${TARGET_TRIPLE}'"
  exit 1
fi
if [ "$TARGET_OS" = "unknown" ]; then
  echo "Unknown target OS in '${TARGET_TRIPLE}'"
  exit 1
fi

# Get expected binary architecture based on target architecture and OS
get_expected_binary_architecture() {
  local target_architecture="$1"
  local target_os="$2"

  case "${target_os}" in
    "darwin")
      case "${target_architecture}" in
        "x86_64") echo "x86_64" ;;
        "aarch64") echo "arm64" ;;
      esac
      ;;
    "linux")
      case "${target_architecture}" in
        "x86_64") echo "x86-64" ;;
        "aarch64") echo "aarch64" ;;
      esac
      ;;
    "windows")
      case "${target_architecture}" in
        "x86_64") echo "X64" ;;
        "aarch64") echo "Aarch64" ;;
      esac
      ;;
  esac
}
EXPECTED_BINARY_ARCHITECTURE=$(get_expected_binary_architecture "$TARGET_ARCHITECTURE" "$TARGET_OS")

# Parse binary architecture
file_output=$(file -b "${BINARY_PATH}")
BINARY_ARCHITECTURE=$(echo "${file_output}" | grep -Eo "x86_64|arm64|x86-64|aarch64|X64|Aarch64" | head -n1 || echo "unknown")

# Verify that binary architecture matches target architecture
if [ "$BINARY_ARCHITECTURE" != "$EXPECTED_BINARY_ARCHITECTURE" ]; then
  echo "Architecture mismatch for '${TARGET_TRIPLE}'"
  echo "Expected: '${EXPECTED_BINARY_ARCHITECTURE}'"
  echo "Got: '${BINARY_ARCHITECTURE}'"
  exit 1
fi
