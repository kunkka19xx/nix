{ config, lib, pkgs, ... }:
{
  dconf.enable = false;
  home.pointerCursor = {
    name = "Banana";
    size = 36;
    package = pkgs.banana-cursor;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    cursorTheme = {
      name = "Banana";
      package = pkgs.banana-cursor;
    };
  };
}
