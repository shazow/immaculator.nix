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
