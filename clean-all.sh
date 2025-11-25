#!/bin/bash
# redsea-builds clean-all.sh
# Clean all build artifacts

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "[+] Cleaning build artifacts..."

# Clean output directories
rm -rf out/armv6/*
rm -rf out/armhf/*
rm -rf out/arm64/*
rm -rf out/amd64/*

# Clean any temporary build directories
rm -rf build/

echo "[OK] Clean complete"
