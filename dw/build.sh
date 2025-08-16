#!/bin/bash

set -euo pipefail

namegen=true

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
reset=$(tput sgr0)

# Check for required subfolders
if [ ! -d "asm/bin" ]; then
    echo "ERROR: asm/bin/ folder not found."
    echo "You should run extract.sh before running the build."
    exit 1
fi

NAMEGEN_DEFINE=()
if [ "$namegen" = true ]; then
    NAMEGEN_DEFINE=(-D namegen)
fi

printf "\n${magenta}Deleting previous build files...${reset}\n"
rm -rf build
mkdir -p build

printf "\n${magenta}Assembling with ca65...${reset}\n"

# Header (should emit exactly 16 bytes from $0000)
ca65 -o build/Header.o asm/Header.asm

# PRG banks
ca65 -o build/Bank00.o asm/Bank00.asm
ca65 -o build/Bank01.o asm/Bank01.asm "${NAMEGEN_DEFINE[@]}"
ca65 -o build/Bank02.o asm/Bank02.asm
ca65 -o build/Bank03.o asm/Bank03.asm "${NAMEGEN_DEFINE[@]}"

ld65 -C asm/nes.cfg \
    build/Header.o \
    build/Bank00.o build/Bank01.o build/Bank02.o build/Bank03.o \
    --mapfile build/map.txt

# ------------------------------------------------------------------------------
# Combine into final .nes:
#   - Header.bin (16 bytes produced by ld65)
#   - Four 16KB PRG banks
#   - CHR ROM binary (existing)
# ------------------------------------------------------------------------------
printf "\n${magenta}Combining Assembled banks into a ROM...${reset}\n"
cat build/Header.bin \
    build/Bank00.bin \
    build/Bank01.bin \
    build/Bank02.bin \
    build/Bank03.bin \
    asm/bin/CHR_ROM.bin \
    > build/DragonWarrior.nes

printf "\n${magenta}Cleaning up intermediate files......${reset}\n"	
rm -f build/*.o
rm -f build/*.bin

# MD5 check only when namegen is disabled
if [ "$namegen" = false ]; then
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
fi

printf "\n"
bash ./scripts/check_limits.sh

printf "\nBuild complete.\n"
printf "${green}Output written to: build/DragonWarrior.nes${reset}\n"