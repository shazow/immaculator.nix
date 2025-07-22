{
  inputs.microvm = {
    url = "github:astro/microvm.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, microvm, ... }: let
    system = "x86_64-linux";
    user = "user";

    defaultMicroVM = {
      hypervisor = "qemu";
      mem = 3072;
      # TODO: Add a version of this for qemu?
      # hotplugMem = 2048; # cloud-hypervisor: Extra memory that can be added if there's memory pressure
      storeOnDisk = true;
      writableStoreOverlay = "/nix/.rw-store";
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

      services.getty.autologinUser = user;
      users.users.${user} = {
        password = "";
        group = "wheel";
        isNormalUser = true;
      };
      security.sudo = {
        enable = true;
        wheelNeedsPassword = false;
      };

      environment.systemPackages = [ pkgs.bindfs ];
      # TODO: Generalize this across shares
      fileSystems."/home/user/src" = {
        device = "/mnt/src";
        fsType = "fuse.bindfs";
        options = [
          "force-user=1000"
          "force-group=100"
          "nofail"
        ];
      };
    };

    mkImmaculate = {
      srcPath ? "./", # Path to mount to $HOME/src
      devShell ? null, # Derivation to include in the environment
      extraPackages ? [],
      extraShares ? [],
      configuration ? defaultConfiguration,
      vm ? defaultMicroVM,
    }: (nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        microvm.nixosModules.microvm
        {
          microvm = vm // {
            shares = [
              # We bindfs this one to $HOME/src with uid=1000
              {
                tag = "src";
                source = srcPath;
                securityModel = "mapped";
                mountPoint = "/mnt/src";
              }
            ] ++ extraShares;
          };
        }
        configuration
        { environment.systemPackages = extraPackages; }
      ] ++ nixpkgs.lib.optional (devShell != null) {
        # Add devShell to the environment if provided
        # mkDerivation documents as buildInputs for runtime dependencies, yet
        # mkShell documents .packages for runtime dependencies and proceeds
        # to merge them into buildNativeInputs instead of buildInputs. So
        # we bring in both. -_-
        environment.systemPackages = devShell.buildInputs ++ devShell.nativeBuildInputs;
        programs.bash.loginShellInit = devShell.shellHook;
      };
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
