{ pkgs, ... }:

{
  imports = [
    ./../../modules/home-manager/default.nix
    ./../../modules/home-manager/alacritty.nix
    ./../../modules/home-manager/firefox.nix
    ./../../modules/home-manager/i3.nix
    ./../../modules/home-manager/zathura.nix
    ./../../modules/home-manager/qute.nix
    ./../../modules/home-manager/obs.nix
    ./langs.nix
  ];
  home.username = "kunkka";
  home.homeDirectory = "/home/kunkka";
  home.stateVersion = "25.05";

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
    pkgs.qutebrowser
    pkgs.jq
  ];

  home.file = {
    ".config/rcm/bindings.conf".text = ''
      .txt = ${pkgs.neovim}/bin/nvim
    '';
  };
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
