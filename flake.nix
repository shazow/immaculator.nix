{
  inputs.microvm = {
    url = "github:astro/microvm.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, microvm }: let
    system = "x86_64-linux";

    defaultMicroVM = {
      mem = 1024;
      # TODO: Add a version of this for qemu?
      # hotplugMem = 2048; # cloud-hypervisor: Extra memory that can be added if there's memory pressure
      storeOnDisk = true;
      writableStoreOverlay = "/nix/.rw-store";
      hypervisor = "qemu";
      interfaces = [
        {
          type = "user";
          id = "microvm1";
          mac = "02:00:00:00:00:01";
        }
      ];
    };

    defaultConfiguration = { pkgs, lib, ... }: {
      system.stateVersion = lib.trivial.release;
      nix = {
        package = pkgs.nixVersions.latest;
        settings.experimental-features = [ "nix-command" "flakes" ];
      };
      systemd.network.enable = true;

      services.getty.autologinUser = "root";
    };

    mkImmaculate = {
      devShell ? null, # Derivation to include in the environment
      configuration ? defaultConfiguration,
      vm ? defaultMicroVM,
    }: (nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        microvm.nixosModules.microvm
        { microvm = vm; }
        configuration
        # Add devShell to the environment if provided
        { environment.systemPackages = if devShell != null then [ devShell ] else []; }
      ];
    }).config.microvm.declaredRunner;
  in {
    packages.${system} = {
      default = mkImmaculate {};
    };

    lib = {
      inherit mkImmaculate defaultConfiguration defaultMicroVM;
    };
  };
}
