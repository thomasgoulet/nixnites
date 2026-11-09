{
  den,
  ...
}:
{
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];

  den.default = {
    includes = [
      den.batteries.define-user
      den.batteries.hostname
      den.batteries.inputs'
      den.batteries.self'
    ];

    nixos =
      { ... }:
      {
        # Run `nh` with `NH_FLAKE=<path to this repo>` during first activation
        environment.variables.NH_FLAKE = builtins.getEnv "NH_FLAKE";

        system.stateVersion = "26.05";

        nix.gc = {
          automatic = true;
          persistent = true;
          dates = "Fri *-*-* 06:00:00";
          options = "--delete-older-than 7d";
        };

        nix.settings = {
          auto-optimise-store = true;
          experimental-features = [
            "pipe-operators"
            "nix-command"
            "flakes"
          ];
        };

        home-manager = {
          backupFileExtension = "backup";
          useGlobalPkgs = true;
          useUserPackages = true;
        };
      };

    homeManager =
      { ... }:
      {
        home.stateVersion = "26.05";
      };
  };
}
