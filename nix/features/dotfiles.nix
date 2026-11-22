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
      symlinkDirectories = [ "nix" ];
      nushellFiles = [
        "aliases.nu"
        "config.nu"
        "modules"
        "scripts"
        "tools"
      ];
      outOfStore = path: {
        source = config.lib.file.mkOutOfStoreSymlink "${flakePath}/${path}";
      };
    in
    {
      xdg.configFile = lib.listToAttrs (
        map (name: lib.nameValuePair "nushell/${name}" (outOfStore "nushell/${name}")) nushellFiles
        ++ map (name: lib.nameValuePair name (outOfStore "symlinks/${name}")) symlinkDirectories
      );
    };
}
