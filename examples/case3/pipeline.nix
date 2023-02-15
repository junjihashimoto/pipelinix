{pkgs ? import <nixpkgs> {}}:
let lib = import ../../lib.nix;
    processes =
      import ./pre-processing.nix {} //
      import ./main.nix {} //
      import ./post-processing.nix {};
in with processes; lib.compose [pre-processing main post-processing]
