{ den, ... }:
{
  den.aspects.catppuccin = {

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
          greeter = "Catppuccin";

          autoEnable = false;

          base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
          override.base10 = "181825";
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
      stylix.opencode = "catppuccin";

      programs = {
        bat.config.theme = "Catppuccin Mocha";
        git.settings.delta.syntax-theme = "Catppuccin Mocha";
        helix.settings.theme = "catppuccin_mocha";
        herdr.settings.theme.name = "catppuccin";
      };

      stylix = {
        autoEnable = false;
      };
    };
  };
}
