# 🍦 Vanilla Model

![gen](./gen.gif)

This is a minimal name generator designed to demonstrate the capabilities of a simple bigram-based model running natively on the NES.

This version is intended as a lightweight proof of concept. The code is not optimized, and serves primarily to validate the feasibility of running generative logic on NES hardware.

While this implementation is minimal, it's likely that larger and more capable models could also be made to run on the NES; this remains an open area for future exploration.

## 🛠️ Building

The name generation logic is implemented in C (`src/gen.c`) and compiled to 6502 assembly using the `cc65` toolchain. You'll need `cc65` installed and available in your system's `PATH`.

Use the appropriate build script for your platform:

- Windows: `build.bat`
- Linux/macOS: `build.sh`

The scripts generate assembly output and a runnable `.nes` ROM image.

### 🙏 Acknowledgments

This project uses boilerplate code from:
- [Doug Fraker](https://github.com/nesdoug) - [01_Hello example](https://github.com/nesdoug/01_Hello)
- [Shiru](https://shiru.untergrund.net/)
