{pkgs ? import <nixpkgs> {}}:
let lib = import ../../lib.nix;
in lib.pipeline pkgs (self: {
  pre-processing = {
    exec = ''
      echo "{\"a\":1, \"b\":2}" > $out/hello.json
    '';
  };
  main = {
    buildInputs = [ pkgs.jq ];
    exec = ''
      jq '.' < ${self.pre-processing}/hello.json > $out/hello.json;
    '';
  };
  post-processing = {
    exec = "sed -e 's/a/hello-world/g' < ${self.main}/hello.json > $out/hello.json";
  };
})
