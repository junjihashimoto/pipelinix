{pkgs ? import <nixpkgs> {}}:
let lib = import ../../lib.nix;
in lib.pipeline pkgs (self: {
  pre-processing = {
    exec = ''
      echo "{\"a\":1, \"b\":2}" > $out/hello.json
    '';
  };
})
