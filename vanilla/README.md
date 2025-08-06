# 🍦 Vanilla Model

![gen](./gen.gif)

A minimal name generator showcasing a simple bigram model running natively on the NES.

This lightweight proof of concept isn't optimized, but demonstrates the feasibility of generative logic on NES hardware. More advanced models may be possible; an open area for future exploration!

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
