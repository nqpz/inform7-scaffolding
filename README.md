# Inform 7 scaffolding

This repository provides wrapper scripts around the [Inform 7 package in
nixpkgs](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/in/inform7/package.nix).

By default Inform 7 insists on creating lots of not-strictly-needed
files, also in $HOME, which I dislike.

It turns out that you only truly need two files: A `.ni` file which
contains the story, and a text file containing an UUID (presumably as a
way for each Inform 7 game in existence to have a unique ID - this gets
embedded into the final binary).

These scripts ensure that you can focus on your `.ni` story file without
having to consider all the other files, which the scripts instead put
into a subdirectory named `scaffolding`.

**Example use:** https://github.com/nqpz/kantinen2012


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
*.ulx
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

  - Run `inform7-run release.ulx` to run the release build.

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
