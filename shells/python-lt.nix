{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python312
    python312Packages.gevent
    python312Packages.greenlet
    stdenv.cc.cc.lib
  ];

  shellHook = ''
    echo "Welcome to dev shell with libstdc++!"
  '';
}

