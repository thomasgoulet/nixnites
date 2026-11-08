{ den, inputs, ... }:
{
  den.aspects.headful = {

    includes = [
      (den.batteries.unfree [
        "spotify"
        "spicetify-catppuccin"
        "zen-browser"
      ])
    ];

    nixos =
      { pkgs, ... }:
      {
        imports = [
          inputs.niri.nixosModules.niri
        ];

        hardware.graphics.enable = true;
        security.polkit.enable = true;
        systemd.user.services.niri-flake-polkit.enable = false;

        programs.niri = {
          enable = true;
          package = inputs.niri.packages.${pkgs.system}.niri-unstable;
        };

        environment.sessionVariables = {
          NIXOS_OZONE_WL = 1;
        };

        environment.systemPackages = [
          # TODO - Remove alacritty after installing a better terminal emulator
          pkgs.alacritty

          pkgs.bibata-cursors
          pkgs.bitwarden-cli
          pkgs.noctalia
          pkgs.xwayland-satellite

          inputs.zen-browser.packages.${pkgs.system}.default
        ];

      };

    homeManager =
      { pkgs, ... }:
      let
        spicetify-pkg = inputs.spicetify-nix.legacyPackages.${pkgs.system};
        spicetify-module = inputs.spicetify-nix.homeManagerModules.spicetify;
      in
      {
        imports = [
          (inputs.import-tree ./headful)
          spicetify-module
        ];

        programs.spicetify = {
          enable = true;
          theme = spicetify-pkg.themes.catppuccin;
          colorScheme = "mocha";
          wayland = true;
        };

        programs.vesktop.enable = true;
        services.mpris-proxy.enable = true;
      };
  };
}
