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
    rPackages.precommit
    go-tools # gogrep gosmith irdump staticcheck
    # Zig
    zig
    # API testing
    hurl
  ];

  home.sessionVariables = {
    # Python
    PYTHONSTARTUP = "${pkgs.python3}/lib/python3.13/site-packages";

    GOROOT = "${pkgs.go}";
    GOPATH = "/home/kunkka-vm/go";
    GOBIN = "/home/kunkka-vm/go/bin";
    GOPROXY = "https://proxy.golang.org,direct";
    # Node.js
    NODE_PATH = "~/.npm-global/lib/node_modules";

    # Rust
    CARGO_HOME = "~/.cargo";
    PATH = "${pkgs.go}/bin:$HOME/.npm-global/bin:$PATH";

  };
}
