{ pkgs, lib, ... }:

let
  installMacism = pkgs.writeShellScriptBin "install-macism" ''
    export PATH="${pkgs.lib.makeBinPath [ pkgs.curl pkgs.coreutils pkgs.bash ]}:$PATH"
    set -euo pipefail

    # URL binary macism
    MACISM_URL="https://github.com/laishulu/macism/releases/latest/download/macism-arm64"

    TMP_BIN="/tmp/macism"
    curl -L $MACISM_URL -o $TMP_BIN
    chmod +x $TMP_BIN

    if [ ! -f "/usr/local/bin/macism" ]; then
      echo "Installing macism to /usr/local/bin..."
      cp $TMP_BIN /usr/local/bin/macism
    else
      echo "macism already exists in /usr/local/bin"
    fi

    rm -f $TMP_BIN
  '';
in
{
  home.activation.installMacism =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${installMacism}/bin/install-macism
    '';
}
