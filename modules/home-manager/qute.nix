{ config, lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  quteDotfiles = ../../dotfiles/qutebrowser/.qutebrowser;
  quteTargetBase =
    if isDarwin
    then ".qutebrowser"
    else ".config/qutebrowser";
in
{
  # nixpkgs marks qutebrowser insecure (it still accepts eMudhra TLS certs).
  # Match by name so the allowance survives version bumps.
  nixpkgs.config.allowInsecurePredicate = pkg: lib.getName pkg == "qutebrowser";

  home.file = {
    "${quteTargetBase}/config.py".source = "${quteDotfiles}/config.py";
    "${quteTargetBase}/gruvbox.py".source = "${quteDotfiles}/gruvbox.py";
    "${quteTargetBase}/userscript".source = "${quteDotfiles}/userscript";
  };
}
