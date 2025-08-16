#!/bin/bash

# Seek the given binary assets inside a game ROM,
# and output corresponding offsets and lengths.
#
# Used to produce the offsets files.

# WARNING: do CHR separately because the script looks inside all subfolders

CHR_DIR="../../dw/asm/bin/"
BANK00_DIR="../../dw/asm/bin/Bank00/"
BANK01_DIR="../../dw/asm/bin/Bank01/"
BANK02_DIR="../../dw/asm/bin/Bank02/"
BANK03_DIR="../../dw/asm/bin/Bank03/"
ROM="dw.nes"

CHR_OUTFILE="offsets_dw_chr"
BANK00_OUTFILE="offsets_dw_00"
BANK01_OUTFILE="offsets_dw_01"
BANK02_OUTFILE="offsets_dw_02"
BANK03_OUTFILE="offsets_dw_03"

# Clear the output files
> "$CHR_OUTFILE"
> "$BANK00_OUTFILE"
> "$BANK01_OUTFILE"
> "$BANK02_OUTFILE"
> "$BANK03_OUTFILE"

# Seek bin offsets
python ./find_binary_offsets.py "$CHR_DIR" "$ROM" >> "$CHR_OUTFILE"
python ./find_binary_offsets.py "$BANK00_DIR" "$ROM" >> "$BANK00_OUTFILE"
python ./find_binary_offsets.py "$BANK01_DIR" "$ROM" >> "$BANK01_OUTFILE"
python ./find_binary_offsets.py "$BANK02_DIR" "$ROM" >> "$BANK02_OUTFILE"
python ./find_binary_offsets.py "$BANK03_DIR" "$ROM" >> "$BANK03_OUTFILE"
