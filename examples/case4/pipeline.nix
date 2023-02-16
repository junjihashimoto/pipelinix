{pkgs ? import <nixpkgs> {}
,lib ? (import (builtins.fetchTarball https://github.com/junjihashimoto/pipelinix/archive/2e04642a7230de1999fd1d8b4d0c31cd2b9534d4.tar.gz)).lib}:
lib.pipeline pkgs (self: {
  pre-processing = ''
    echo "{\"a\":1, \"b\":2}" > $out/hello.json
 '';
  main = input: ''
    ${pkgs.jq}/bin/jq '.' < ${input}/hello.json > $out/hello.json
  '';
  post-processing = input: ''
    sed -e 's/a/hello-world/g' < ${input}/hello.json > $out/hello.json
  '';
  main-with-pre-processing = self.main self.pre-processing;
  default = lib.compose [
    self.pre-processing
    self.main
    self.post-processing
  ];
})
