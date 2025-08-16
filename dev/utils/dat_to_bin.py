import re
import glob
import os

# Seek any .dat file in the current directory,
# and convert them to .bin.

# Pattern to match .byte and .word directives
byte_pattern = re.compile(r"\.byte\s+(.*)")
word_pattern = re.compile(r"\.word\s+(.*)")
# Pattern to match $xx hex values (2 or 4 digits)
hex_pattern = re.compile(r"\$([0-9A-Fa-f]{2,4})")

for dat_file in glob.glob("*.dat"):
    data = bytearray()
    with open(dat_file, "r", encoding="utf-8") as f:
        for line in f:
            line = line.split(";")[0].strip()  # Remove comments and whitespace
            
            # Check for .byte directive
            byte_match = byte_pattern.search(line)
            if byte_match:
                byte_data = byte_match.group(1)
                # Find all hex values in the byte data
                for hex_val in hex_pattern.findall(byte_data):
                    data.append(int(hex_val, 16))
            
            # Check for .word directive  
            word_match = word_pattern.search(line)
            if word_match:
                word_data = word_match.group(1)
                # Find hex values in the word data
                for hex_val in hex_pattern.findall(word_data):
                    word_value = int(hex_val, 16)
                    # Write word in little-endian format (low byte first, high byte second)
                    data.append(word_value & 0xFF)        # Low byte
                    data.append((word_value >> 8) & 0xFF) # High byte

    bin_file = os.path.splitext(dat_file)[0] + ".bin"
    with open(bin_file, "wb") as out:
        out.write(data)

    print(f"Converted {dat_file} -> {bin_file} ({len(data)} bytes)")
