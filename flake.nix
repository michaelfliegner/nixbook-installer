{
  description = "Custom GNOME/Calamares ISO that clones nixbook";

  inputs = {
    nixpkgs.url     = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # 1. script that does the real work, stored in the Nix store
        cloneScript = pkgs.writeShellScript "clone-nixbook.sh" ''
          set -euo pipefail
          ${pkgs.git}/bin/git clone https://github.com/mkellyxp/nixbook /etc/nixbook
        '';

        isoSystem = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            # Stock graphical installer recipe (provides Calamares + GNOME)
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"

            # --- our tweaks ---------------------------------------------------
            ({ lib, pkgs, ... }: {
              isoImage.isoName   = "nixos-custom-installer.iso";
              system.stateVersion = "25.05";

              nix.settings.experimental-features = [ "nix-command" "flakes" ];

              # Git needs to be present both live and in the installed system
              environment.systemPackages = [ pkgs.git ];

              /* ----------------------------------------------------------------
                 2.  Drop an extra Calamares *module* into the ISO.
                     Calamares scans /etc/calamares/modules at start‑up.
                 ---------------------------------------------------------------- */
              environment.etc."calamares/modules/clone‑nixbook.conf".text = ''
                ---
                id: clone-nixbook
                type: shellprocess
                name: "Clone nixbook repo"
                chroot: true
                timeout: 300
                script:
                  - ${cloneScript}
              '';

              /* ----------------------------------------------------------------
                 3.  Patch Calamares’ settings so the module actually runs.
                     Upstream settings.conf lives in the extension package;
                     we append one line with lib.mkAfter.
                 ---------------------------------------------------------------- */
              environment.etc."calamares/settings.conf".text =
                lib.mkAfter ''
                  - shellprocess@clone‑nixbook.conf
                '';
            })
          ];
        };
      in {
        packages.install-iso = isoSystem.config.system.build.isoImage;
      });
}