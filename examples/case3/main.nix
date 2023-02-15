{pkgs ? import <nixpkgs> {}}:
let lib = import ../../lib.nix;
in lib.pipeline pkgs (self: {
  main = input: {
    buildInputs = [ pkgs.jq ];
    exec = ''
      jq '.' < ${input}/hello.json > $out/hello.json;
    '';
  };
})
