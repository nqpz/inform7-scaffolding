pkgs:
let
  sources = import ./nix/sources.nix;
  files = import ./files.nix pkgs sources;
  programs = import ./programs.nix pkgs sources;
  scripts = import ./scripts.nix pkgs files programs;
in
{
  mkShell = extraPkgs: pkgs.mkShell {
    buildInputs = extraPkgs ++ [
      scripts.inform7-init
      scripts.inform7-create-scaffolding
      scripts.inform7-compile
      pkgs.util-linux
      programs.inform7
      programs.glulxe
    ];
    shellHook = ''
      export INFORM7_SCAFFOLDING_INCLUDE_MK="${files.makefileInclude}"
    '';
  };

  mkDerivation = extraPkgs: src: pname: version: pkgs.stdenv.mkDerivation {
    inherit src;
    inherit pname;
    inherit version;

    buildInputs = extraPkgs ++ [
      scripts.inform7-create-scaffolding
      scripts.inform7-compile
      pkgs.util-linux
    ];

    buildPhase = ''
      export INFORM7_SCAFFOLDING_INCLUDE_MK="${files.makefileInclude}"
      make clean bin/release.ulx
    '';

    installPhase = ''
      mkdir $out
      cp bin/release.ulx $out/${pname}.ulx
    '';
  };
}
