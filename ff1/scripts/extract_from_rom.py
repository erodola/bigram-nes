import sys
import os

dat_path = "asm/dat"
bin_path = "asm/bin"

def extract_bytes(rom_path, instruction_path):
    # Check file existence
    if not os.path.isfile(rom_path):
        raise FileNotFoundError(f"ROM file not found: {rom_path}")
    if not os.path.isfile(instruction_path):
        raise FileNotFoundError(f"Instruction file not found: {instruction_path}")

    # Read ROM contents
    with open(rom_path, 'rb') as rom_file:
        rom_data = rom_file.read()

    # Ensure output directories exist
    os.makedirs(dat_path, exist_ok=True)
    os.makedirs(bin_path, exist_ok=True)

    # Process each instruction line
    with open(instruction_path, 'r') as f:
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
            subdir = dat_path if filename.lower().endswith(".dat") else bin_path

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
