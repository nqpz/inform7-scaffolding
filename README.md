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

Run `inform7-init` with no arguments to create a new project.  This will
create two files: An empty `story.ni` and a `uuid.txt` containing an
UUID.

**Example use:** https://github.com/nqpz/kantinen2012
