{ config, lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  quteDotfiles = ../../dotfiles/qutebrowser/.qutebrowser;
  quteTargetBase =
    if isDarwin
    then ".qutebrowser"
    else ".config/qutebrowser";
in
{
  home.file = {
    "${quteTargetBase}/config.py".source = "${quteDotfiles}/config.py";
    "${quteTargetBase}/gruvbox.py".source = "${quteDotfiles}/gruvbox.py";
    "${quteTargetBase}/userscript".source = "${quteDotfiles}/userscript";
  };
}
