{ den, ... }:
{
  den.aspects.dotfiles.homeManager =
    {
      config,
      lib,
      osConfig,
      ...
    }:
    let
      flakePath = osConfig.environment.variables.NH_FLAKE;
      requiredDirectories = [
        "symlinks"
        "nushell"
      ];

      hasFlakeFile =
        (flakePath != "")
        && (lib.hasPrefix "/" flakePath)
        && (builtins.pathExists "${flakePath}/flake.nix");

      repositoryDirectories = if hasFlakeFile then builtins.readDir flakePath else { };

      hasRequiredDirectories =
        requiredDirectories |> builtins.all (name: (repositoryDirectories.${name} or null) == "directory");

      symlinkDirectories =
        if hasRequiredDirectories then
          (
            builtins.readDir "${flakePath}/symlinks"
            |> lib.filterAttrs (_: type: type == "directory")
            |> builtins.attrNames
          )
        else
          [ ];

    in
    {
      assertions = [
        {
          assertion = hasFlakeFile;
          message = ''
            NH_FLAKE must be an absolute local path to this repository's root directory.
            Set NH_FLAKE to <repository path> and evaluate with --impure.
          '';
        }
        {
          assertion = hasRequiredDirectories;
          message = ''
            NH_FLAKE must contain `symlinks` and `nushell`
          '';
        }
      ];

      xdg.configFile =
        (lib.genAttrs symlinkDirectories (name: {
          source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/symlinks/${name}";
        }))
        // {
          nushell.source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/nushell";
        };
    };
}
