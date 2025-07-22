{
  inputs = {
    immaculator = {
      url = "github:shazow/immaculator.nix";
    };
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
  };

  outputs = { immaculator, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
    in rec {
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.gemini-cli
          pkgs.git
        ];
      };
 
      # Run with:
      # $ nix run .#microvm
      packages.microvm = immaculator.lib.mkImmaculate {
        devShell = devShells.default;

        srcPath = "../../";

        extraShares = [
          {
            proto = "9p";
            tag = "gemini-config";
            source = "/home/shazow/.gemini";
            mountPoint = "/root/.gemini";
          }
          # TODO: Add ~/.config/git/config share and other things?
        ];
      };
    }
  );
}
