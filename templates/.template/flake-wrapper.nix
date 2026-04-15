{
  inputs = {
    template.url = ./template;
  };
  outputs = inputs: let
    context = builtins.fromJSON (builtins.readFile ./context.json);
  in {
    # TODO: avoid hardcoding the system
    packages.${context.system}.default = inputs.template.template context;
  };
}
