{ lib
, config
, pkgs
, ...
}:


with lib;

let
  cfg = config.within.wezterm;
in
{
  options.within.wezterm.enable = mkEnableOption "Enables Within's wezterm config";

  config = mkIf cfg.enable {
    programs.wezterm.enable = true;
    home.file = {
      ".wezterm.lua" = {
        source = ../../dotfiles/wezterm/.wezterm.lua;
      };
    };
  };
}

