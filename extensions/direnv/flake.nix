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

        cd $out

        if [ -f .envrc ]; then
          chmod +w .envrc
        fi
        echo 'use flake' >> .envrc

        if [ -f .gitignore ]; then
          chmod +w .gitignore
        fi
        echo -e '\n.direnv' >> .gitignore
      '';
  };
}
