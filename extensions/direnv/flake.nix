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
      pkgs.runCommand "template" {} ''
        mkdir -p $out
        cp -r ${src}/. $out

        echo 'use flake' >> $out/.envrc
        echo -e '\n.direnv\n' >> $out/.gitignore
      '';
  };
}
