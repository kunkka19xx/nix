# showmethekey (Wayland on-screen key display) tuned to look like keycast on
# macOS: compact glyphs (⌘⌃⌥⇧A), centered, short pill, keys fade after 1.2s,
# no border, no mouse buttons.
#
# Two changes on top of nixpkgs:
#
# 1. A patch makes the keys window a wlr-layer-shell surface (overlay layer,
#    anchored bottom, centred by the compositor, no keyboard). Upstream it is
#    a plain floating toplevel, which niri shows on one workspace only.
#    Position is set in the patch, not here: see showmethekey-layer-shell.patch.
#
# 2. Defaults baked into the GSettings schema instead of home-manager's
#    dconf.settings, because dconf is disabled in modules/home-manager/banana.nix.
#    The GUI can still change any of these at runtime.
#    paused-modifier / clickable-modifier are 'none' on purpose: upstream
#    toggles pause on every *second* Alt press (the counter only resets on a
#    mouse click), so Alt+Space for Look kept pausing it.
#
# Must stay in environment.systemPackages: polkit only picks the rule that
# lets wheel run the libinput backend without a password from there.
{
  showmethekey,
  glib,
  gtk4-layer-shell,
}:
showmethekey.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./showmethekey-layer-shell.patch ];
  nativeBuildInputs = old.nativeBuildInputs ++ [ glib ];
  buildInputs = old.buildInputs ++ [ gtk4-layer-shell ];
  postInstall = (old.postInstall or "") + ''
    cat > $out/share/glib-2.0/schemas/50-keycast.gschema.override <<'EOF'
    [one.alynx.showmethekey]
    first-time=false
    mode='compact'
    alignment='center'
    width=560.0
    height=64.0
    timeout=1200.0
    draw-border=false
    show-shift=false
    show-mouse=false
    paused-modifier='none'
    clickable-modifier='none'
    EOF
    glib-compile-schemas $out/share/glib-2.0/schemas
  '';
})
