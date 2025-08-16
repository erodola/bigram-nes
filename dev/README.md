# ✍️ Development Notes

Development code that is **not** part of the final production pipeline.

This code is preserved in the repo to simplify future development. However, it is **not actively maintained** and may become outdated over time.

Currently includes:

## 1. Early-stage C code as a starting point for the ROM hack (./src and ./lib)

The name generation logic is implemented in `src/gen.c`, and is compiled to 6502 assembly as part of the development workflow.

The `cc65` toolchain must be installed and available in your system's PATH.

Use the appropriate build script for your platform:

- Windows: `build.bat`
- Linux/macOS: `build.sh`

## 2. Scripts to generate offsets for the asset extraction step (./utils)

Starting with a full game ROM and pre-extracted assets (`bin/`, `dat/`, etc.), the `seek_data_*.sh` scripts scan the ROM to locate matching data, and record their offsets in files named `offsets_*`.

To use them, update the paths in `seek_data_*.sh`, then run the scripts.

Use `compare_folder.py` to verify that the extracted assets match the original binaries.

### 🙏 Acknowledgments

The C part uses boilerplate code from:
- [Doug Fraker](https://github.com/nesdoug) - [01_Hello example](https://github.com/nesdoug/01_Hello)
- [Shiru](https://shiru.untergrund.net/)
