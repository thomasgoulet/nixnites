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
            if [ "$#" -ne 1 ]; then
              echo "usage: nix run github:thomasgoulet/nixnites#install -- <host>" >&2
              exit 1
            fi

            host="$1"
            export NIX_CONFIG="extra-experimental-features = nix-command flakes pipe-operators"
            config="github:thomasgoulet/nixnites#nixosConfigurations.$host.config"

            # shellcheck disable=SC2016
            users=$(nix eval --raw "$config.users.users" --apply '
              us: builtins.concatStringsSep "\n" (map (n: "''${n} ''${us.''${n}.home}")
                (builtins.filter (n: us.''${n}.isNormalUser) (builtins.attrNames us)))
            ') || {
              echo "error: could not find a nixos configuration for host '$host'" >&2
              exit 1
            }
            user_count=$(printf '%s\n' "$users" | sed '/^$/d' | wc -l)
            if [ "$user_count" -ne 1 ]; then
              echo "error: host '$host' must define exactly one normal user, found $user_count" >&2
              exit 1
            fi
            read -r user home <<< "$users"

            if [ "$(id -un)" != "$user" ]; then
              echo "error: run this as '$user' (found '$(id -un)')" >&2
              exit 1
            fi
            if [ ! -d "$home" ]; then
              echo "error: home directory $home does not exist; create the user first (sudo useradd -m $user)" >&2
              exit 1
            fi

            dir=$(nix eval --raw "$config.environment.variables.NH_FLAKE") || {
              echo "error: could not read NH_FLAKE for host '$host'" >&2
              exit 1
            }
            if [ -z "$dir" ]; then
              echo "error: host '$host' does not set NH_FLAKE" >&2
              exit 1
            fi

            export NH_FLAKE="$dir"

            if [ -e "$dir" ]; then
              echo "error: $dir already exists" >&2
              exit 1
            fi

            mkdir -p "$(dirname "$dir")"
            git clone https://github.com/thomasgoulet/nixnites.git "$dir"
            nh os switch "$dir" --hostname "$host" --ask
          '';
        };
      };
    };
}
