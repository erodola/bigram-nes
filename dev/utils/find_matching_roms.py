import hashlib
import os
import sys

def md5sum(filepath):
    hasher = hashlib.md5()
    with open(filepath, 'rb') as f:
        for chunk in iter(lambda: f.read(4096), b''):
            hasher.update(chunk)
    return hasher.hexdigest()

if len(sys.argv) != 3:
    print(f"Usage: {sys.argv[0]} <input_file.nes> <folder_path>")
    sys.exit(1)

input_file = sys.argv[1]
folder_path = sys.argv[2]

target_md5 = md5sum(input_file)

for filename in os.listdir(folder_path):
    if filename.startswith("Dragon Warrior"):
        file_path = os.path.join(folder_path, filename)
        if os.path.isfile(file_path):
            if md5sum(file_path) == target_md5:
                print(filename)
