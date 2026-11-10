{ mkContainer, hardening }:
{ lib, pkgs, ... }:
lib.mkMerge [
  (mkContainer "glance" {
    hostIp = "10.233.3.1";
    localIp = "10.233.3.2";
    module =
      { ... }:
      {
        networking.firewall.allowedTCPPorts = [ 8080 ];

        services.glance = {
          enable = true;
          settings = {
            server = {
              host = "10.233.3.2";
              port = 8080;
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
                      { type = "hacker-news"; }
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

        systemd.services.glance.serviceConfig = hardening // {
          CapabilityBoundingSet = "";
        };
      };
  })

  {
    systemd.services.glance-forward = {
      description = "Loopback TCP forwarder to the glance container";
      wantedBy = [ "multi-user.target" ];
      after = [ "container@glance.service" ];
      wants = [ "container@glance.service" ];
      serviceConfig = {
        ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:7777,bind=127.0.0.1,fork,reuseaddr TCP:10.233.3.2:8080";
        Restart = "always";
        RestartSec = 2;
      };
    };
  }
]
