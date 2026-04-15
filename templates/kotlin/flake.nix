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

        export SRC_DIR=$out/src/main/kotlin/${pkgs.lib.replaceStrings ["."] ["/"] options.group_id}/${options.artifact_id}
        mkdir -p $SRC_DIR
        cp -r ${./src}/. $SRC_DIR

        # TODO: replace placeholders (group_id, artifact_id)
      '';
  };
}
