{ config
, pkgs
, inputs
, lib
, ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Shell Envs
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  environment.systemPackages = [
    pkgs.docker-compose
    pkgs.lazydocker
    pkgs.tlrc
    pkgs.gnumake
    pkgs.mangohud #games
    pkgs.protonup #games
    pkgs.discord-ptb
    pkgs.droidcam # android phone wbcam client
    pkgs.android-tools
    pkgs.fastfetch
    pkgs.davinci-resolve
    pkgs.tree
    pkgs.flameshot
  ];
  virtualisation.docker.enable = true;
  nixpkgs.config.allowUnfreePredicate = (_: true);
  boot.loader.systemd-boot.configurationLimit = 5;
  # Garbage Collector Setting
  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than 7d";

  # games
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd # davinci-resolve
    ];
  };
  services.xserver.videoDrivers = [ "amdgpu" ];

  # steam & games
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true;
  };
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      "/home/kunkka/.steam/root/compatibilitytools.d";
  }; # run protonup for updating
  # more info here https://nixos.wiki/wiki/Steam

  #obs vtcam
  programs.obs-studio.enableVirtualCamera = true;
  programs.adb.enable = true;
  environment.variables = {
    RUSTICL_ENABLE = "radeonsi";
  };
  # davinci-resolve
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      mesa.opencl # Enables Rusticl (OpenCL) support
    ];
  };
}


