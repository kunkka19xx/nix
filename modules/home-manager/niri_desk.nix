{
  pkgs,
  ...
}:
let
  wallpaper = "$HOME/nix/modules/bg/nix-waifu.png";

  # niri has no built-in wallpaper support, so swaybg does it.
  # Re-running kills the old instance first, otherwise they stack.
  randomBgScript = pkgs.writeShellScript "niri-random-bg" ''
    pkill -x swaybg
    exec ${pkgs.swaybg}/bin/swaybg -i "$(find $HOME/nix/modules/bg -type f | shuf -n1)" -m fill
  '';
in
{
  xdg.configFile."niri/config.kdl".text = ''
    // niri: scrollable-tiling compositor, sibling to sway_desk.nix.
    // Keybinds mirror the sway config where it makes sense; niri-native
    // features (overview, columns, tabbed columns) are used where they beat
    // a literal translation. niri hot-reloads this file on write.

    // X11 apps: firefox, brave and electron all run under XWayland here
    // because input-method.nix forces them to x11 for fcitx5. niri has no
    // built-in XWayland, so xwayland-satellite provides it. niri exports
    // DISPLAY to everything it spawns.
    xwayland-satellite {
        path "${pkgs.xwayland-satellite}/bin/xwayland-satellite"
    }

    // Declared up front so window rules can target them by name and they
    // always exist in this order.
    workspace "1"
    workspace "b"
    workspace "0"
    workspace "9"

    input {
        keyboard {
            xkb {
                layout "us"
            }
        }
        // sway does this by default; niri does not.
        focus-follows-mouse
    }

    layout {
        gaps 8

        // How the strip scrolls when focus moves off-screen.
        //   "never"       - view only shifts as much as needed (sway-like)
        //   "on-overflow" - shifts only when the new column would not fit
        //   "always"      - focused column is always centered
        center-focused-column "on-overflow"

        // A lone window sits centered instead of stuck to the left edge.
        always-center-single-column

        default-column-width { proportion 0.5; }

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }

        // Matches the sway theme: focused window accented, unfocused invisible.
        focus-ring {
            width 2
            active-color "#88c0d0"
            inactive-color "#00000000"
        }

        border { off; }

        // swayfx shadows, same values.
        shadow {
            on
            softness 20
            spread 4
            offset x=0 y=4
            color "#00000080"
        }

        tab-indicator {
            gap 4
            width 4
            active-color "#88c0d0"
            inactive-color "#585b70"
        }
    }

    prefer-no-csd

    screenshot-path "~/Pictures/Screenshots/screenshot-%Y-%m-%d-%H-%M-%S.png"

    spawn-at-startup "ghostty"
    spawn-at-startup "lookapp"
    spawn-at-startup "fcitx5"
    spawn-sh-at-startup "${pkgs.swaybg}/bin/swaybg -i ${wallpaper} -m fill"

    window-rule {
        match app-id="^ghostty$"
        open-on-workspace "1"
    }

    window-rule {
        match app-id="^firefox$"
        match app-id="^Navigator$"
        open-on-workspace "b"
        default-column-width { proportion 1.0; }
    }

    window-rule {
        match app-id="^brave-browser$"
        match app-id="^Brave-browser$"
        open-on-workspace "0"
        default-column-width { proportion 1.0; }
    }

    window-rule {
        match title="^kew-player$"
        open-on-workspace "9"
    }

    window-rule {
        match title="^Look$"
        open-floating true
        focus-ring { off; }
        shadow { off; }
    }

    binds {
        Mod+Shift+Slash { show-hotkey-overlay; }

        // Launchers
        Mod+Return hotkey-overlay-title="Terminal" { spawn "ghostty"; }
        Mod+Shift+F hotkey-overlay-title="Firefox" { spawn "firefox"; }
        Mod+Shift+BackSpace hotkey-overlay-title="Brave" { spawn "brave"; }
        Mod+Shift+D hotkey-overlay-title="Zathura" { spawn "zathura"; }
        Mod+Shift+T { spawn-sh "bash $HOME/.config/zathura/change-theme.bash"; }
        Mod+Shift+M { spawn "ghostty" "--title=kew-player" "-e" "bash" "-c" "kew all shuffle"; }
        Mod+D hotkey-overlay-title="Run a command" { spawn "dmenu_run"; }
        Alt+Space hotkey-overlay-title="Toggle Look" {
            spawn "dbus-send" "--session" "--type=method_call" \
                  "--dest=com.look.Desktop" "/com/look/Desktop" \
                  "com.look.Desktop.Toggle"
        }
        Mod+Shift+N hotkey-overlay-title="Random wallpaper" { spawn "${randomBgScript}"; }

        Mod+Shift+E { close-window; }
        Mod+Shift+W { quit; }

        // Focus. A workspace is an infinite horizontal strip of columns:
        // h/l scroll along it, j/k move within the focused column.
        Mod+H { focus-column-left; }
        Mod+J { focus-window-down; }
        Mod+K { focus-window-up; }
        Mod+L { focus-column-right; }

        // Jump to either end of the strip.
        Mod+Home { focus-column-first; }
        Mod+End { focus-column-last; }
        Mod+Shift+Home { move-column-to-first; }
        Mod+Shift+End { move-column-to-last; }

        // Scroll the strip with the wheel. cooldown-ms keeps a fast flick
        // from overshooting by several columns.
        Mod+WheelScrollDown cooldown-ms=150 { focus-column-right; }
        Mod+WheelScrollUp cooldown-ms=150 { focus-column-left; }
        Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-right; }
        Mod+Ctrl+WheelScrollUp cooldown-ms=150 { move-column-left; }

        // Horizontal wheel / tilt scrolls without holding Mod.
        Mod+WheelScrollRight { focus-column-right; }
        Mod+WheelScrollLeft { focus-column-left; }

        Mod+Shift+H { move-column-left; }
        Mod+Shift+J { move-window-down; }
        Mod+Shift+K { move-window-up; }
        Mod+Shift+L { move-column-right; }

        // Pull the next window into this column / push it back out.
        // This is how you build a stack in niri; there is no split toggle.
        Mod+Comma  { consume-or-expel-window-left; }
        Mod+Period { consume-or-expel-window-right; }

        Mod+Ctrl+H { set-column-width "-10%"; }
        Mod+Ctrl+L { set-column-width "+10%"; }
        Mod+Ctrl+K { set-window-height "+10%"; }
        Mod+Ctrl+J { set-window-height "-10%"; }
        Mod+Minus  { set-column-width "-10%"; }
        Mod+Equal  { set-column-width "+10%"; }

        // Cycle the preset widths. niri reloads config on save, so the sway
        // reload bind is not needed.
        Mod+R { switch-preset-column-width; }
        Mod+Shift+R { switch-preset-window-height; }
        Mod+F { maximize-column; }
        Mod+Shift+Return { fullscreen-window; }
        Mod+C { center-column; }
        Mod+W { toggle-column-tabbed-display; }
        Mod+V { toggle-window-floating; }
        Mod+Shift+V { switch-focus-between-floating-and-tiling; }

        // Overview: bird's-eye view of every workspace. No sway equivalent.
        Mod+O { toggle-overview; }

        Mod+1 { focus-workspace "1"; }
        Mod+B { focus-workspace "b"; }
        Mod+0 { focus-workspace "0"; }
        Mod+9 { focus-workspace "9"; }
        Mod+Shift+1 { move-window-to-workspace "1"; }
        Mod+Shift+B { move-window-to-workspace "b"; }
        Mod+Shift+0 { move-window-to-workspace "0"; }
        Mod+Shift+9 { move-window-to-workspace "9"; }

        Mod+Tab { focus-workspace-previous; }
        Mod+U { focus-workspace-down; }
        Mod+I { focus-workspace-up; }

        // Built-in screenshot UI: freeze, select region, copies to clipboard
        // and saves to screenshot-path. Replaces grim + slurp + wl-copy.
        Mod+Ctrl+Shift+4 { screenshot; }
        Mod+Ctrl+4 { screenshot-screen; }
        Mod+Ctrl+Shift+5 { screenshot-window; }

        XF86AudioRaiseVolume allow-when-locked=true { spawn "pactl" "set-sink-volume" "@DEFAULT_SINK@" "+5%"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn "pactl" "set-sink-volume" "@DEFAULT_SINK@" "-5%"; }
        XF86AudioMute allow-when-locked=true { spawn "pactl" "set-sink-mute" "@DEFAULT_SINK@" "toggle"; }
    }
  '';
}
