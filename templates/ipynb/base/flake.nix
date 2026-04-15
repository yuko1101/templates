{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
        custom-python = pkgs.python3.withPackages (
          ps:
            with ps; [
              jupyter
            ]
        );
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            custom-python
          ];
        };
      }
    );
}
