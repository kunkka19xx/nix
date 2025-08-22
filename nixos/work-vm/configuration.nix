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
  networking.firewall.allowedTCPPorts = [ 3000 5173 8080 8000 ];
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  services.xserver.enable = true;
  # services.xserver.dpi = 220;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.defaultSession = "none+i3";

  # fix ratio with vm
  services.vmwareGuest.enable = true;
  services.vmwareGuest.headless = false;
  # services.xserver.videoDrivers = ["vmware"];

  services.xserver = {
    xkb.layout = "us,vn";
    xkb = { variant = ""; };
  };

  # transparent i3
  services.picom = {
    enable = true;
    settings = {
      rounded-corners = true;
      corner-radius = 15;
    };
  };

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
      open-vm-tools
    ];
  services.openssh.enable = true;
  security.polkit.enable = true;
  environment.variables = {
    # GDK_SCALE = "1";
    # GDK_DPI_SCALE = "0.44";
    # QDK_FONT_DPI = "220";
    # QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    # QT_SCALE_FACTOR = "0.44";
    XCURSOR_SIZE = "36";
    # CHROME_FLAGS = "--force-device-scale-factor=0.44";
  };
}

