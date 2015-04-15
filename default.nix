{ stdenv, haskellPackages }:

let
  env = haskellPackages.ghcWithPackages (p: with p; [
    # Tools:
    cabal-install hlint

    # Libraries:
    haskeline ansi-terminal text mtl transformers
  ]);

in stdenv.mkDerivation rec {
  name = "byline";
  src = ./src;

  buildInputs = [ env ];

  buildPhase = ''
    ( HOME="$(mktemp -d)" # For cabal-install.
      cabal build || exit 1
      cabal test  || exit 1
    )

    hlint src
  '';

  installPhase = ''
  '';

  shellHook = ''
    export NIX_GHC="${env}/bin/ghc"
    export NIX_GHCPKG="${env}/bin/ghc-pkg"
    export NIX_GHC_DOCDIR="${env}/share/doc/ghc/html"
    export NIX_GHC_LIBDIR=$( $NIX_GHC --print-libdir )
  '';
}
