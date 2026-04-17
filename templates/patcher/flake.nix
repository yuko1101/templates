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
        substituteInPlace $out/.gitmodules --replace "%UPSTREAM_URL%" "${options.upstream}"

        mkdir -p $out/patches
      '';
  };
}
