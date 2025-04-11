{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-graphical-gnome.nix")
  ];

  isoImage.isoName = lib.mkForce "custom-gnome-installer.iso";

  environment.systemPackages = with pkgs; [
    firefox
    helix
    gparted
    calamares
  ];

  # 🧷 Include Calamares configuration files
  environment.etc."calamares/settings.conf".source = ./calamares/settings.conf;
  environment.etc."calamares/modules/welcome.conf".source = ./calamares/modules/welcome.conf;
  environment.etc."calamares/modules/locale.conf".source = ./calamares/modules/locale.conf;
  environment.etc."calamares/modules/keyboard.conf".source = ./calamares/modules/keyboard.conf;
  environment.etc."calamares/modules/partition.conf".source = ./calamares/modules/partition.conf;
  environment.etc."calamares/modules/users.conf".source = ./calamares/modules/users.conf;
  environment.etc."calamares/modules/summary.conf".source = ./calamares/modules/summary.conf;
  environment.etc."calamares/modules/install.conf".source = ./calamares/modules/install.conf;
  environment.etc."calamares/modules/finished.conf".source = ./calamares/modules/finished.conf;

  # Optional autostart Calamares on GNOME login
  environment.etc."xdg/autostart/calamares.desktop".text = ''
    [Desktop Entry]
    Name=Calamares Installer
    Exec=calamares -D /etc/calamares
    Type=Application
    X-GNOME-Autostart-enabled=true
  '';

  # User and login setup
  services.xserver.displayManager.gdm.autoLogin.enable = true;
  services.xserver.displayManager.gdm.autoLogin.user = "nixos";

  users.users.nixos = {
    isNormalUser = true;
    password = "nixos";
    extraGroups = [ "wheel" ];
  };

  networking.hostName = "gnome-installer";
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
}
