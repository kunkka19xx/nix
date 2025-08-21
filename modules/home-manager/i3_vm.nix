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
        "${mod}+Shift+d" = "exec zathura";
        "${mod}+Shift+t" = "exec --no-startup-id bash $HOME/.config/zathura/change-theme.bash";
        "${mod}+Shift+plus" = "exec i3-msg scratchpad show || bash -c 'i3-msg floating enable && i3-msg resize set 1280px 1350px && i3-msg move position center && i3-msg move scratchpad'";
        "${mod}+Shift+e" = "kill";
        "${mod}+Shift+w" = "exec i3-msg exit";
        "${mod}+r" = "restart";
        "${mod}+d" = "exec dmenu_run";
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
        "${mod}+Ctrl+Shift+4" = "exec --no-startup-id flameshot gui";
        "${mod}+Ctrl+4" = "exec --no-startup-id flameshot screen";
        "${mod}+b" = "workspace b";
        "${mod}+1" = "workspace 1";
        "${mod}+Shift+b" = "move container to workspace b";
        "${mod}+Shift+1" = "move container to workspace 1";
        "${mod}+Shift+n" = "exec --no-startup-id feh --no-fehbg --randomize --bg-scale ~/nix/modules/bg/";
        "${mod}+Shift+i" = "exec --no-startup-id bash $HOME/nix/dotfiles/dmenu/info.sh";
        "${mod}+Shift+minus" = "exec i3-msg scratchpad show || bash -c 'i3-msg floating enable && i3-msg resize set 1920px 1080px && i3-msg move position center && i3-msg move scratchpad'";
        "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
      };
    };
    extraConfig = ''
      default_border pixel 1
      for_window [class="ghostty, firefox, alacritty"] border none
      for_window [class="firefox"] move to workspace b
      font pango:JetBrainsMono Nerd Font 20
      exec --no-startup-id sh -c "sleep 0.5 && ${pkgs.feh}/bin/feh --bg-scale ~/nix/dotfiles/sway/bg/bg1.jpg"
      exec --no-startup-id ghostty
      exec --no-startup-id ${pkgs.open-vm-tools}/bin/vmware-user
      exec i3-msg workspace 1
      exec --no-startup-id xclip'
    '';
  };
}

