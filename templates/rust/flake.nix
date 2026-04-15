{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs = inputs: {
    template = context: let
      inherit (context) options;
      pkgs = import inputs.nixpkgs {
        inherit (context) system;
      };
    in
      pkgs.runCommand "template" {} ''
        mkdir -p $out
        cp -r ${./base}/. $out

        cd $out
        ${pkgs.cargo}/bin/cargo init --name $(cat ${pkgs.writeText "crate-name" context.name}) ${
          if (options.is_lib or false)
          then "--lib"
          else "--bin"
        }
        ${pkgs.git}/bin/git branch -m main
        ${
          if (!(options.disable_direnv or false))
          then ''
            echo 'use flake' >> .envrc
            echo -e '\n.direnv\n' >> .gitignore
          ''
          else ""
        }
      '';
  };
}
