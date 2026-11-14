{ den, ... }:
{
  den.aspects.rosepine = {

    includes = [
      den.aspects.stylix
    ];

    nixos =
      { pkgs, config, ... }:
      let
        koi = import ../../resources/wallpaper/koi {
          inherit pkgs;
          colors = config.lib.stylix.colors.withHashtag;
        };
      in
      {
        stylix = {
          greeter = "Rosé Pine";

          autoEnable = false;

          base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
          override.base10 = "16141f";
          image = koi;

          cursor = {
            package = pkgs.bibata-cursors;
            name = "Bibata-Modern-Classic";
            size = 24;
          };

          fonts = {
            monospace = {
              package = pkgs.nerd-fonts.caskaydia-cove;
              name = "CaskaydiaCove Nerd Font";
            };
            sansSerif = {
              package = pkgs.nerd-fonts.caskaydia-cove;
              name = "CaskaydiaCove Nerd Font";
            };
          };
        };
      };

    homeManager = {
      stylix.opencode = "rosepine";

      programs = {
        bat.config.theme = "base16";
        git.settings.delta.syntax-theme = "base16";
        helix.settings.theme = "rose_pine";
        herdr.settings.theme.name = "rose-pine";
      };

      stylix = {
        autoEnable = false;
      };
    };
  };
}
