{
  description = "Custom NixOS Installer ISO with Calamares";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        nixosConfiguration = nixpkgs.lib.nixosSystem {
          system = system;
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"

            {
              nixpkgs.config.allowUnfree = true;
              isoImage.isoName = "nixos-custom-installer.iso";
              system.stateVersion = "24.05";
            }
          ];
        };
      in {
        packages.install-iso = nixosConfiguration.config.system.build.isoImage;
      });
}

