{ den, inputs, ... }:
{
  den.hosts.x86_64-linux.oric = {
    wsl.enable = true;

    users.thomas.classes = [
      "user"
      "homeManager"
    ];
  };

  den.aspects.oric = {
    nixos.imports = [
      (inputs.import-tree ./oric)
    ];
  };
}
