{
  description = "book builder";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-22.11;
    flake-utils.url = github:numtide/flake-utils;
  };
  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib; eachSystem allSystems (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      tex = pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-basic latex-bin latexmk blindtext pgf pgfplots booktabs filecontents float tocloft biblatex parskip caption metafont cm-super;
      };
    in rec {
      packages = {
        document = pkgs.stdenvNoCC.mkDerivation rec {
          name = "book";
          src = self;
          buildInputs = [ pkgs.coreutils tex pkgs.gnumake pkgs.gawk pkgs.biber];
          phases = ["unpackPhase" "buildPhase" "installPhase"];
          buildPhase = ''
            export PATH="${pkgs.lib.makeBinPath buildInputs}";
            mkdir -p .cache/texmf-var
            cd book/
            env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
              #latexmk -interaction=nonstopmode -pdf -pdflatex \
              make
            cd ..
          '';
          installPhase = ''
            mkdir -p $out
            cp book/book.pdf $out/
          '';
        };
      };
      defaultPackage = packages.document;
    });
}
