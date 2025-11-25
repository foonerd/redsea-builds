# Package Sources

This directory contains the source tarball for redsea.

## Current Source

- **redsea-1.2.0.tar.gz**
  - Version: 1.2.0
  - Release Date: 2025-04-15
  - Source: https://github.com/windytan/redsea/releases/tag/v1.2.0
  - SHA256: (verify after download)

## Updating Source

To update to a newer version:

1. Download the new release tarball from GitHub
2. Replace the tarball in this directory
3. Update the version references in:
   - scripts/build-redsea.sh
   - README.md (root)
   - This file

## Dependencies Built from Source

The build process also clones and builds:

- **liquid-dsp** v1.6.0
  - Source: https://github.com/jgaeddert/liquid-dsp
  - Built as static library for linking

## License

redsea is released under the MIT License.
liquid-dsp is released under the MIT License.
