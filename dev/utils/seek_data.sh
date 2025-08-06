#!/bin/bash

# Seek the given binary assets inside a game ROM,
# and output corresponding offsets and lengths.
#
# Used to produce the offsets file.

BIN_DIR="../../ff1/asm/bin/"
DAT_DIR="../../ff1/asm/dat/"
ROM="ff1.nes"

OUTFILE="offsets"

# Clear the output file
> "$OUTFILE"

# Seek bin & dat offsets
python ./find_binary_offsets.py "$BIN_DIR" "$ROM" >> "$OUTFILE"
python ./find_binary_offsets.py "$DAT_DIR" "$ROM" >> "$OUTFILE"
