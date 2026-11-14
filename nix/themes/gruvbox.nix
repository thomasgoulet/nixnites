{ den, ... }:
{
  den.aspects.gruvbox = {

    includes = [
      den.aspects.stylix
    ];

    nixos =
      { pkgs, ... }:
      {
        stylix = {
          greeter = "Gruvbox";
          autoEnable = false;

          base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
          override.base10 = "191c1d";
          image = ../../resources/wallpaper/gruvbox.png;

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
      stylix.opencode = "gruvbox";

      programs = {
        bat.config.theme = "gruvbox-dark";
        git.settings.delta.syntax-theme = "gruvbox-dark";
        helix.settings.theme = "gruvbox_dark_hard";
        herdr.settings.theme.name = "gruvbox-dark";
      };

      stylix = {
        autoEnable = false;
      };
    };
  };
}
