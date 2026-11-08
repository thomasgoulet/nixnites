{
  den,
  inputs,
  ...
}:
{
  den.hosts.x86_64-linux.yousuke = {
    users.thom.classes = [
      "user"
      "homeManager"
    ];
  };

  den.aspects.yousuke = {
    nixos.imports = [
      (inputs.import-tree ./yousuke)
    ];
  };
}
