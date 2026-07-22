# build go from source
{ pkgs, lib, ... }:

let
  go_from_source = pkgs.stdenv.mkDerivation rec {
    pname = "go";
    version = "1.26.5";

    src = pkgs.fetchFromGitHub {
      owner = "golang";
      repo = "go";
      rev = "go1.26.5";
      sha256 = "sha256-jyZ0QPD1lR/mgsNpqr1NPr1kFfK4AuHU3Y8uZaY6N04=";
    };

    nativeBuildInputs = [ pkgs.go ];
    buildInputs = [ pkgs.gcc pkgs.bash ];

    buildPhase = ''
      export GOROOT=$(pwd)
      export GOBIN=$GOROOT/bin
      export PATH=$GOROOT/bin:$PATH

      export GOCACHE=$TMPDIR/go-build
      export GOTMPDIR=$TMPDIR/go-build
      mkdir -p $GOCACHE $GOTMPDIR

      echo "Building New Go..."
      cd src
      ./make.bash
      cd ..
      echo "Go build completed!"
    '';

    installPhase = ''
      mkdir -p $out

      # Copy everything, preserving the Go source structure
      cp -r . $out/

      # Verify that unsafe package exists
      if [ ! -f "$out/src/unsafe/unsafe.go" ]; then
        echo "ERROR: unsafe package is missing!"
        echo "Listing contents of $out/src:"
        ls -l $out/src
        exit 1
      fi

      echo "Go installed with full stdlib"
      echo ">>> $out/bin:"
      ls -l $out/bin
    '';

    meta = with lib; {
      description = "Go programming language";
      license = licenses.bsd3;
    };
  };

in
{
  home.packages = with pkgs; [
    go_from_source
  ];

  home.sessionVariables = {
    # Point GOROOT at the stable profile symlink, NOT the raw store path.
    # "${go_from_source}" bakes in a specific /nix/store/<hash>-go path that
    # breaks (go: cannot find GOROOT) once that path is garbage-collected on a
    # later rebuild. ~/.nix-profile always retargets to the current generation
    # and holds the full go tree (bin/, src/, pkg/), so it survives GC.
    GOROOT = "$HOME/.nix-profile";
    GOPATH = "/Users/haovanngyuen/go";
    GOBIN = "/Users/haovanngyuen/go/bin";
    PATH = "$HOME/.nix-profile/bin:$HOME/.npm-global/bin:$PATH";
  };
}
