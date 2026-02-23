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
  # services.xserver.dpi = 192; moved to home manager
  # services.xserver.dpi = 220;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.defaultSession = "none+i3";
  # fix ratio with vm
  services.vmwareGuest.enable = true;
  services.vmwareGuest.headless = false;
  # services.xserver.videoDrivers = ["vmware"];
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.displayManager.sessionPackages = [
  #   pkgs.sway
  # ];

  # Vietnamese input
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
      fcitx5-gtk # alternatively, kdePackages.fcitx5-qt
      fcitx5-unikey
    ];
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
  # moved these settings to home-manager kunkka-vm.nix
  # environment.variables = {
  #   GDK_SCALE = "1";
  #   GDK_DPI_SCALE = "0.44";
  #   QT_AUTO_SCREEN_SCALE_FACTOR = "1";
  #   QT_SCALE_FACTOR = "0.44";
  #   XCURSOR_SIZE = "24";
  #   CHROME_FLAGS = "--force-device-scale-factor=0.5";
  # };

}
