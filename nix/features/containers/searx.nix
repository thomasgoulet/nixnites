{ lib, pkgs, ... }:
{
  containers.searx = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.233.2.1";
    localAddress = "10.233.2.2";
    config =
      { ... }:
      {
        system.stateVersion = "26.05";

        networking.useHostResolvConf = false;
        networking.nameservers = [ "9.9.9.9" ];
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

        systemd.services.searx.serviceConfig = {
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectKernelLogs = true;
          ProtectControlGroups = true;
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_UNIX"
          ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          LockPersonality = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = [ "@system-service" ];
          CapabilityBoundingSet = lib.mkForce "";
        };
      };
  };

  systemd.services."container@searx".serviceConfig = {
    IPAddressAllow = [ "10.233.0.0/16" ];
    IPAddressDeny = [
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"
    ];
  };

  networking.hosts."127.0.0.1" = [ "searx.home.arpa" ];

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
