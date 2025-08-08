# 🧙 Final Fantasy: The AI Roster

![demo](../ff1-1.gif) ![demo](../ff1-2.gif)

This ROM hack adds a tiny AI-powered name generator to the **Final Fantasy I (NES)** character naming screen.

The model produces fantasy-style names of 3–4 letters (matching the original game's naming constraints) while compressing a name space of nearly half a million possibilities into a form small enough to run on NES hardware.

## 🧠 Model

The generator is a character-level bigram model (context size = 1), with `uint8`-quantized weights trained offline and embedded in the ROM. All inference runs natively on the NES, written entirely in 6502 assembly.

**Size \& Placement**:

- **Model weights**: 729 bytes
- **Inference code**: 144 bytes
- Stored in **bank 0E** of the ROM.

**Inference.** Name generation is autoregressive and constrained to 3–4 letters (shorter names are rejected at sample time). The 6502 assembly handles all steps (multinomial sampling, token-to-tile mapping, etc.) with careful attention to both CPU cycles and byte footprint.

The inference code is fully commented and stored in [asm/inference.asm](https://github.com/erodola/bigram-nes/blob/main/ff1/asm/inference.asm)

Some original FF1 code in bank 0E was rewritten to make space, preserving full functionality.

**Training.** Re-training isn't required, but if you'd like to experiment (e.g. with Pokémon names), run:

```bash
git clone https://github.com/erodola/bigram-nes.git
cd model
uv venv
uv pip install -r pyproject.toml
uv run train.py
```

This will output quantized weights in the correct format and location.

## 🕹️ In-Game

When starting a new game, you are presented with freshly generated names and random classes.

- Press **B** to generate new ones.
- Press **A** to confirm.

A fresh seed is used on every run to keep results varied.

## 🔧 Building

You can either [download the binary patch from its dedicated page on ROMHacking.net](https://www.romhacking.net/hacks/9080/), or build the patched ROM yourself from the assembly source:

1. **Get a clean FF1 ROM**

   The North American NES release.

   The file's MD5 hash must be either `cd4e3c7b65f3cc45594c5122f2e17fdb` or `d111fc7770e12f67474897aaad834c0c`.

   Equivalently, the ROM-only (no headers) MD5 must be `24ae5edf8375162f91a6846d3202e3d6`.

   Rename the ROM as `ff1.nes`, and place inside the `ff1/` folder.

2. **Install dependencies**

   - [`cc65`](https://cc65.github.io/) toolchain
   - Add the `bin/` folder to `PATH`

3. **Extract game assets**

   This step pulls necessary data from the base ROM into `asm/`.

   Use `extract.sh` (Linux/MacOS) or `extract.bat` (Windows)

4. **Assemble**

   This assembles the ROM with the embedded generator.

   Use `build.sh` Linux/MacOS or `build.bat` (Windows)


The final ROM will be located in the `build/` folder. Run it with your favorite NES emulator.

## 🙏 Credits

Built on top of the excellent, fully commented [FF1 disassembly](https://github.com/Entroper/FF1Disassembly) by Disch.
