{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      lib,
      inputs',
      ...
    }:
    let
      hm = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs'; };
        modules = [
          {
            home.username = "nix";
            home.homeDirectory = "/homeless";
            home.stateVersion = "26.05";
            programs.helix.enable = true;
          }
          (inputs.import-tree ./features/editor)
        ];
      };

      helix = hm.config.programs.helix;
      toml = pkgs.formats.toml { };

      configFile = toml.generate "config.toml" (
        helix.settings
        // {
          editor = removeAttrs helix.settings.editor [ "shell" ];
        }
      );

      configDir = pkgs.linkFarm "helix-config" [
        {
          name = "helix/languages.toml";
          path = toml.generate "languages.toml" helix.languages;
        }
      ];
    in
    {
      packages.helix = pkgs.symlinkJoin {
        name = "helix";
        paths = [ helix.package ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        meta.mainProgram = "hx";
        postBuild = ''
          wrapProgram $out/bin/hx \
            --add-flags "-c ${configFile}" \
            --set XDG_CONFIG_HOME ${configDir} \
            --prefix PATH : ${lib.makeBinPath (hm.config.home.packages ++ [ pkgs.git ])}
        '';
      };
    };
}
