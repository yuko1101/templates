{
  inputs = {
    src.url = ./src;
    extension.url = ./extension;
  };
  outputs = inputs: let
    context = builtins.fromJSON (builtins.readFile ./context.json);
    inherit (context) system;
  in {
    # TODO: avoid hardcoding the system
    packages.${system}.default = inputs.extension.extension inputs.src.packages.${system}.default context;
  };
}
