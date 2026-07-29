{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./custom.nix
  ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "kunkka-vm";
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.defaultSession = "none+i3";
  # Resolution / DPI is owned by home-manager:
  #   users/kunkka-vm/kunkka-vm.nix -> .xprofile -> pick-resolution.sh
  services.vmwareGuest.enable = true;
  services.vmwareGuest.headless = false;

  # Vietnamese input
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      # Use the engine from qt6Packages
      addons = with pkgs; [
        fcitx5-gtk # Specifically keep this for Brave/Firefox
        qt6Packages.fcitx5-unikey
      ];
      waylandFrontend = false;
    };
  };

  services.xserver = {
    xkb.layout = "us,vn";
    xkb = {
      variant = "";
    };
  };

  users.users.kunkka-vm = {
    isNormalUser = true;
    description = "kunkka-vm";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    vim
    wget
    tree
    git
    gh
    gcc
    home-manager
    open-vm-tools
  ];
  services.openssh.enable = true;
  security.polkit.enable = true;
}
