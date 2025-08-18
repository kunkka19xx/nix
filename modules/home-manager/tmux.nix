{ config, pkgs, lib, ... }:

{
  programs.tmux = {
    plugins = [
      pkgs.tmuxPlugins.vim-tmux-navigator
    ];
    enable = true;
    extraConfig = builtins.readFile ../../dotfiles/tmux/tmux.conf;
  };
}

