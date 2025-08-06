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

Starting with a full game ROM and pre-extracted assets (`bin/` and `dat/`), the `seek_data.sh` script scans the ROM to locate matching data and records their offsets in a file called `offsets`.

To use it, update the paths in `seek_data.sh`, then run the script.

Use `compare_folder.py` to verify that the extracted assets match the pre-extracted `bin/` and `dat/` folders.

### 🙏 Acknowledgments

The C part uses boilerplate code from:
- [Doug Fraker](https://github.com/nesdoug) - [01_Hello example](https://github.com/nesdoug/01_Hello)
- [Shiru](https://shiru.untergrund.net/)
