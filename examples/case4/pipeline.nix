{pkgs ? import <nixpkgs> {}}:
let lib = import ../../lib.nix {};
    processes = lib.pipeline pkgs (self: {
      pre-processing = ''
        echo "{\"a\":1, \"b\":2}" > $out/hello.json
     '';
      main = input: ''
        ${pkgs.jq}/bin/jq '.' < ${input}/hello.json > $out/hello.json;
      '';
      post-processing = input: ''
        sed -e 's/a/hello-world/g' < ${input}/hello.json > $out/hello.json
      '';
    });
in processes // {
  default = with processes; lib.compose [
    pre-processing
    main
    post-processing
  ];
}
