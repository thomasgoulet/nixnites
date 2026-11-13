{ den, inputs, ... }:
let
  hostOptions =
    { lib, ... }:
    {
      options.host = {
        display = {
          output = lib.mkOption {
            type = lib.types.str;
            description = "Name of the primary display output.";
          };
          width = lib.mkOption {
            type = lib.types.int;
            description = "Width of the primary display in pixels.";
          };
          height = lib.mkOption {
            type = lib.types.int;
            description = "Height of the primary display in pixels.";
          };
          refreshRate = lib.mkOption {
            type = lib.types.int;
            description = "Refresh rate of the primary display in Hz.";
          };
          scale = lib.mkOption {
            type = lib.types.float;
            description = "Scale factor of the primary display.";
          };
        };

        keyboard = {
          layout = lib.mkOption {
            type = lib.types.str;
            description = "Comma-separated XKB layouts.";
          };
          variant = lib.mkOption {
            type = lib.types.str;
            description = "Comma-separated XKB variants, matching the layouts.";
          };
          options = lib.mkOption {
            type = lib.types.str;
            description = "Comma-separated XKB options.";
          };
        };
      };
    };
in
{
  den.aspects.headful = {

    includes = [
      den.aspects.greeter
      (den.batteries.unfree [
        "spotify"
        "zen-browser"
      ])
    ];

    nixos =
      { pkgs, ... }:
      {
        imports = [
          inputs.umbriel.nixosModules.default
          hostOptions
        ];

        hardware.graphics.enable = true;
        security.polkit.enable = true;

        programs.umbriel.enable = true;

        environment.sessionVariables = {
          NIXOS_OZONE_WL = 1;
        };

        environment.systemPackages = [
          # TODO - Remove alacritty after installing a better terminal emulator
          pkgs.alacritty

          pkgs.bitwarden-cli

          inputs.zen-browser.packages.${pkgs.system}.default
        ];

      };

    homeManager =
      {
        imports = [
          (inputs.import-tree ./headful)
          inputs.spicetify-nix.homeManagerModules.spicetify
          inputs.umbriel.homeModules.default
          inputs.noctalia.homeModules.default
        ];

        programs.spicetify = {
          enable = true;
          wayland = true;
        };

        programs.vesktop.enable = true;
        services.mpris-proxy.enable = true;
      };
  };
}
