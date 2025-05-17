{ config, pkgs, ... }:

{
  xsession.enable = true;
  home.packages = with pkgs; [
    dmenu
    feh
  ];
  xsession.windowManager.i3.enable = true;
  xsession.windowManager.i3.config = {
    modifier = "Mod4";
    # terminal = "alacritty";
    terminal = "ghostty";
    keybindings = {
      "${config.xsession.windowManager.i3.config.modifier}+Return" = "exec ghostty";
      "${config.xsession.windowManager.i3.config.modifier}+Shift+q" = "kill";
      "${config.xsession.windowManager.i3.config.modifier}+d" = "exec dmenu_run";
      "${config.xsession.windowManager.i3.config.modifier}+j" = "focus left";
      "${config.xsession.windowManager.i3.config.modifier}+k" = "focus down";
      "${config.xsession.windowManager.i3.config.modifier}+l" = "focus up";
      "${config.xsession.windowManager.i3.config.modifier}+semicolon" = "focus right";
    };
  };
  xsession.windowManager.i3.extraConfig = ''
    default_border pixel 1
    for_window [class=".*"] border pixel 1
    font pango:JetBrainsMono Nerd Font 26
    exec --no-startup-id ${pkgs.feh}/bin/feh --bg-scale ~/nix/dotfiles/sway/bg/bg1.jpg
  '';
}
