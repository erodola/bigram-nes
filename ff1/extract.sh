#!/bin/bash

ROM="ff1.nes"

set -e

echo "==> Checking hash..."
md5sum -c ff1.md5

echo ""

echo "==> Extracting game assets..."
python scripts/extract_from_rom.py "$ROM" scripts/offsets

echo "done."

echo ""
echo "You can now run the build.sh script."
