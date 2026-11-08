{ den, ... }:
{
  den.aspects.thomas = {

    includes = [
      den.batteries.primary-user
      den.aspects.docker
      den.aspects.dotfiles
      den.aspects.excalidash
      den.aspects.infra
      den.aspects.notes
      den.aspects.opencode
      den.aspects.terminal
    ];

  };
}
