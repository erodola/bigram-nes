# 🐉 Bigram NES

[![License](https://img.shields.io/github/license/erodola/bigram-nes?style=flat-square)](./LICENSE)
[![Stars](https://img.shields.io/github/stars/erodola/bigram-nes?style=flat-square)](https://github.com/erodola/bigram-nes/stargazers)
[![Last Commit](https://img.shields.io/github/last-commit/erodola/bigram-nes?style=flat-square)](https://github.com/erodola/bigram-nes/commits/main)
[![Top Language](https://img.shields.io/github/languages/top/erodola/bigram-nes?style=flat-square)](https://github.com/erodola/bigram-nes)
[![Commit Activity](https://img.shields.io/github/commit-activity/y/erodola/bigram-nes?style=flat-square)](https://github.com/erodola/bigram-nes/graphs/contributors)
![Platform](https://img.shields.io/badge/platform-NES-cc0000?style=flat-square)
![CPU](https://img.shields.io/badge/CPU-6502-2c8ebb?style=flat-square)
![Toolchain](https://img.shields.io/badge/toolchain-cc65-00599c?style=flat-square)
![Model](https://img.shields.io/badge/model-char--bigram-3b9c4a?style=flat-square)
![Python](https://img.shields.io/badge/python-3.11-3776ab?style=flat-square)

![gen](./gen.gif) ![demo](./ff1-1.gif) ![demo](./ff1-2.gif)

![demo](./dw-1.gif) ![demo](./dw-2.gif)

This project explores simple bigram-based name generation models running on NES hardware.

The NES only has **2KB RAM** and usually a **128KB ROM** for the code. What AI can we fit in there?

The project includes three subprojects:

- 🍦 [**Vanilla Model**](./vanilla) — a standalone name generator that runs on an NES ROM
- 🧙 [**Final Fantasy: The AI Roster**](./ff1) — a ROM hack that integrates the AI generator in the FF1 name screen
- 🐲 [**Dragon Warrior: NameGen**](./dw) — same for the DW name entry screen (8 characters!)

Each subfolder contains its own README with instructions for building and usage.

Here's a [video](https://youtu.be/pZTwpNlM-Ko) of the romhacks running on real hardware! (courtesy of [@lucentw](https://lucy.gq/))

## ⚙️ Requirements

- [`cc65`](https://cc65.github.io/) toolchain
- An NES emulator (e.g. [FCEUX](http://fceux.com/) or [Mesen](https://www.mesen.ca/))
- Legally owned game ROMs of Final Fantasy 1 and Dragon Warrior (NES), US versions

## 📄 License

This project is licensed under the [MIT License](./LICENSE).

It also includes third-party code used under their respective licenses.  
See [NOTICE](./NOTICE) for attribution and licensing details.
