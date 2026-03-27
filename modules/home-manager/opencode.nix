{ pkgs, inputs, ... }: # Changed from opencode to inputs

{
  home.packages = [
    # Use nixpkgs version instead of flake (flake version has build issues)
    pkgs.opencode
  ];

  # Manually manage the config file since we aren't using a built-in module
  xdg.configFile."opencode/config.json".text = builtins.toJSON {
    theme = "opencode";
    autoshare = false;
    autoupdate = false;
    keybinds = {
      "leader" = "ctrl+x";

      # 1. Remap the keys to navigation
      # We add them to history and input move to ensure they work in the palette
      "history_previous" = "up,ctrl+k";
      "history_next" = "down,ctrl+j";
      "input_move_up" = "up,ctrl+k";
      "input_move_down" = "down,ctrl+j";

      # 2. Clear the old bindings so they don't conflict
      # 'ctrl+k' usually kills the line, we change it to 'none' or another key
      "input_delete_to_line_end" = "none";
      # 'ctrl+j' usually makes a newline, we change it to 'none'
      # (return still works for newline via shift+return)
      "input_newline" = "shift+return,ctrl+return,alt+return";
    };
  };
}
