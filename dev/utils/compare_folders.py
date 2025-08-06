'''
Compare byte-per-byte the binary files contained in two
folders given as input. Same filenames are compared.

Used to check whether the asset extraction utility
does its job.
'''

import sys
import os

def compare_files(file1, file2):
    with open(file1, 'rb') as f1, open(file2, 'rb') as f2:
        return f1.read() == f2.read()

def compare_matching_files(folder1, folder2):
    files1 = set(os.listdir(folder1))
    files2 = set(os.listdir(folder2))

    common_files = sorted(files1 & files2)

    for filename in common_files:
        path1 = os.path.join(folder1, filename)
        path2 = os.path.join(folder2, filename)

        if not (os.path.isfile(path1) and os.path.isfile(path2)):
            continue  # skip subdirectories or non-files

        if compare_files(path1, path2):
            print(f"OK {filename}")
        else:
            print(f"FAIL {filename}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python compare_folders.py <folder1> <folder2>")
        sys.exit(1)

    folder1 = sys.argv[1]
    folder2 = sys.argv[2]

    if not os.path.isdir(folder1) or not os.path.isdir(folder2):
        print("Error: Both arguments must be valid directories.")
        sys.exit(1)

    compare_matching_files(folder1, folder2)
