{ config, lib, pkgs, ... }:

let
  mod = "Mod4";
in
{
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = mod;
      # terminal = "alacritty";
      terminal = "ghostty";
      keybindings = lib.mkOptionDefault {
        "${mod}+Return" = "exec ghostty";
        "${mod}+Shift+e" = "kill";
        "${mod}+Shift+w" = "exec i3-msg exit";
        "${mod}+r" = "restart";
        "${mod}+d" = "exec dmenu_run";
        "${mod}+Shift+h" = "focus left";
        "${mod}+Shift+l" = "focus right";
        "${mod}+Shift+j" = "focus down";
        "${mod}+Shift+k" = "focus up";
      };
    };
    extraConfig = ''
      default_border pixel 1
      for_window [class=".*"] border pixel 1
      font pango:JetBrainsMono Nerd Font 26
      exec --no-startup-id ${pkgs.feh}/bin/feh --bg-scale ~/nix/dotfiles/sway/bg/bg1.jpg
      exec --no-startup-id ghostty
      exec i3-msg workspace C
    '';
  };
}
