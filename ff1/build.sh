#!/bin/bash

set -e

echo "==> Starting build process..."

# Optional: uncomment to temporarily add cc65 to path
# export PATH="$PATH:../tools/cc65/bin"

# Create build directory if it doesn't exist
mkdir -p build

echo "==> Assembling code banks..."
banks=("bank_01" "bank_09" "bank_0B" "bank_0C" "bank_0D" "bank_0F" "bank_0E")
for bank in "${banks[@]}"; do
    echo "   - Assembling asm/${bank}.asm"
    ca65 "asm/${bank}.asm"
done

echo "==> Assembling inference modules..."
ca65 asm/inference.asm
ca65 asm/T_matrix.asm

echo "==> Linking..."
ld65 -C asm/nes.cfg \
    asm/bank_01.o asm/bank_09.o asm/bank_0B.o asm/bank_0C.o asm/bank_0D.o \
    asm/bank_0E.o asm/bank_0F.o asm/inference.o asm/T_matrix.o \
    --mapfile build/map.txt

echo "==> Combining binary files into final ROM..."
cat asm/nesheader.bin \
    asm/dat/bank_00.dat \
    bank_01.bin \
    asm/dat/bank_02.dat asm/dat/bank_03.dat asm/dat/bank_04.dat asm/dat/bank_05.dat asm/dat/bank_06.dat \
    asm/dat/bank_07.dat asm/dat/bank_08.dat \
    bank_09.bin \
    asm/dat/bank_0A.dat \
    bank_0B.bin bank_0C.bin bank_0D.bin bank_0E.bin bank_0F.bin \
    > build/FinalFantasy.nes

echo "==> Cleaning up intermediate files..."
rm -f asm/*.o
rm -f bank_*.bin

echo "==> Running size check..."
bash ./scripts/check_limits.sh

echo "==> Build complete."
echo "Output written to: build/FinalFantasy.nes"
