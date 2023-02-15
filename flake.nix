{
  description = "Pipelinix";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs = { self, nixpkgs }:
    let systems = [ "x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
        forAllSystems = f: builtins.listToAttrs (map (name: { inherit name; value = f name; }) systems);
        mkPackage = pkgs: import ./pipelinix.nix { inherit pkgs; };
        
    in {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          pipelinix = mkPackage pkgs;
        });
      defaultPackage = forAllSystems (system: self.packages.${system}.pipelinix);
      lib = import ./lib.nix;
  };
}