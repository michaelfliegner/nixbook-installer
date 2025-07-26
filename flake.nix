{
  description = "Custom GNOME/Calamares ISO that clones nixbook";

  inputs = {
    nixpkgs      .url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils  .url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # ── 1  Script that does the real work ────────────────────────────────
        cloneScript = pkgs.writeShellScript "clone-nixbook.sh" ''
          set -euo pipefail
          ${pkgs.git}/bin/git clone https://github.com/mkellyxp/nixbook /etc/nixbook
        '';
      in
      {
        packages.install-iso = (
          nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              # Stock Calamares‑GNOME live ISO recipe
              "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"

              # ── 2  Customisation layer ────────────────────────────────────
              ({ lib, pkgs, ... }:
               let
                 upstreamSettings =
                   "${pkgs.calamares-nixos-extensions}/share/calamares/settings.conf";
               in
               {
                 isoImage.isoName    = "nixos-custom-installer.iso";
                 system.stateVersion = "25.05";

                 # flakes + new nix command in live ISO *and* installed system
                 nix.settings.experimental-features = [ "nix-command" "flakes" ];

                 # Git must be available in both environments
                 environment.systemPackages = [ pkgs.git ];

                 # 2a. Drop the shellprocess module description into the ISO
                 environment.etc."calamares/modules/clone-nixbook.conf".text = ''
                   ---
                   id: clone-nixbook
                   type: shellprocess
                   chroot: true            # run inside the target root
                   script:
                     - ${cloneScript}
                 '';

                 # 2b. Patch settings.conf so the module runs just before "finished"
                 environment.etc."calamares/settings.conf".source =
                   pkgs.runCommand "settings.conf" { inherit upstreamSettings; } ''
                     substitute "$upstreamSettings" "$out" \
                       --replace "- finished@finished" \
                                 "- shellprocess@clone-nixbook.conf\n  - finished@finished"
                   '';
               })
            ];
          }
        ).config.system.build.isoImage;
      });
}