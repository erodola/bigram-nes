def extract_chr_rom(nes_file, output_file):
    with open(nes_file, 'rb') as f:
        header = f.read(16)
        if header[0:4] != b'NES\x1a':
            raise ValueError("Not a valid iNES file")
        
        prg_size = header[4] * 16 * 1024  # PRG ROM size
        chr_size = header[5] * 8 * 1024   # CHR ROM size

        if chr_size == 0:
            raise ValueError("This ROM uses CHR RAM, not CHR ROM")

        # Skip trainer if present (512 bytes)
        has_trainer = header[6] & 0b100
        if has_trainer:
            f.read(512)

        # Skip PRG ROM
        f.read(prg_size)

        # Read CHR ROM
        chr_data = f.read(chr_size)

    with open(output_file, 'wb') as out:
        out.write(chr_data)

    print(f"Extracted {chr_size} bytes to {output_file}")

extract_chr_rom("./dw.nes", "./CHR_ROM.bin")
