{ config, pkgs, ... }:

{
  xsession.enable = true;
  home.packages = with pkgs; [
    i3status
    dmenu
  ];
  xsession.windowManager.i3.enable = true;
  xsession.windowManager.i3.config = {
    modifier = "Mod4";
    terminal = "alacritty";
    keybindings = {
      keybindings = {
        "${config.xsession.windowManager.i3.config.modifier}+Return" = "exec alacritty";
        "${config.xsession.windowManager.i3.config.modifier}+Shift+q" = "kill";
        "${config.xsession.windowManager.i3.config.modifier}+d" = "exec dmenu_run";
        "${config.xsession.windowManager.i3.config.modifier}+j" = "focus left";
        "${config.xsession.windowManager.i3.config.modifier}+k" = "focus down";
        "${config.xsession.windowManager.i3.config.modifier}+l" = "focus up";
        "${config.xsession.windowManager.i3.config.modifier}+semicolon" = "focus right";
      };
    };
  };
}
