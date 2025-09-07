import sys
import os

paths = ["asm/bin", "asm/bin/Bank00", "asm/bin/Bank01", "asm/bin/Bank02", "asm/bin/Bank03"]
offsets_suf = ["_chr", "_00", "_01", "_02", "_03"]

def extract_bytes(rom_path, instruction_path):
    
    # Check file existence
    if not os.path.isfile(rom_path):
        raise FileNotFoundError(f"ROM file not found: {rom_path}")
    
    for suf in offsets_suf:
        fname = instruction_path + suf        
        if not os.path.isfile(fname):
            raise FileNotFoundError(f"Instruction file not found: {fname}")

    # Read ROM contents
    with open(rom_path, 'rb') as rom_file:
        rom_data = rom_file.read()

    # Ensure output directories exist
    for p in paths:
        os.makedirs(p, exist_ok=True)
    
    for idx, suf in enumerate(offsets_suf):
        
        in_fname = instruction_path + suf

        # Process each instruction line
        with open(in_fname, 'r') as f:
            for line_num, line in enumerate(f, 1):
                line = line.strip()
                if not line or line.startswith('#'):
                    continue  # skip empty or commented lines

                parts = line.split()
                if len(parts) != 3:
                    print(f"Skipping invalid line {line_num}: {line}")
                    continue
                
                filename, offset_str, length_str = parts

                try:
                    offset = int(offset_str)
                    length = int(length_str)
                except ValueError:
                    print(f"Skipping line {line_num} due to invalid numbers: {line}")
                    continue

                end = offset + length
                if offset < 0 or end > len(rom_data):
                    print(f"Skipping line {line_num}: out-of-bounds read (offset {offset}, length {length})")
                    continue

                # Determine output path
                subdir = paths[idx]

                out_path = os.path.join(subdir, filename)

                # Extract and write data
                data = rom_data[offset:end]
                with open(out_path, 'wb') as out_file:
                    out_file.write(data)
                print(".", end='')
                # print(f"Wrote {length} bytes to '{out_path}' (offset {offset}, 0x{offset:X})")
            print('')

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python extract_from_rom.py <rom_file> <offsets>")
        sys.exit(1)

    rom_path = sys.argv[1]
    instruction_path = sys.argv[2]

    try:
        extract_bytes(rom_path, instruction_path)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
