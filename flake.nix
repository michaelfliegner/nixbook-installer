{
  description = "Custom NixOS GNOME Installer ISO";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, flake-utils, nixos-hardware, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        isoConfig = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            # Pass modulesPath to support importing core NixOS modules
            ({ modulesPath, ... }: {
              _module.args.modulesPath = "${nixpkgs}/nixos/modules";
            })

            # Your custom configuration
            ./nixos/configuration.nix

            # Optional: hardware support (e.g. Intel CPU)
            nixos-hardware.nixosModules.common-cpu-intel
          ];
        };
      in {
        packages.iso = isoConfig.config.system.build.isoImage;
      });
}
