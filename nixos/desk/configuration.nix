{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./custom.nix
    ./input-method.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "amdgpu" ];
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ja_JP.UTF-8";
    LC_IDENTIFICATION = "ja_JP.UTF-8";
    LC_MEASUREMENT = "ja_JP.UTF-8";
    LC_MONETARY = "ja_JP.UTF-8";
    LC_NAME = "ja_JP.UTF-8";
    LC_NUMERIC = "ja_JP.UTF-8";
    LC_PAPER = "ja_JP.UTF-8";
    LC_TELEPHONE = "ja_JP.UTF-8";
    LC_TIME = "ja_JP.UTF-8";
  };
  # 3. Clean up the Graphics warnings (from your earlier log)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva-vdpau-driver # This is the new name for vaapiVdpau
      libvdpau-va-gl
    ];
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Remap Caps Lock to Ctrl at kernel level (works on both X11 and Wayland)
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main = {
        capslock = "leftcontrol";
      };
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kunkka = {
    isNormalUser = true;
    description = "kunkka";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "docker"
      "adbusers"
      "libvirtd" # vm
      "input"
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    gh
    gcc
    home-manager
    pulseaudio
    pipewire
    alsa-tools
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

  services.xserver.enable = true;
  programs.sway = {
    enable = true;
    package = pkgs.swayfx;
    wrapperFeatures.gtk = true;
  };
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;
  services.displayManager.defaultSession = "sway";

  # transparent i3
  # services.picom = {
  #   enable = true;
  #   backend = "glx";
  #   settings = {
  #     rounded-corners = true;
  #     corner-radius = 15;
  #   };
  # };

  security.polkit.enable = true;

  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.ollama = {
    enable = true;
    # Remove the 'acceleration' line entirely
    # Use the rocm-enabled package directly
    package = pkgs.ollama-rocm;
  };

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true; # simple bluetooth gui
  # Automatic System Upgrades
  system.autoUpgrade = {
    enable = true;
    flake = "/home/kunkka/nix#desk"; # Path to your flake and the output name
    flags = [
      "--update-input"
      "nixpkgs"
      "--commit-lock-file" # Automatically commits the flake.lock change to your git repo
    ];
    dates = "weekly"; # Can be "daily", "04:00", etc.
    randomizedDelaySec = "45min";
  };

  # VM windows
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      swtpm.enable = true;
    };
  };

  programs.virt-manager.enable = true;
}
