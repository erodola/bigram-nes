#!/bin/bash

set -euo pipefail

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
reset=$(tput sgr0)

printf "\n${magenta}Deleting previous build files...${reset}\n"
rm -rf build
mkdir -p build

printf "\n${magenta}Assembling with ca65...${reset}\n\n"

# Header (should emit exactly 16 bytes from $0000)
ca65 -o build/Header.o asm/Header.asm
ld65 -C asm/header.cfg -o build/Header.bin build/Header.o

# PRG banks
ca65 -o build/Bank00.o asm/Bank00.asm
ca65 -o build/Bank01.o asm/Bank01.asm
ca65 -o build/Bank02.o asm/Bank02.asm
ca65 -o build/Bank03.o asm/Bank03.asm

ld65 -C asm/prg_bank.cfg -o build/Bank00.bin build/Bank00.o
ld65 -C asm/prg_bank.cfg -o build/Bank01.bin build/Bank01.o
ld65 -C asm/prg_bank.cfg -o build/Bank02.bin build/Bank02.o
ld65 -C asm/prg_bank.cfg -o build/Bank03.bin build/Bank03.o

# ------------------------------------------------------------------------------
# Combine into final .nes:
#   - Header.bin (16 bytes produced by ld65)
#   - Four 16KB PRG banks
#   - CHR ROM binary (existing)
# ------------------------------------------------------------------------------
printf "${magenta}Combining Assembled banks into a ROM...${reset}\n"
cat build/Header.bin \
    build/Bank00.bin \
    build/Bank01.bin \
    build/Bank02.bin \
    build/Bank03.bin \
    asm/bin/CHR_ROM.bin \
    > build/DragonWarrior.nes

printf "${magenta}Cleaning up intermediate files......${reset}\n"	
#rm -f build/*.o
#rm -f build/*.bin

printf "\n${magenta}Verifying final ROM checksum...${reset}\n\n"
final_md5=($(md5sum build/DragonWarrior.nes))
expected_md5="1cfeeac7a20b405780eea318d3d1af2a"
printf "Assembled ROM md5sum = $final_md5\n"
printf "Expected  ROM md5sum = $expected_md5\n"
if [ "$final_md5" = "$expected_md5" ]; then
    printf "${green}Final ROM checksum matches!${reset}\n\n"
else
    printf "${red}Final ROM checksum mismatch!${reset}\n\n"
fi

printf "${green}Build complete.${reset}\n"
printf "Output written to: build/DragonWarrior.nes\n"