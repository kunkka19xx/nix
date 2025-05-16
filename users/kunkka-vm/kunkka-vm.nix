{ pkgs, ... }:

{
  imports = [
    ./../../modules/home-manager/zsh.nix
    ./../../modules/home-manager/neovim.nix
    ./../../modules/home-manager/tmux.nix
    ./../../modules/home-manager/alacritty.nix
    ./../../modules/home-manager/i3.nix
    ./langs.nix
  ];
  home.username = "kunkka-vm";
  home.homeDirectory = "/home/kunkka-vm";
  home.stateVersion = "24.05";

  within.neovim.enable = true;
  within.zsh.enable = true;
  nixpkgs.config.allowUnfree = true;

  home.packages = [
    pkgs.vim
    pkgs.git
    pkgs.nerd-fonts.inconsolata
    # pkgs.nerd-fonts.maple-mono
    pkgs.rcm
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
