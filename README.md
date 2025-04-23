# Inform 7 scaffolding

This repository provides wrapper scripts and a wrapper Makefile around
the [Inform 7](https://github.com/ganelson/inform) system and the
[Glulxe](https://github.com/erkyrath/glulxe) interpreter.

You only truly need two files to create an Inform 7 project: A `.ni`
file which contains the story, and a text file containing an UUID
(presumably as a way for each Inform 7 game in existence to have a
unique ID - this gets embedded into the final binary).

The wrapping in this repository ensure that you can focus on your `.ni`
story file without having to consider all the other files that the
Inform 7 machinery likes to create, which the scripts instead put into a
subdirectory named `scaffolding`.

You can use this project with [niv](https://github.com/nmattia/niv) by
running `niv init` and then `niv add nqpz/inform7-scaffolding`.  (This
project is currently not available as a Nix flake, but probably should
be.)  **Example use:** <https://github.com/nqpz/kantinen2012>.


## Creating a new project

First install [Nix](https://nixos.org/).

Run `inform7-init` with no arguments to create a new project.  This will
create these files:

  - `story.ni`: An empty file.
  - `uuid.txt`: A single-line file containing an UUID.
  - `Makefile`: A Makefile that you can use for development and release.

You can put this in your `.gitignore`:

```
scaffolding
bin
result
```


## Building and running

Run `nix-shell` to enter an environment with Inform 7 tooling present.
This is useful for when developing the game.

Then run `make test` to build and run the test build.  All builds use
the [Glulx format](https://www.eblong.com/zarf/glulx/).  The test build
has additional helper commands such as
[`SHOWME`](https://ganelson.github.io/inform-website/book/WI_2_7.html).)

You can also:

  - Run `make bin/test.ulx` to build a test build. (Contrary to `make
    test`, this doesn't immediately run it.)

  - Run `make bin/release.ulx` to build a release build.

  - Run `glulxe bin/release.ulx` to run the release build.

  - Run `nix-build` to build a release build.  This will build
    `release.ulx` and make it available in `result/`.  This is useful if
    you only need to build the game, and not actively develop it.

(Alternatively, if you can't install Nix, you can follow the [Inform 7
manual on how to use its
GUIs](https://ganelson.github.io/inform-website/book/WI_1_3.html) and
manually import `story.ni` into the story window, and then build and run
from there.)


## External resources

  - [Emacs package on MELPA](https://melpa.org/#/inform7)

Note: There is also an [Inform 7 package in
nixpkgs](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/in/inform7/package.nix),
but this is outdated and uses a 2015 version of Inform 7 along with a
wrapper script.


## License

Copyright (C) 2025 by Niels G. W. Serup.

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero
General Public License for more details.
