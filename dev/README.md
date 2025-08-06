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

Starting from a full game ROM and pre-extracted game assets contained in `bin` and `dat` folders, the script seeks the assets within the ROM and outputs their offsets in a text file (`offsets`).

Simply edit the paths in `seek_data.sh`, and run the script.

The `compare_folder.py` script is used to compare pre-extracted `bin`/`dat` folders with those extracted during the build pipeline.

### 🙏 Acknowledgments

The C part uses boilerplate code from:
- [Doug Fraker](https://github.com/nesdoug) - [01_Hello example](https://github.com/nesdoug/01_Hello)
- [Shiru](https://shiru.untergrund.net/)
