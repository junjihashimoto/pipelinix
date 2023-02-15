{pkgs ? import <nixpkgs> {}}:
let lib = import ../../lib.nix {};
    processes = lib.pipeline pkgs (self: {
      pre-processing = {
        exec = ''
             echo "{\"a\":1, \"b\":2}" > $out/hello.json
        '';
      };
      main = input: {
        buildInputs = [ pkgs.jq ];
        exec = ''
              jq '.' < ${input}/hello.json > $out/hello.json;
        '';
      };
      post-processing = input: {
        exec = "sed -e 's/a/hello-world/g' < ${input}/hello.json > $out/hello.json";
      };
    });
in processes // {
  default = with processes; lib.compose [
    pre-processing
    main
    post-processing
  ];
}
