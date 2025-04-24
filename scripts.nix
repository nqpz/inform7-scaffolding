pkgs: programs:
{
  inform7-init = pkgs.writeScriptBin "inform7-init" (''
#!/bin/sh
#
# Create core files.

# Exit on first error.
set -e

if [[ -f uuid.txt || -f story.ni || -f Makefile ]]; then
    echo It looks like you have already run init. >/dev/stderr
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
# Create scaffolding required by Inform tools.

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
# Use the existing uuid.txt and story.ni
ln -s ../uuid.txt .
mkdir Source
cd Source
ln -s ../../story.ni .
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

abs_path="$(readlink -f scaffolding)"
${programs.inform7}/bin/inform7 -format=Inform6/32/v3.1.2 -project "$abs_path" "$@"
${programs.inform7}/inform6/Tangled/inform6 -kE2SwG "$abs_path/Build/auto.inf" "$output"
find scaffolding/Index -type f -exec sed -i 's|src=inform:/|src=${programs.inform7}/resources/Imagery/|g' {} \;
'';
}
