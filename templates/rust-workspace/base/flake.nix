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
        src = craneLib.cleanCargoSource root;
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

        rootCargoToml = builtins.fromTOML (builtins.readFile "${root}/Cargo.toml");

        localDeps = crate: let
          crateDeps = (builtins.fromTOML (builtins.readFile "${crate}/Cargo.toml")).dependencies or {};
          parsedDeps = lib.mapAttrs (_: dep:
            if lib.isAttrs dep && lib.hasAttr "path" dep
            then crate + "/${dep.path}"
            else null)
          crateDeps;
          deps = lib.filter (dep: dep != null) (lib.attrValues parsedDeps);
          recursiveDeps = (lib.concatMap localDeps deps) ++ deps;
        in
          recursiveDeps;

        requiredCrateFiles = let
          crates = rootCargoToml.workspace.members or [];
          files = lib.map (crate: root + "/${crate}/Cargo.toml") crates;
        in
          files;

        # TODO: generate dummy src/lib.rs for non-dependency crates
        fileSetForCrate = crate: let
          deps = localDeps crate;
          fileset = lib.fileset.unions ([
              (root + "/Cargo.toml")
              (root + "/Cargo.lock")
              (craneLib.fileset.commonCargoSources crate)
            ]
            ++ (lib.map craneLib.fileset.commonCargoSources deps) ++ requiredCrateFiles);
          src = lib.fileset.toSource {
            inherit root fileset;
          };
        in
          src;

        buildCrate = crate: let
          path = root + "/crates/${crate}";
        in
          craneLib.buildPackage (individualCrateArgs
            // {
              inherit (craneLib.crateNameFromCargoToml {src = path;}) pname version;
              src = fileSetForCrate path;
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
