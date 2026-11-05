{ lib
, config
, pkgs
, ...
}:

with lib;

let
  cfg = config.within.ghostty;
in
{
  options.within.ghostty.enable = mkEnableOption "Enables Within's Ghostty config";

  config = mkIf cfg.enable {
    # Shared config plus the platform overlay. The shared file ends with an
    # optional "config-file = ?macos" include, which is skipped here because
    # no macos file is linked next to it.
    home.file.".config/ghostty/config".text =
      builtins.readFile ../../dotfiles/ghostty/.config/ghostty/config
      + "\n"
      + builtins.readFile (
        if pkgs.stdenv.isDarwin
        then ../../dotfiles/ghostty/.config/ghostty/macos
        else ../../dotfiles/ghostty/.config/ghostty/linux
      );
  };
}

