{ config, lib, pkgs, ... }:

let
  quteDotfiles = ../../dotfiles/qute;
  quteTargetBase = ".qutebrowser";

in
{
  home.file = {
    "${quteTargetBase}/config.py".source = "${quteDotfiles}/config.py";
    "${quteTargetBase}/gruvbox.py".source = "${quteDotfiles}/gruvbox.py";
  };
}












