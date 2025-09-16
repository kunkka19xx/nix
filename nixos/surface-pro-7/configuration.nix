{ inputs, config, pkgs, lib, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./custom.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  services.iptsd.enable = lib.mkDefault true;

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.displayManager.sessionPackages = [
    pkgs.sway
  ];
  # services.xserver.windowManager.i3.enable = true;
  # services.xserver.displayManager.lightdm.enable = true;
  # services.xserver.displayManager.lightdm.autoLogin.enable = false;

  services.xserver = {
    xkb.layout = "us,vn";
    # xkbOptions = "ctrl:nocaps";
    xkb = { variant = ""; };
  };
  # Vietnamese input
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
      fcitx5-gtk # alternatively, kdePackages.fcitx5-qt
      fcitx5-unikey
    ];
  };


  # Enable CUPS to print documents.
  services.printing.enable = true;
  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  # sway home manager needs
  security.polkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kunkka07xx = {
    isNormalUser = true;
    description = "kunkka07xx";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      #  thunderbird 
    ];
  };

  # Install firefox.
  # programs.firefox.enable = true; -> home manager
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
    [
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      git
      gh
      gcc
      home-manager
      pipewire
      pulseaudio
      brightnessctl
      surface-control
    ];
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  /* services.interception-tools =
    let
    itools = pkgs.interception-tools;
    itools-caps = pkgs.interception-tools-plugins.caps3esc;
    in
    {
    enable = true;
    plugins = [ itools-caps ];
    # requires explicit paths: https://github.com/NixOS/nixpkgs/issues/126682
    udevmonConfig = pkgs.lib.mkDefault ''
    - JOB: "${itools}/bin/intercept -g $DEVNODE | ${itools-caps}/bin/caps2esc -m 1 | ${itools}/bin/uinput -d $DEVNODE"
    DEVICE:
    EVENTS:
    EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
    '';
    }; */
  system.stateVersion = "24.11";

}
