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
      homeManager = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs'; };
        modules = [
          {
            home.username = "nix";
            home.homeDirectory = "/homeless";
            home.stateVersion = "26.05";
            programs.helix = {
              enable = true;
              settings.theme = "catppuccin_mocha";
            };
          }
          ./features/editor/settings.nix
        ];
      };

      helix = homeManager.config.programs.helix;
      configFile = (pkgs.formats.toml { }).generate "config.toml" (
        helix.settings
        // {
          editor = removeAttrs helix.settings.editor [ "shell" ];
        }
      );
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
              --add-flags "-c ${configFile}"
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
