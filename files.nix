pkgs: sources:
{
  makefileInclude = pkgs.writeTextFile {
    name = "include.mk";
    text = ''
.PHONY: init
init:
	inform7-init

bin/test.ulx: scaffolding bin story.ni
	inform7-compile bin/test.ulx -debug

bin/release.ulx: scaffolding bin story.ni
	inform7-compile bin/release.ulx -release

.PHONY: test
test: bin/test.ulx
	glulxe bin/test.ulx

scaffolding:
	inform7-create-scaffolding

bin:
	mkdir -p bin

.PHONY: clean
clean:
	rm -rf scaffolding
	rm -rf bin
'';
  };

  externalNest = pkgs.stdenv.mkDerivation {
    pname = "inform7-extensions";
    version = "git";

    unpackPhase = "true";

    buildInputs = [];

    buildPhase = "true";

    installPhase = ''
      mkdir $out
      cp -r ${sources.extensions} $out/Extensions
    '';
  };
}
