{ inputs, config, pkgs, lib, ... }:

{
  imports =
    [
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
  # services.xserver.dpi = 144;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.defaultSession = "none+i3";
  # fix ratio with vm
  services.vmwareGuest.enable = true;
  # services.xserver.videoDrivers = ["vmware"];
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.displayManager.sessionPackages = [
  #   pkgs.sway
  # ];

  services.xserver = {
    xkb.layout = "us,vn";
    xkb = { variant = ""; };
  };

  # transparent i3
  services.picom.enable = true;

  users.users.kunkka-vm = {
    isNormalUser = true;
    description = "kunkka-vm";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [

    ];
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs;
    [
      vim
      wget
      tree
      git
      gh
      gcc
      home-manager
    ];
  services.openssh.enable = true;
  security.polkit.enable = true;
  environment.variables = {
    # QDK_SCALE = "1";
    # QDK_FONT_DPI = "144";
    # QT_SCALE_FACTOR = "1";
  };
}

