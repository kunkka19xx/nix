# Look of the showmethekey keys window: a dark keycast-style pill.
# The package, its defaults and the layer-shell placement live in
# pkgs/showmethekey.nix (NixOS side); the toggle bind is in niri_desk.nix.
#
# Only the window chrome is CSS. The key glyphs are drawn with cairo at a
# size derived from the schema's height, so font and color are not here.
# Corners are rounded here rather than by niri because the window is a layer
# surface, which niri's window-rule geometry-corner-radius does not touch.
{ ... }:
{
  gtk.gtk4.extraCss = ''
    /* showmethekey keys window: dark pill, no visible header bar. */
    window.smtk-keys-win,
    window.smtk-keys-win.background {
      background: rgba(18, 18, 18, 0.85);
      border-radius: 20px;
    }
    window.smtk-keys-win headerbar {
      min-height: 0;
      padding: 0;
      margin: 0;
    }
    window.smtk-keys-win headerbar windowhandle box windowtitle {
      font-size: 1px;
      opacity: 0;
    }
  '';
}
