{ den, ... }:
{
  den.aspects.thomas = {

    includes = [
      den.batteries.primary-user
      den.aspects.catppuccin-mocha
      den.aspects.dashboard
      den.aspects.docker
      den.aspects.dotfiles
      den.aspects.excalidash
      den.aspects.infra
      den.aspects.notes
      den.aspects.opencode
      den.aspects.search
      den.aspects.terminal
    ];

  };
}
