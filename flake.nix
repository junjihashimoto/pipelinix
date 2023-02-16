{
  description = "Pipelinix";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, ... }:
    let systems = [ "x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
        forAllSystems = f: builtins.listToAttrs (map (name: { inherit name; value = f name; }) systems);
    in {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in rec {
          yaml2pipeline = pkgs.haskellPackages.callPackage ./yaml2pipeline {};
          pipelinix = import ./pipelinix.nix { inherit pkgs; inherit yaml2pipeline;};
        });
      defaultPackage = forAllSystems (system: self.packages.${system}.pipelinix);
      lib = import ./lib.nix;
  };
}
