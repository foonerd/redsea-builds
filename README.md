# redsea-builds

Docker-based cross-compilation system for building fn-redsea (RDS decoder) binaries
for multiple architectures.

## Overview

This repository builds statically-linked fn-redsea binaries from the
[redsea](https://github.com/windytan/redsea) project by Oona Raisanen.

The fn-redsea binary decodes RDS (Radio Data System) data from FM radio signals
and outputs JSON metadata including station names, song titles, and artist information.

## Output Binary

- **fn-redsea**: RDS decoder with JSON output

The `fn-` prefix distinguishes these builds from any system-installed versions.

## Supported Architectures

| Architecture | Platform | Target Hardware |
|--------------|----------|-----------------|
| armv6 | linux/arm/v7 | Raspberry Pi Zero, Pi 1 |
| armhf | linux/arm/v7 | Raspberry Pi 2, Pi 3 (32-bit) |
| arm64 | linux/arm64 | Raspberry Pi 3/4/5 (64-bit) |
| amd64 | linux/amd64 | x86-64 PC |

## Prerequisites

- Docker with BuildKit support
- QEMU for cross-architecture builds (usually included with Docker Desktop)

### Enable QEMU on Linux

```bash
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

## Building

### Build All Architectures

```bash
./build-matrix.sh
```

### Build Single Architecture

```bash
./docker/run-docker-redsea.sh <arch>
```

Where `<arch>` is one of: armv6, armhf, arm64, amd64

### Verbose Output

```bash
./build-matrix.sh --verbose
./docker/run-docker-redsea.sh arm64 --verbose
```

## Output

Binaries are placed in `out/<arch>/`:

```
out/
  armv6/fn-redsea
  armhf/fn-redsea
  arm64/fn-redsea
  amd64/fn-redsea
```

## Clean Build

```bash
./clean-all.sh
```

## Source

The source tarball is stored in `package-sources/`:

- redsea-1.2.0.tar.gz (from https://github.com/windytan/redsea/releases)

## Dependencies Built

The build process compiles liquid-dsp from source and links statically to minimize
runtime dependencies. The resulting binary requires only:

- glibc (libc6)
- libm (math library)

## Usage Example

```bash
# Decode RDS from FM radio using rtl_fm
fn-rtl_fm -M fm -l 0 -A std -p 0 -s 171k -g 20 -F 9 -f 87.9M | fn-redsea -r 171k

# Output (JSON):
# {"pi":"0xC204","group":"0A","ps":"BBC R2  ","prog_type":"Pop Music",...}
```

## Integration with Volumio RTL-SDR Plugin

These binaries are designed for use with the Volumio RTL-SDR Radio plugin to
provide FM radio metadata (station names, now playing information).

## Version

- redsea version: 1.2.0
- Build system version: 1.0.0

## License

This build system is released under the MIT License.
The original redsea project is also MIT licensed.

## Credits

- redsea by Oona Raisanen (windytan): https://github.com/windytan/redsea
- liquid-dsp by Joseph Gaeddert: https://github.com/jgaeddert/liquid-dsp
