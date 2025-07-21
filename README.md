# immaculator.nix

Run your vibecoding inside a microvm, to ensure that the vibes are immaculate.

Powered by [microvm.nix](https://github.com/astro/microvm.nix).

**Status**: WIP, still experimenting with ergonomics.

## Goals

- Ergonomic abstraction layer for setting up project environments to run vibecoders like Claude Code, gemini-cli, aider, etc.
- Prioritize minimal setup by default, such as using QEMU's userland network bridging.
- Someday:
    - Support more efficient setups, like easily scaling memory usage by default and using faster containers like firecracker.
    - Support more secure setups, like avoiding a fully accessible network stack.


## License

MIT
