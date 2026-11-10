{ den, ... }:
{
  den.aspects.dashboard = {
    nixos =
      { lib, pkgs, ... }:
      let
        runtimeFile = "/run/glance/glance.yaml";
        overrideFile = "/home/thomas/.config/glance/glance.yml";
        mergeScript = pkgs.writeShellScript "glance-merge-override" ''
          set -euo pipefail
          [ -f ${overrideFile} ] || exit 0
          tmp=$(mktemp)
          trap 'rm -f "$tmp"' EXIT
          ${lib.getExe pkgs.yq-go} eval-all -o=json '. as $i ireduce ({}; . *+ $i)' \
            ${runtimeFile} ${overrideFile} > "$tmp"
          cat "$tmp" > ${runtimeFile}
        '';
      in
      {
        systemd.services.glance.serviceConfig.ExecStartPre = lib.mkAfter [ "+${mergeScript}" ];

        services.glance = {
          enable = true;
          settings = {
            server = {
              port = 8887;
              bind_address = "127.0.0.1";
            };
            theme = {
              background-color = "240 21 15";
              primary-color = "217 92 76";
              positive-color = "115 54 76";
              negative-color = "343 81 75";
            };
            pages = [
              {
                name = "Home";
                head-widgets = [
                  {
                    type = "search";
                    search-engine = "http://127.0.0.1:8888/search?q={QUERY}";
                  }
                ];
                columns = [
                  {
                    size = "small";
                    widgets = [
                      { type = "clock"; }
                      { type = "calendar"; }
                      {
                        type = "weather";
                        units = "metric";
                        hour-format = "24h";
                        location = "Quebec, Canada";
                      }
                    ];
                  }
                  {
                    size = "full";
                    widgets = [
                      {
                        type = "bookmarks";
                        groups = [
                          {
                            title = "Search";
                            links = [
                              {
                                title = "SearXNG";
                                url = "http://localhost:8888";
                              }
                              {
                                title = "NixOS Packages";
                                url = "https://search.nixos.org/packages";
                              }
                              {
                                title = "Home Manager Options";
                                url = "https://home-manager-options.extranix.com/";
                              }
                            ];
                          }
                        ];
                      }
                      {
                        type = "releases";
                        cache = "1h";
                        repositories = [
                          "nushell/nushell"
                          "helix-editor/helix"
                          "herdrdev/herdr"
                          "anomalyco/opencode"
                          "jesseduffield/lazygit"
                          "Canop/broot"
                          "kubernetes/kubernetes"
                          "hashicorp/terraform"
                        ];
                      }
                    ];
                  }
                ];
              }
            ];
          };
        };
      };
  };
}
