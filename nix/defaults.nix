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

  den = {
    schema.host.includes = [ den.batteries.user-aspects ];

    default = {
      includes = [
        den.batteries.define-user
        den.batteries.hostname
        den.batteries.inputs'
        den.batteries.self'
      ];

      nixos =
        { ... }:
        {
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
  };
}
