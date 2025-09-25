# build go from source
{ pkgs, lib, ... }:

let
  go_from_source = pkgs.stdenv.mkDerivation rec {
    pname = "go";
    version = "1.25.1";

    src = pkgs.fetchFromGitHub {
      owner = "golang";
      repo = "go";
      rev = "go1.25.1";
      sha256 = "sha256-5HYi44U6DedmLCNZuFiuKoM9tP2tVurjzmaLptvyht0=";
    };

    nativeBuildInputs = [ pkgs.go_1_24 ];
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
    GOROOT = "${go_from_source}";
    GOPATH = "/Users/haovanngyuen/go";
    GOBIN = "/Users/haovanngyuen/go/bin";
    PATH = "${go_from_source}/bin:$HOME/.npm-global/bin:$PATH";
  };
}
