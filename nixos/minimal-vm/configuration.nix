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
  services.xserver = {
    xkb.layout = "us,vn";
    xkb = { variant = ""; };
  };

  users.users.kunkka-vm = {
    isNormalUser = true;
    description = "kunkka-vm";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [

    ];
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs;
    [
      vim
      wget
      git
      gh
      gcc
      home-manager
    ];
  services.openssh.enable = true;
  security.polkit.enable = true;
}
