{
  description = "Custom NixOS Installer ISO with Calamares";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          system = system;
        };
      in {
        packages.install-iso = pkgs.nixosConfigurations.installer.config.system.build.isoImage;

        nixosConfigurations.installer = pkgs.lib.nixosSystem {
          system = system;
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"

            # Add any of your customizations here:
            {
              nixpkgs.config.allowUnfree = true;
              isoImage.isoName = "nixos-custom-installer.iso";
              system.stateVersion = "24.05"; # adjust to your desired version
            }
          ];
        };
      });
}

