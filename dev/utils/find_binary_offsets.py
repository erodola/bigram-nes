import sys
import os

def find_all_offsets(source_data, target_data):
    offsets = []
    start = 0
    while True:
        index = target_data.find(source_data, start)
        if index == -1:
            break
        offsets.append(index)
        start = index + 1  # allows overlapping matches
    return offsets

def search_snippets_in_rom(snippets_folder, rom_path):
    if not os.path.isdir(snippets_folder):
        raise ValueError(f"'{snippets_folder}' is not a valid folder.")
    if not os.path.isfile(rom_path):
        raise FileNotFoundError(f"ROM file '{rom_path}' not found.")

    try:
        with open(rom_path, 'rb') as f:
            rom_data = f.read()
    except Exception as e:
        raise RuntimeError(f"Failed to read ROM: {e}")

    for root, _, files in os.walk(snippets_folder):
        for file in sorted(files):
            snippet_path = os.path.join(root, file)
            try:
                with open(snippet_path, 'rb') as sf:
                    snippet_data = sf.read()

                offsets = find_all_offsets(snippet_data, rom_data)

                if len(offsets) != 1:
                    print(f"WARNING: {file} {len(offsets)} matches found (expected exactly 1)", file=sys.stderr)

                offset = offsets[0]
                print(f"{file} {offset} {len(snippet_data)}")

            except Exception as e:
                print(f"Error: {e}", file=sys.stderr)
                sys.exit(1)

def print_usage():
    print("Usage:")
    print("  python find_binary_offsets.py <snippets_folder> <rom_file>")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print_usage()
        sys.exit(1)

    snippets_folder = sys.argv[1]
    rom_file = sys.argv[2]

    try:
        search_snippets_in_rom(snippets_folder, rom_file)
    except Exception as e:
        print(f"Fatal error: {e}", file=sys.stderr)
        sys.exit(1)
