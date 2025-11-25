#!/bin/bash
# redsea-builds build-matrix.sh
# Build fn-redsea binary for all architectures

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

VERBOSE=""

# Parse arguments
for arg in "$@"; do
  if [[ "$arg" == "--verbose" ]]; then
    VERBOSE="--verbose"
  fi
done

echo "========================================"
echo "fn-redsea Build Matrix"
echo "========================================"
echo "Source: redsea 1.2.0"
echo ""

# Check source tarball exists
if [ ! -f "package-sources/redsea-1.2.0.tar.gz" ]; then
  echo "Error: package-sources/redsea-1.2.0.tar.gz not found"
  exit 1
fi

# Build for all architectures
ARCHITECTURES=("armv6" "armhf" "arm64" "amd64")

for ARCH in "${ARCHITECTURES[@]}"; do
  echo ""
  echo "----------------------------------------"
  echo "Building for: $ARCH"
  echo "----------------------------------------"
  ./docker/run-docker-redsea.sh "$ARCH" $VERBOSE
done

echo ""
echo "========================================"
echo "Build Matrix Complete"
echo "========================================"
echo ""
echo "Output structure:"
for ARCH in "${ARCHITECTURES[@]}"; do
  if [ -d "out/$ARCH" ]; then
    echo "  out/$ARCH/"
    ls -lh "out/$ARCH/" 2>/dev/null | tail -n +2 | awk '{printf "    %-20s %s\n", $9, $5}'
  fi
done

echo ""
echo "Binary: fn-redsea"
