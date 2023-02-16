{
  description = "Pipelinix";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs = { self, nixpkgs }:
    let systems = [ "x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
        forAllSystems = f: builtins.listToAttrs (map (name: { inherit name; value = f name; }) systems);
    in {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./pipeline.nix { inherit pkgs; });
      defaultPackage = forAllSystems (system: self.packages.${system}.post-processing);
  };
}
