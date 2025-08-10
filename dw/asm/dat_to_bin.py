import re
import glob
import os

# Pattern to match $xx hex bytes
hex_pattern = re.compile(r"\$([0-9A-Fa-f]{2})")

for dat_file in glob.glob("*.dat"):
    data = bytearray()
    with open(dat_file, "r", encoding="utf-8") as f:
        for line in f:
            line = line.split(";")[0]  # Remove comments
            # Find all $xx hex tokens
            for tok in hex_pattern.findall(line):
                data.append(int(tok, 16))

    bin_file = os.path.splitext(dat_file)[0] + ".bin"
    with open(bin_file, "wb") as out:
        out.write(data)

    print(f"Converted {dat_file} -> {bin_file} ({len(data)} bytes)")
