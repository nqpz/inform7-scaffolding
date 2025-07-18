pkgs: sources:
{
  makefileInclude = pkgs.writeTextFile {
    name = "include.mk";
    text = ''
.PHONY: all
all:
	@echo "Available targets:"
	@echo "  test: Build a test build and run it."
	@echo "  bin/test.ulx: Build a test build."
	@echo "  bin/release.ulx: Build a release build."
	@echo "  map: Open a map of the world."
	@echo "  init: Create a new project consisting of story.ni and uuid.txt."

.PHONY: init
init:
	inform7-init

# These variables may already have been defined in the Makefile.
ULX_DEPS_BASE += scaffolding bin story.ni $(shell find includes 2>/dev/null || true)
ULX_DEPS_TEST ?=
ULX_DEPS_RELEASE ?=
TEST_DEPS ?=

bin/test.ulx: $(ULX_DEPS_BASE) $(ULX_DEPS_TEST)
	inform7-compile bin/test.ulx -debug

bin/release.ulx: $(ULX_DEPS_BASE) $(ULX_DEPS_RELEASE)
	inform7-compile bin/release.ulx -release

.PHONY: test
test: bin/test.ulx $(TEST_DEPS)
	rlwrap glulxe bin/test.ulx

scaffolding:
	inform7-create-scaffolding

bin:
	mkdir -p bin

.PHONY: map
map:
	xdg-open scaffolding/game.inform/Index/World.html

.PHONY: clean_internal
clean_internal:
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
