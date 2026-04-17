{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs = inputs: {
    extension = src: context: let
      pkgs = import inputs.nixpkgs {
        inherit (context) system;
      };
    in
      pkgs.runCommand "template" {
        buildInputs = [ pkgs.git ];
      } ''
        mkdir -p $out
        cp -r ${src}/. $out

        cd $out

        git init -b main
      '';
  };
}
