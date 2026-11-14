{ den, ... }:
{
  den.aspects.thom = {

    includes = [
      den.batteries.primary-user
      den.aspects.adblock
      den.aspects.dashboard
      den.aspects.gruvbox
      den.aspects.excalidash
      den.aspects.dotfiles
      den.aspects.headful
      den.aspects.notes
      den.aspects.opencode
      den.aspects.search
      den.aspects.terminal
    ];

  };
}
