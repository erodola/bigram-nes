#!/bin/bash

ROM="dw.nes"

set -e

echo "==> Checking hash..."
md5sum -c dw.md5

echo ""

echo "==> Extracting game assets..."
python scripts/extract_from_rom.py "$ROM" scripts/offsets

echo "done."

echo ""
echo "You can now run the build.sh script."
