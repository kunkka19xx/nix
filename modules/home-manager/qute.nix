{ config, lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  quteDotfiles = ../../dotfiles/qute;
  quteTargetBase =
    if isDarwin
    then ".qutebrowser"
    else ".config/qutebrowser";
in
{
  home.file = {
    "${quteTargetBase}/config.py".source = "${quteDotfiles}/config.py";
    "${quteTargetBase}/gruvbox.py".source = "${quteDotfiles}/gruvbox.py";
  };
}
