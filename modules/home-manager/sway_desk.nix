{
  config,
  lib,
  pkgs,
  ...
}:
let
  mod = "Mod4";
  scratchpadScript = pkgs.writeShellScript "sway-scratchpad-toggle" ''
    # Smart scratchpad toggle:
    # - Empty scratchpad → send focused window in (1920x1080, centered, floating)
    # - Non-empty       → toggle visibility (sway's `scratchpad show` already toggles)
    count=$(swaymsg -t get_tree | ${pkgs.jq}/bin/jq '[.. | objects | select(.name == "__i3_scratch") | .floating_nodes[]] | length')
    if [ "''${count:-0}" -eq 0 ]; then
      swaymsg floating enable
      swaymsg resize set 1920px 1080px
      swaymsg move position center
      swaymsg move scratchpad
    else
      swaymsg scratchpad show
    fi
  '';
  toggleBarScript = pkgs.writeShellScript "sway-toggle-bar" ''
    bar_id=$(swaymsg -t get_bar_config | ${pkgs.jq}/bin/jq -r '.[0]')
    state=$(swaymsg -t get_bar_config "$bar_id" | ${pkgs.jq}/bin/jq -r '.mode')
    if [ "$state" = "invisible" ]; then
      swaymsg bar "$bar_id" mode dock
    else
      swaymsg bar "$bar_id" mode invisible
    fi
  '';
  statusScript = pkgs.writeShellScript "sway-status" ''
    while true; do
      DATE=$(date '+%a %d %b  %H:%M')
      VOL=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oE '[0-9]+%' | head -1)
      pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -q yes && VOL="muted"
      IM=$(fcitx5-remote 2>/dev/null || echo 1)
      if [ "$IM" = "2" ]; then IM_STR="VI"; else IM_STR="EN"; fi
      echo "  $IM_STR     vol $VOL     $DATE  "
      sleep 2
    done
  '';
in
{
  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.swayfx;
    wrapperFeatures.gtk = true;
    checkConfig = false;
    config = {
      modifier = mod;
      bars = [{
        position = "top";
        mode = "invisible";
        statusCommand = "${statusScript}";
        trayOutput = "none";
        fonts = {
          names = [ "JetBrainsMono Nerd Font" ];
          size = 12.0;
        };
        colors = {
          background = "#1e1e2ecc";
          statusline = "#cdd6f4";
          separator = "#585b70";
          focusedWorkspace  = { border = "#88c0d0"; background = "#88c0d0"; text = "#1e1e2e"; };
          activeWorkspace   = { border = "#313244"; background = "#313244"; text = "#cdd6f4"; };
          inactiveWorkspace = { border = "#00000000"; background = "#00000000"; text = "#6c7086"; };
          urgentWorkspace   = { border = "#f38ba8"; background = "#f38ba8"; text = "#1e1e2e"; };
        };
      }];
      gaps = {
        inner = 8;
        outer = 4;
      };
      terminal = "ghostty";
      keybindings = lib.mkOptionDefault {
        "${mod}+Return" = "exec ghostty";
        "${mod}+Shift+f" = "exec firefox";
        "${mod}+Shift+BackSpace" = "exec brave";
        "${mod}+Shift+d" = "exec zathura";
        "${mod}+Shift+t" = "exec bash $HOME/.config/zathura/change-theme.bash";
        "${mod}+minus" = "exec ${scratchpadScript}";
        "${mod}+Shift+m" = "exec ghostty --title=kew-player -e bash -c 'kew all shuffle'";
        "${mod}+Shift+e" = "kill";
        "${mod}+Shift+w" = "exec swaymsg exit";
        "${mod}+r" = "reload";
        "${mod}+Shift+r" = "reload";
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
        "${mod}+Shift+n" =
          "exec bash -c 'swaymsg output \"*\" bg \"$(find $HOME/nix/modules/bg -type f | shuf -n1)\" fill'";
        "${mod}+Shift+i" = "exec ${toggleBarScript}";
        "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
      };
    };
    extraConfig = ''
      # swayfx: subtle corners + shadows
      corner_radius 8
      shadows enable
      shadow_blur_radius 20
      shadow_color #00000080
      shadow_offset 0 4

      default_border pixel 2
      # border visible only on the focused window — unfocused = transparent
      #                 border    background text     indicator child_border
      client.focused   #88c0d0ff #88c0d0ff #ffffffff #88c0d0ff #88c0d0ff
      client.unfocused #00000000 #00000000 #888888ff #00000000 #00000000

      for_window [app_id="ghostty"] move to workspace 1
      for_window [app_id="firefox"] move to workspace b
      for_window [class="firefox"] move to workspace b
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
