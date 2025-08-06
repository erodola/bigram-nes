# 🐉 Bigram NES

![gen](./gen.gif)

This project explores simple bigram-based name generation models running on NES hardware.

The NES only has **2KB of RAM** and a **128KB ROM** for the code. What can we fit in there?

The project includes two subprojects:

- 🍦 [**Vanilla Model**](./vanilla) — a standalone name generator that runs on an NES ROM
- 🧙 [**Final Fantasy I Hack**](./ff1) — a ROM hack that integrates the generator in the FF1 name screen

Each subfolder contains its own README with instructions for building and usage.

## ⚙️ Requirements

- [`cc65`](https://cc65.github.io/) toolchain
- An NES emulator (e.g. [FCEUX](http://fceux.com/) or [Mesen](https://www.mesen.ca/))
- A legally owned game ROM of Final Fantasy 1 (NES), US version

The MD5 hash of the ROM file should be `d111fc7770e12f67474897aaad834c0c`.

## 🙏 Acknowledgments

The project wouldn't have been possible without the fully commented FF1 disassembly by [Michael Bennett](https://github.com/Entroper/FF1Disassembly/)

## 📄 License

This project is licensed under the [MIT License](./LICENSE).

It also includes third-party code used under their respective licenses.  
See [NOTICE](./NOTICE) for attribution and licensing details.
