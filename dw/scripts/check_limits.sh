#!/bin/bash

# This script parses a linker map file to calculate and report
# the used and remaining space in BANK_01. It extracts the sizes
# of the main bank, inference code, and model parameters, then
# prints a summary including available free space.

map_file="build/map.txt"
max_size=$((0x4000))  # 16 KB
free_bytes=$max_size

# ANSI color codes
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
NC='\033[0m'  # No color

# Function to extract bank size from map file
get_bank_size() {
    local bank_name="$1"
    local hex_size

    hex_size=$(grep -E "${bank_name}[[:space:]].*Size[[:space:]]*=[[:space:]]*[0-9A-Fa-f]+" "$map_file" | \
               sed -E 's/.*Size[[:space:]]*=[[:space:]]*([0-9A-Fa-f]+).*/\1/I' | head -n 1)

    if [[ -n $hex_size ]]; then
        echo $((16#$hex_size))
    else
        echo 0
    fi
}

main_bank="BANK_01"

main_size=$(get_bank_size "$main_bank")
free_bytes=$((free_bytes - main_size))
echo -e "${YELLOW}${main_bank} size:\t${main_size} bytes${NC}"

echo
echo -e "${GREEN}Free space:\t${free_bytes} bytes${NC}"
