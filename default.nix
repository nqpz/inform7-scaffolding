pkgs:
let
  scripts = {
    inform7-init = pkgs.writeScriptBin "inform7-init" (''
#!/bin/sh
#
# Create core files.

# Exit on first error.
set -e

if [[ -f uuid.txt || -f story.ni || -f Makefile ]]; then
    echo It looks like you have already run inform7-init. >/dev/stderr
    exit 1
fi

# Every Inform 7 game needs a UUID.
${pkgs.util-linux}/bin/uuidgen > uuid.txt

# Every Inform 7 game has at least one .ni file.
touch story.ni

# Create a Makefile
echo 'include $'' + ''{INFORM7_SCAFFOLDING_INCLUDE_MK}' > Makefile
'');

    inform7-create-scaffolding = pkgs.writeScriptBin "inform7-create-scaffolding" ''
#!/bin/sh
#
# Create scaffolding required by Inform tools.  Inform is not lightweight when
# it comes to the amount of files it wants to keep around but that I don't care
# about.

# Exit on first error.
set -e

# Check that we are ready.
if ! [[ -f uuid.txt && -f story.ni ]]; then
    echo Please run inform7-init first. >/dev/stderr
    exit 1
fi
if [[ -d scaffolding ]]; then
    echo Scaffolding already exists. >/dev/stderr
    exit 1
fi

# Keep all the scaffolding in a separate directory.
mkdir scaffolding
cd scaffolding

# Avoid placing a glaring "Inform" directory in $HOME.
mkdir game.state
export HOME="$(readlink -f game.state)"

# Create a project and call it "game".
yes Q | ${pkgs.inform7}/bin/i7
(echo S; echo game.inform; echo Q) | ${pkgs.inform7}/bin/i7
cd game.inform

# Use the existing uuid.txt and story.ni
rm uuid.txt
ln -s ../../uuid.txt .
cd Source
rm story.ni
ln -s ../../../story.ni .
'';

    inform7-compile = pkgs.writeScriptBin "inform7-compile" ''
#!/bin/sh
#
# Compile a story contained within a scaffolding into an .ulx file.

# Exit on first error.
set -e

# Check that we are ready.
if ! [[ -d scaffolding ]]; then
    echo Please run inform7-create-scaffolding first. >/dev/stderr
    exit 1
fi

output="$1"
if ! [[ "$output" ]]; then
    echo Please specify an output filename >/dev/stderr
    exit 1
fi
shift

# Avoid placing a glaring "Inform" directory in $HOME.
export HOME="$(readlink -f scaffolding/game.state)"

${pkgs.inform7}/bin/i7 "$@" scaffolding/game.inform
cp scaffolding/game.inform/Build/output.ulx "$output"
'';

    inform7-run = pkgs.writeScriptBin "inform7-run" ''
#!/bin/sh
#
# Run an .ulx file.

exec ${pkgs.rlwrap}/bin/rlwrap ${pkgs.inform7}/libexec/dumb-glulxe "$@"
'';
  };

  files = {
    makefileInclude = pkgs.writeTextFile {
      name = "include.mk";
      text = ''
bin/test.ulx: scaffolding bin story.ni
	inform7-compile bin/test.ulx -c

bin/release.ulx: scaffolding bin story.ni
	inform7-compile bin/release.ulx -r

.PHONY: test
test: bin/test.ulx
	inform7-run bin/test.ulx

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
  };

  shellBuildInputs = [
    scripts.inform7-init
    scripts.inform7-create-scaffolding
    scripts.inform7-compile
    scripts.inform7-run
    pkgs.util-linux
  ];

  mkShell = pkgs.mkShell {
    buildInputs = shellBuildInputs;
    shellHook = ''export INFORM7_SCAFFOLDING_INCLUDE_MK="${files.makefileInclude}"'';
  };

  buildInputs = with scripts; [
    scripts.inform7-create-scaffolding
    scripts.inform7-compile
    pkgs.util-linux
  ];

  mkDerivation = src: pname: version: pkgs.stdenv.mkDerivation {
    pname = pname;
    version = version;

    src = src;

    buildInputs = buildInputs;

    buildPhase = ''
    export INFORM7_SCAFFOLDING_INCLUDE_MK="${files.makefileInclude}"
    make clean release.ulx
  '';

    installPhase = ''
    mkdir $out
    cp release.ulx $out/${pname}.ulx
  '';
  };
in
{
  scripts = scripts;
  files = files;
  shellBuildInputs = shellBuildInputs;
  mkShell = mkShell;
  buildInputs = buildInputs;
  mkDerivation = mkDerivation;
}
