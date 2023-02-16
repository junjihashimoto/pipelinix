{pkgs ? import <nixpkgs> {}
,lib ? import ../../lib.nix}:
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
