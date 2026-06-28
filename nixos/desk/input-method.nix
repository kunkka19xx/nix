{ pkgs, lib, ... }:
let
  # GTK3 only loads IM modules listed in immodules.cache. NixOS's default cache
  # doesn't include fcitx5-gtk, so Firefox can't find fcitx even with
  # GTK_IM_MODULE=fcitx set. Build a cache that includes fcitx5-gtk + GTK's
  # bundled immodules and point GTK_IM_MODULE_FILE at it.
  # Note: lookapp's WebKit doesn't work with this cache, so fcitx5.nix wraps
  # lookapp to unset GTK_IM_MODULE_FILE for its own process.
  fcitx5-gtk3-immodules-cache = pkgs.runCommand "fcitx5-gtk3-immodules.cache" { } ''
    mkdir -p "$out/lib/gtk-3.0/3.0.0"
    ${pkgs.gtk3.dev}/bin/gtk-query-immodules-3.0 \
      ${pkgs.gtk3.out}/lib/gtk-3.0/3.0.0/immodules/*.so \
      ${pkgs.fcitx5-gtk}/lib/gtk-3.0/3.0.0/immodules/im-fcitx5.so \
      > "$out/lib/gtk-3.0/3.0.0/immodules.cache"
  '';
in
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-gtk
        qt6Packages.fcitx5-unikey
      ];
      waylandFrontend = false;
    };
  };

  environment.sessionVariables = {
    GTK_IM_MODULE = lib.mkForce "fcitx";
    QT_IM_MODULE = lib.mkForce "fcitx";
    XMODIFIERS = "@im=fcitx";
    GTK_IM_MODULE_FILE = "${fcitx5-gtk3-immodules-cache}/lib/gtk-3.0/3.0.0/immodules.cache";
    NIXOS_OZONE_WL = "0";
    MOZ_ENABLE_WAYLAND = "0";
    ELECTRON_OZONE_PLATFORM_HINT = "x11";
  };

  # Inject GTK_IM_MODULE_FILE into the systemd user manager's default
  # environment, otherwise apps launched via D-Bus / .desktop activation
  # (which go through systemd --user, not sway exec) won't see it.
  systemd.user.settings.Manager.DefaultEnvironment =
    "GTK_IM_MODULE_FILE=${fcitx5-gtk3-immodules-cache}/lib/gtk-3.0/3.0.0/immodules.cache";

  programs.chromium.extraOpts = {
    enable = true;
    extraArgs = [
      "--gtk-version=4"
      "--disable-features=WaylandFractionalScaleV1"
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=x11"
    ];
  };
}
