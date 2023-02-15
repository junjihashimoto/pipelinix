{pkgs ? import <nixpkgs> {}}:
let lib = import ../../lib.nix;
in lib.pipeline pkgs (self: {
  post-processing = input: {
    exec = "sed -e 's/a/hello-world/g' < ${input}/hello.json > $out/hello.json";
  };
})
