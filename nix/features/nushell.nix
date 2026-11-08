{ den, ... }:
{
  den.aspects.nushell = {
    user =
      { pkgs, ... }:
      {
        shell = pkgs.nushell;
      };

    homeManager =
      {
        config,
        lib,
        osConfig,
        pkgs,
        ...
      }:
      let
        inherit (lib) concatStringsSep mapAttrsToList;
        env =
          ((removeAttrs osConfig.environment.variables [ "PATH" ]) // config.home.sessionVariables)
          |> mapAttrsToList (name: value: "$env.${name} = \"${value}\"")
          |> concatStringsSep "\n";
        checkoutPath = osConfig.environment.variables.NH_FLAKE;
        generatedEnv = pkgs.writeText "nushell-env.nu" (env + "\n" + (builtins.readFile ./nushell/env.nu));
      in
      {
        home.packages = [
          pkgs.nh
          pkgs.nushell
        ];

        home.activation.nushellEnv = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          $DRY_RUN_CMD ${pkgs.coreutils}/bin/ln -sfnT \
            ${lib.escapeShellArg generatedEnv} \
            ${lib.escapeShellArg "${checkoutPath}/nushell/env.nu"}
        '';

        programs.bat.syntaxes.nushell = {
          src = ./nushell;
          file = "nushell.sublime-syntax";
        };
      };
  };
}
