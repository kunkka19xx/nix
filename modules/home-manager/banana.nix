{ config, lib, pkgs, ... }:

let
  isDarwinAarch64 = pkgs.system == "aarch64-darwin";
in
{
  dconf.enable = false;

  home.pointerCursor = lib.mkIf (!isDarwinAarch64) {
    name = "Banana";
    size = 36;
    package = pkgs.banana-cursor;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;

    cursorTheme = lib.mkIf (!isDarwinAarch64) {
      name = "Banana";
      package = pkgs.banana-cursor;
    };
  };
}
