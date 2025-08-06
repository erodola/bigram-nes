#!/bin/bash

set -e

NAME="gen"

# Uncomment the line below to temporarily add cc65 to the system path
# export PATH="$PATH:../../tools/cc65/bin"

# Ensure required tools are available
command -v cc65 >/dev/null 2>&1 || { echo >&2 "cc65 is not installed or not in PATH."; exit 1; }
command -v ca65 >/dev/null 2>&1 || { echo >&2 "ca65 is not installed or not in PATH."; exit 1; }
command -v ld65 >/dev/null 2>&1 || { echo >&2 "ld65 is not installed or not in PATH."; exit 1; }

# Compile C to assembly
cc65 -Oirs "src/${NAME}.c" --add-source

# Assemble
ca65 "lib/crt0.s"
ca65 "src/${NAME}.s" -g

# Link
ld65 -C "src/nrom_32k_vert.cfg" -o "${NAME}.nes" lib/crt0.o "src/${NAME}.o" nes.lib -Ln labels.txt

# Cleanup object files
rm -f lib/*.o src/*.o

# Create build directory if it doesn't exist
mkdir -p build

# Move build artifacts
mv -f labels.txt "build/"
mv -f "src/${NAME}.s" "build/"
mv -f "${NAME}.nes" "build/"

echo "Build complete. Output files are in the build/ directory."
