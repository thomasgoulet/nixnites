{
  den,
  inputs,
  ...
}:
{
  den.aspects.editor = {
    homeManager = {
      imports = [
        (inputs.import-tree ./editor)
      ];

      config.programs.helix.enable = true;

      config.home.sessionVariables = {
        EDITOR = "hx";
      };
    };
  };
}
