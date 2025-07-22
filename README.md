# immaculator.nix

Run your vibecoding inside a microvm, to ensure that the vibes are immaculate.

Powered by [microvm.nix](https://github.com/astro/microvm.nix).

**Status**: Unstable, still experimenting with ergonomics.

## Usage

```nix
{
  inputs.immaculator = {
    url = "github:shazow/immaculator.nix";
  };

  outputs = { self, immaculator }: {
    # Run with:
    # $ nix run .
    packages.x86_64-linux.default = immaculator.lib.mkImmaculate {};
  };
}
```

## Goals

- Ergonomic abstraction layer for setting up project environments to run vibecoders like Claude Code, gemini-cli, aider, etc.
- Prioritize minimal setup by default, such as using QEMU's userland network bridging.
- Guest VM should share the host's nix store with a read-only overlay to minimize storage duplication.
- Someday:
    - Support more efficient setups, like easily scaling memory usage by default and using faster containers like firecracker.
    - Support more secure setups, like avoiding a fully accessible network stack.


## License

MIT
