{
  den,
  inputs,
  ...
}:
{
  den.aspects.excalidash = {
    includes = [
      den.aspects.docker
    ];

    nixos = {
      imports = [
        (inputs.import-tree ./excalidash)
      ];
    };
  };
}
