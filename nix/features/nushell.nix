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

        envToString =
          name: value:
          if builtins.isString value || builtins.isPath value || builtins.isInt value then
            toString value
          else if builtins.isList value then
            concatStringsSep ":" (map (envToString name) value)
          else
            throw "nushell: environment variable ${name} has unsupported type ${builtins.typeOf value}";

        env =
          ((removeAttrs osConfig.environment.variables [ "PATH" ]) // config.home.sessionVariables)
          |> mapAttrsToList (name: value: "$env.${name} = \"${envToString name value}\"")
          |> concatStringsSep "\n";

        generatedEnv = pkgs.writeText "nushell-env.nu" (env + "\n" + (builtins.readFile ./nushell/env.nu));
      in
      {
        home.packages = [
          pkgs.nh
          pkgs.nushell
        ];

        xdg.configFile."nushell/env.nu".source = generatedEnv;

        programs.bat.syntaxes.nushell = {
          src = ./nushell;
          file = "nushell.sublime-syntax";
        };
      };
  };
}
