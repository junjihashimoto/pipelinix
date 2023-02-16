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
        mkPackage = pkgs: import ./pipelinix.nix { inherit pkgs; };
        
    in {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          pipelinix = mkPackage pkgs;
          yaml2pipeline = pkgs.callCabal2nix "yaml2pipeline" ./yaml2pipeline {};
        });
      defaultPackage = forAllSystems (system: self.packages.${system}.pipelinix);
      lib = import ./lib.nix;
  };
}
