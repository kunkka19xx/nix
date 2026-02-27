{
  pkgs,
  inputs,
  config,
  lib,
  ...
}:

{
  imports = [
    ./../../modules/home-manager/default.nix
    ./../../modules/home-manager/alacritty.nix
    ./../../modules/home-manager/wezterm.nix
    ./../../modules/home-manager/qute.nix
    ./../../modules/home-manager/firefox.nix
    ./langs.nix
    ./go.nix
    # ./im-select.nix
    ./macism.nix
  ];
  home.username = "haovanngyuen";
  home.homeDirectory = "/Users/haovanngyuen";
  home.stateVersion = "24.05";
  nixpkgs.config.allowUnfree = true;

  # Custom Modules that I'm enabling
  within.neovim.enable = true;
  within.alacritty.enable = true;
  within.wezterm.enable = true;
  within.zsh.enable = true;
  within.ghostty.enable = true;

  xdg.configFile.aerospace = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/dotfiles/aerospace";
    recursive = true;
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.vim
    pkgs.wezterm
    pkgs.aerospace
    pkgs.nerd-fonts.inconsolata
    pkgs.alacritty
    pkgs.rcm
    pkgs.unzip # install java, ... neovim
    pkgs.lazydocker
    pkgs.tree
    pkgs.gradle
    pkgs.brave
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
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
