{ pkgs, lib, ... }:

let
  python_version = pkgs.python3_13;
in
{
  home.packages = with pkgs; [
    # Python
    python3
    # Node.js
    nodejs_23
    # Golang
    go
    golangci-lint
    # Rust
    cargo # Rust package manager, neovim pack install
    # Zig
    zig
    # Java
    openjdk17 # Java JDK
  ];

  # Other settings
  home.sessionVariables = {
    # Python
    PYTHONSTARTUP = "${pkgs.python3}/lib/python3.13/site-packages";

    GOROOT = "${pkgs.go}";
    GOPATH = "/home/kunkka-vm/go";
    GOBIN = "/home/kunkka-vm/go/bin";
    # Node.js
    NODE_PATH = "~/.npm-global/lib/node_modules";

    # Rust
    CARGO_HOME = "~/.cargo";
    PATH = "${pkgs.go}/bin:$HOME/.npm-global/bin:$PATH";

  };

}
