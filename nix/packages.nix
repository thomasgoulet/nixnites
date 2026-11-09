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
      packages = {
        helix = pkgs.symlinkJoin {
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
      }
      // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
        install = pkgs.writeShellApplication {
          name = "install";
          runtimeInputs = [
            pkgs.coreutils
            pkgs.git
            pkgs.nh
            pkgs.nix
          ];
          text = ''
            if [ "$#" -ne 2 ]; then
              echo "usage: nix run github:thomasgoulet/nixnites#install -- <host> <directory>" >&2
              exit 1
            fi

            host="$1"
            dir=$(realpath -m "$2")
            export NH_FLAKE="$dir"
            export NIX_CONFIG="extra-experimental-features = nix-command flakes pipe-operators"

            if [ -e "$dir" ]; then
              echo "error: $dir already exists" >&2
              exit 1
            fi

            git clone https://github.com/thomasgoulet/nixnites.git "$dir"
            nh os switch "$dir" --hostname "$host" --ask -- --impure
          '';
        };
      };
    };
}
