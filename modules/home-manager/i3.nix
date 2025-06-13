{ config, lib, pkgs, ... }:
let
  mod = "Mod4";
in
{
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = mod;
      bars = [ ];
      gaps = {
        inner = 4;
        outer = 2;
      };
      # terminal = "alacritty";
      terminal = "ghostty";
      keybindings = lib.mkOptionDefault {
        "${mod}+Return" = "exec ghostty";
        "${mod}+Shift+f" = "exec firefox";
        "${mod}+Shift+e" = "kill";
        "${mod}+Shift+w" = "exec i3-msg exit";
        "${mod}+r" = "restart";
        "${mod}+d" = "exec dmenu_run";
        # "${mod}+Shift+h" = "focus left";
        # "${mod}+Shift+l" = "focus right"k
        # "${mod}+Shift+j" = "focus down";
        # "${mod}+Shift+k" = "focus up";

        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus top";
        "${mod}+l" = "focus right";
        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+l" = "move right";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+j" = "move down";
        "${mod}+Ctrl+h" = "resize shrink width 10px";
        "${mod}+Ctrl+l" = "resize grow width 10px";
        "${mod}+Ctrl+k" = "resize grow height 10px";
        "${mod}+Ctrl+j" = "resize shrink height 10px";
        "${mod}+b" = "workspace b";
        "${mod}+1" = "workspace 1";
        "${mod}+Shift+b" = "move container to workspace b";
        "${mod}+Shift+1" = "move container to workspace 1";
        "${mod}+Shift+n" = "exec --no-startup-id feh --no-fehbg --randomize --bg-scale ~/nix/modules/bg/";
      };
    };
    extraConfig = ''
      default_border pixel 1
      for_window [class=".*"] border none
      font pango:JetBrainsMono Nerd Font 19
      exec --no-startup-id sh -c "sleep 0.5 && ${pkgs.feh}/bin/feh --bg-scale ~/nix/dotfiles/sway/bg/bg1.jpg"
      exec --no-startup-id ghostty
      exec --no-startup-id ${pkgs.open-vm-tools}/bin/vmware-user
      exec i3-msg workspace 1
      assign [class="Firefox"] workspace b
    '';
  };
}
