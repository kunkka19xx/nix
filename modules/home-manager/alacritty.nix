{ lib
, config
, pkgs
, ...
}:

with lib;

let
  cfg = config.within.alacritty;
in
{
  options.within.alacritty.enable = mkEnableOption "Enables Within's Alacritty config";

  config = mkIf cfg.enable {
    programs.alacritty.enable = true;
    home.file = {
      ".config/alacritty/alacritty.toml" = {
        source = ../../dotfiles/alacritty/.config/alacritty/alacritty.toml;
      };
    };
  };
}
