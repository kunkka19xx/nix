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
    # go
    go-tools # gogrep gosmith irdump staticcheck
    # Zig
    zig
    # API testing
    hurl
    pre-commit
  ];

  home.sessionVariables = {
    # Python
    PYTHONSTARTUP = "${pkgs.python3}/lib/python3.13/site-packages";

    # Node.js
    NODE_PATH = "~/.npm-global/lib/node_modules";

    # Rust
    CARGO_HOME = "~/.cargo";
  };
}
