{ mkContainer, hardening }:
{ lib, pkgs, ... }:
lib.mkMerge [
  (mkContainer "searx" {
    hostIp = "10.233.2.1";
    localIp = "10.233.2.2";
    module =
      { lib, ... }:
      {
        networking.firewall.allowedTCPPorts = [ 8888 ];

        services.searx = {
          enable = true;
          settings = {
            server = {
              port = 8888;
              bind_address = "10.233.2.2";
              secret_key = "not-so-secret-is-it";
            };
            engines = [
              {
                name = "brave";
                disabled = true;
              }
              {
                name = "nixos wiki";
                disabled = false;
              }
              {
                name = "wikidata";
                disabled = true;
              }
            ];
          };
        };

        systemd.services.searx.serviceConfig = hardening // {
          CapabilityBoundingSet = lib.mkForce "";
        };
      };
  })

  {
    systemd.services.searx-forward = {
      description = "Loopback TCP forwarder to the searx container";
      wantedBy = [ "multi-user.target" ];
      after = [ "container@searx.service" ];
      wants = [ "container@searx.service" ];
      serviceConfig = {
        ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:8888,bind=127.0.0.1,fork,reuseaddr TCP:10.233.2.2:8888";
        Restart = "always";
        RestartSec = 2;
      };
    };
  }
]
