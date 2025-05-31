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
  users.users.kunkka-vm.packages = lib.mkDefault [
    pkgs.vim
    pkgs.alsa-tools
    pkgs.home-manager
  ];

  # Shell Envs
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  environment.systemPackages = [
    pkgs.zig
    pkgs.docker-compose
    pkgs.lazydocker
    pkgs.tlrc
    pkgs.gnumake
  ];
  virtualisation.docker.enable = true;
  nixpkgs.config.allowUnfreePredicate = (_: true);
  boot.loader.systemd-boot.configurationLimit = 5;
  # Garbage Collector Setting
  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than 7d";
}
