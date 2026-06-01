{ config, lib, pkgs, ... }:
let
  mod = "Mod4";
in
{
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    checkConfig = false;
    config = {
      modifier = mod;
      bars = [ ];
      gaps = {
        inner = 4;
        outer = 3;
      };
      terminal = "ghostty";
      keybindings = lib.mkOptionDefault {
        "${mod}+Return" = "exec ghostty";
        "${mod}+Shift+f" = "exec firefox";
        "${mod}+Shift+BackSpace" = "exec brave";
        "${mod}+Shift+d" = "exec zathura";
        "${mod}+Shift+t" = "exec bash $HOME/.config/zathura/change-theme.bash";
        "${mod}+Shift+plus" = "exec swaymsg scratchpad show || bash -c 'swaymsg floating enable && swaymsg resize set 1280px 1350px && swaymsg move position center && swaymsg move scratchpad'";
        "${mod}+Shift+m" = "exec ghostty --title=kew-player -e bash -c 'kew all shuffle'";
        "${mod}+Shift+e" = "kill";
        "${mod}+Shift+w" = "exec swaymsg exit";
        "${mod}+r" = "reload";
        "${mod}+d" = "exec dmenu_run";
        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";
        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+l" = "move right";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+j" = "move down";
        "${mod}+Ctrl+h" = "resize shrink width 10px";
        "${mod}+Ctrl+l" = "resize grow width 10px";
        "${mod}+Ctrl+k" = "resize grow height 10px";
        "${mod}+Ctrl+j" = "resize shrink height 10px";
        "${mod}+Ctrl+Shift+4" = "exec bash -c 'grim -g \"$(slurp)\" - | wl-copy'";
        "${mod}+Ctrl+4" = "exec bash -c 'grim - | wl-copy'";
        "${mod}+b" = "workspace b";
        "${mod}+1" = "workspace 1";
        "${mod}+0" = "workspace 0";
        "${mod}+Shift+b" = "move container to workspace b";
        "${mod}+Shift+1" = "move container to workspace 1";
        "${mod}+Shift+n" = "exec bash -c 'swaymsg output \"*\" bg \"$(find $HOME/nix/modules/bg -type f | shuf -n1)\" fill'";
        "${mod}+Shift+i" = "exec bash $HOME/nix/dotfiles/dmenu/info.sh";
        "${mod}+Shift+minus" = "exec swaymsg scratchpad show || bash -c 'swaymsg floating enable && swaymsg resize set 1920px 1080px && swaymsg move position center && swaymsg move scratchpad'";
        "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
      };
    };
    extraConfig = ''
      default_border pixel 1
      for_window [app_id="ghostty"] border none
      for_window [app_id="firefox"] border none, move to workspace b
      for_window [class="firefox"] border none, move to workspace b
      for_window [class="Brave-browser"] move to workspace 0
      for_window [app_id="brave-browser"] move to workspace 0
      for_window [title="kew-player"] move to workspace 9
      for_window [title="Look"] floating enable, border none
      font pango:JetBrainsMono Nerd Font 19
      output * bg ~/nix/modules/bg/nix-waifu.png fill
      exec ghostty
      exec lookapp
      exec swaymsg workspace 1
      exec fcitx5
    '';
  };
}
