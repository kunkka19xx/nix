{ pkgs, ... }:

{
  imports = [
    ./../../modules/home-manager/default.nix
    ./../../modules/home-manager/alacritty.nix
    ./../../modules/home-manager/firefox.nix
    ./../../modules/home-manager/i3-vm.nix
    ./../../modules/home-manager/zathura.nix
    ./langs.nix
    ./go.nix
  ];
  home.username = "kunkka-vm";
  home.homeDirectory = "/home/kunkka-vm";
  home.stateVersion = "24.05";

  within.neovim.enable = true;
  within.ghostty.enable = true;
  within.zsh.enable = true;
  nixpkgs.config.allowUnfree = true;

  home.packages = [
    pkgs.dmenu
    pkgs.feh
    pkgs.vim
    pkgs.git
    pkgs.nerd-fonts.inconsolata
    pkgs.alacritty
    pkgs.ghostty
    pkgs.rcm
    pkgs.cargo
  ];

  home.file = {
    ".config/rcm/bindings.conf".text = ''
      .txt = ${pkgs.neovim}/bin/nvim
    '';
  };
  home.file.".xprofile".text = ''
    xrandr --output Virtual-1 --scale 0.5x0.5
  '';
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
