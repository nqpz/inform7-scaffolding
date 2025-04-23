pkgs: sources:
{
  inform7 = let
    buildInputs = [ pkgs.clang ];

    # Inweb offers a modern approach to literate programming.
    inweb-dev = pkgs.stdenv.mkDerivation {
      pname = "inweb";
      version = "7.2.1-beta+1B67";

      unpackPhase = "true";

      inherit buildInputs;

      configurePhase = ''
        cp -r ${sources.inweb} inweb
        chmod u+w -R inweb
      '';

      buildPhase = ''
        bash inweb/scripts/first.sh linux
      '';

      installPhase = ''
        mkdir $out
        cp -r inweb $out
      '';
    };

    # Intest is a flexible command-line tool for running batches of tests on
    # other command-line tools. It requires Inweb.
    inweb-and-intest-dev = pkgs.stdenv.mkDerivation {
      pname = "intest";
      version = "2.2.0-beta+1A60";

      unpackPhase = "true";

      inherit buildInputs;

      configurePhase = ''
        cp -r ${inweb-dev}/* .
        cp -r ${sources.intest} intest
        chmod u+w -R intest
      '';

      buildPhase = ''
        bash intest/scripts/first.sh
      '';

      installPhase = ''
        mkdir $out
        cp -r inweb intest $out
      '';
    };

    # Build Inform 7 and install the entire directory tree. This is useful as an
    # intermediate step before the next wrapper derivation.
    inform7-dev = pkgs.stdenv.mkDerivation {
      pname = "inform7-dev";
      version = "10.2.0-beta+6X83";

      unpackPhase = "true";

      inherit buildInputs;

      configurePhase = ''
        cp -r ${inweb-and-intest-dev}/* .
        cp -r ${sources.inform} inform
        chmod u+w -R inform
      '';

      buildPhase = ''
        cd inform
        bash scripts/first.sh
      '';

      installPhase = ''
        cp -r . $out
      '';
    };
  in pkgs.stdenv.mkDerivation {
    pname = "inform7";
    version = "10.2.0-beta+6X83";

    unpackPhase = "true";

    buildInputs = [];

    configurePhase = "true";

    buildPhase = "true";

    # This currently installs only the inbuild command line utility. See
    # https://ganelson.github.io/inform/inbuild/index.html for the
    # manual. Inform 7 also comes with other command line utilities that we
    # don't need direct access to.
    #
    # inbuild expects that the relative inform7/Internal directory and the
    # relative gameinfo.dbg file are writable, so we let them live in
    # /tmp/inform7 and recreate them as needed.
    installPhase = ''
      cp -r ${inform7-dev} $out
      chmod u+w $out
      chmod u+w -R $out/inform7
      rm -r $out/inform7/Internal
      ln -s /tmp/inform7/Internal $out/inform7/Internal
      ln -s /tmp/inform7/gameinfo.dbg $out/gameinfo.dbg
      mkdir $out/bin

      cat > $out/bin/inbuild <<EOF
      #!/bin/sh
      set -e
      test -d /tmp/inform7/Internal || (mkdir -p /tmp/inform7 && cp -r ${inform7-dev}/inform7/Internal /tmp/inform7/ && chmod u+w /tmp/inform7)
      test -f /tmp/inform7/gameinfo.dbg || touch /tmp/inform7/gameinfo.dbg
      cd $out
      EOF
      echo 'exec ./inbuild/Tangled/inbuild "$@"' >> $out/bin/inbuild

      chmod +x $out/bin/inbuild
    '';
  };

  glulxe = let
    buildInputs = [ pkgs.ncurses.dev ];

    # glktermw supports wide term characters.
    glktermw-dev = pkgs.stdenv.mkDerivation {
      pname = "glktermw";
      version = "1.0.4";

      src = pkgs.fetchurl {
        url = "https://eblong.com/zarf/glk/glktermw-104.tar.gz";
        sha256 = "5968630b45e2fd53de48424559e3579db0537c460f4dc2631f258e1c116eb4ea";
      };

      inherit buildInputs;

      installPhase = ''
        mkdir $out
        cp -r . $out
      '';
    };
  in
    # Glulxe is an interpreter for the Glulx virtual machine.
    pkgs.stdenv.mkDerivation {
      pname = "glulxe";
      version = "0.6.1";

      src = pkgs.fetchurl {
        url = "https://www.eblong.com/zarf/glulx/glulxe-061.tar.gz";
        sha256 = "f81dc474d60d7d914fcde45844a4e1acafee50e13aebfcb563249cc56740769f";
      };

      inherit buildInputs;

      configurePhase = ''
        substituteInPlace Makefile \
          --replace ../cheapglk ${glktermw-dev} \
          --replace Make.cheapglk Make.glktermw
      '';

      buildPhase = ''
        make glulxe
      '';

      installPhase = ''
        mkdir -p $out/bin
        cp glulxe $out/bin
      '';
    };
}
