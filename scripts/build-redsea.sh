#!/bin/bash
# redsea-builds scripts/build-redsea.sh
# Build script for fn-redsea binary (runs inside Docker container)

set -e

echo "[+] Starting fn-redsea build"
echo "[+] Architecture: $ARCH"
echo "[+] Library path: $LIB_PATH"
echo "[+] Extra CFLAGS: $EXTRA_CFLAGS"
echo "[+] Extra CXXFLAGS: $EXTRA_CXXFLAGS"
echo ""

# Directories
BUILD_BASE="/build"
SOURCE_DIR="$BUILD_BASE/source"
LIQUID_BUILD="$BUILD_BASE/liquid-dsp"
REDSEA_BUILD="$BUILD_BASE/redsea-build"
OUTPUT_DIR="$BUILD_BASE/output"

mkdir -p "$SOURCE_DIR"
mkdir -p "$LIQUID_BUILD"
mkdir -p "$REDSEA_BUILD"
mkdir -p "$OUTPUT_DIR"

#
# Step 1: Build liquid-dsp from source (static library)
#
echo "[+] Building liquid-dsp from source..."

cd "$LIQUID_BUILD"

# Clone liquid-dsp (stable release)
LIQUID_VERSION="v1.6.0"
if [ ! -d "liquid-dsp" ]; then
  git clone --depth 1 --branch "$LIQUID_VERSION" https://github.com/jgaeddert/liquid-dsp.git
fi

cd liquid-dsp

# Configure with static library support
./bootstrap.sh

# Apply architecture-specific flags
if [ -n "$EXTRA_CFLAGS" ]; then
  export CFLAGS="$EXTRA_CFLAGS -fPIC"
fi

./configure --prefix=/usr/local --enable-static --disable-shared

# Build and install
make -j$(nproc)
make install

# Create pkg-config file for liquid-dsp (not provided by upstream)
mkdir -p /usr/local/lib/pkgconfig
cat > /usr/local/lib/pkgconfig/liquid.pc << 'EOF'
prefix=/usr/local
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include

Name: liquid
Description: liquid-dsp signal processing library
Version: 1.6.0
Libs: -L${libdir} -lliquid -lm
Cflags: -I${includedir}
EOF

# Update library cache
ldconfig /usr/local/lib

# Add to ld.so.conf for runtime
echo "/usr/local/lib" > /etc/ld.so.conf.d/local.conf
ldconfig

# Verify installation
echo "[+] liquid-dsp installed:"
ls -la /usr/local/lib/libliquid*
echo "[+] pkg-config check:"
pkg-config --modversion liquid
pkg-config --libs liquid
pkg-config --cflags liquid

#
# Step 2: Extract redsea source
#
echo ""
echo "[+] Extracting redsea source..."

cd "$SOURCE_DIR"
tar -xzf /build/package-sources/redsea-1.2.0.tar.gz
cd redsea-1.2.0

echo "[+] Source version: $(grep "version:" meson.build | head -1)"

#
# Step 3: Build redsea with meson
#
echo ""
echo "[+] Building redsea..."

# Set up environment for static linking
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"
export LIBRARY_PATH="/usr/local/lib:$LIBRARY_PATH"
export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
export LDFLAGS="-L/usr/local/lib -static-libgcc -static-libstdc++"
export CXXFLAGS="$EXTRA_CXXFLAGS -I/usr/local/include"
export CFLAGS="$EXTRA_CFLAGS -I/usr/local/include"

# Create meson build directory
cd "$REDSEA_BUILD"

# Configure with meson
# Note: --prefer-static tells meson to prefer static libraries when available
meson setup \
  --prefix=/usr/local \
  --buildtype=release \
  --prefer-static \
  -Dbuild_tests=false \
  "$SOURCE_DIR/redsea-1.2.0"

# Build
meson compile

# Show build result
echo "[+] Build output:"
ls -la redsea

# Verify linkage
echo "[+] Binary linkage:"
file redsea
ldd redsea || echo "(static binary or minimal dependencies)"

#
# Step 4: Strip and install
#
echo ""
echo "[+] Stripping binary..."
strip redsea

echo "[+] Final binary:"
ls -lh redsea

# Rename and copy to output
cp redsea "$OUTPUT_DIR/fn-redsea"

echo ""
echo "[+] Build complete: fn-redsea"
ls -lh "$OUTPUT_DIR/fn-redsea"

# Test binary
echo ""
echo "[+] Testing binary..."
"$OUTPUT_DIR/fn-redsea" --version || echo "(version check)"
