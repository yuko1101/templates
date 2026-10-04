{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane.url = "github:ipetkov/crane";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    rust-overlay,
    crane,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [rust-overlay.overlays.default];
        };
        lib = pkgs.lib;

        custom-rust-bin = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
        craneLib = (crane.mkLib pkgs).overrideToolchain custom-rust-bin;

        root = ./.;
        src = lib.fileset.toSource {
          inherit root;
          fileset = lib.fileset.unions [
            (craneLib.fileset.commonCargoSources root)
          ];
        };

        commonArgs = {
          inherit src;
          strictDeps = true;
          buildInputs = [];
        };
        cargoArtifacts = craneLib.buildDepsOnly (commonArgs
          // {
            pname = "deps";
            version = "0.0.0";
          });
        individualCrateArgs =
          commonArgs
          // {
            inherit cargoArtifacts;
          };

        buildCrate = crate: let
          path = root + "/crates/${crate}";
        in
          craneLib.buildPackage (individualCrateArgs
            // {
              inherit src;
              inherit (craneLib.crateNameFromCargoToml {src = path;}) pname version;
              cargoExtraArgs = "-p ${crate}";
            });
      in {
        devShells.default = pkgs.mkShell {
          packages = [
            custom-rust-bin
          ];
        };

        packages = {
          # default = buildCrate "default";
        };
      }
    );
}
