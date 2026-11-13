{ inputs, lib, ... }:
let
  greeterOption = {
    options.stylix.greeter = lib.mkOption {
      type = lib.types.str;
      description = "Color scheme name for the noctalia greeter.";
    };
  };

  opencodeOption = {
    options.stylix.opencode = lib.mkOption {
      type = lib.types.str;
      description = "Theme name for opencode.";
    };
  };
in
{
  den.aspects.stylix = {
    nixos = {
      imports = [
        inputs.stylix.nixosModules.stylix
        greeterOption
      ];

      stylix = {
        enable = true;

        targets = {
          fontconfig.enable = true;
          glance.enable = true;
        };
      };
    };

    homeManager = {
      imports = [ opencodeOption ];

      stylix.targets = {
        alacritty.enable = true;
        broot.enable = true;
        lazygit.enable = true;
        noctalia.enable = true;
        spicetify.enable = true;
        vesktop.enable = true;
        zen-browser = {
          enable = true;
          profileNames = [ "Default Profile" ];
        };
      };
    };
  };
}
