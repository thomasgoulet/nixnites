{ ... }:
{
  containers.blocky = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.233.1.1";
    localAddress = "10.233.1.2";
    config =
      { ... }:
      {
        system.stateVersion = "26.05";

        networking.useHostResolvConf = false;
        networking.nameservers = [ "9.9.9.9" ];
        networking.firewall.allowedTCPPorts = [ 53 ];
        networking.firewall.allowedUDPPorts = [ 53 ];

        services.blocky = {
          enable = true;
          settings = {
            ports.dns = [ "10.233.1.2:53" ];

            upstreams = {
              groups.default = [
                "https://one.one.one.one/dns-query"
                "https://dns.quad9.net/dns-query"
                "https://dns.google/dns-query"
              ];
              strategy = "parallel_best";
              timeout = "2s";
            };

            bootstrapDns = {
              upstream = "https://one.one.one.one/dns-query";
              ips = [
                "1.1.1.1"
                "1.0.0.1"
                "9.9.9.9"
              ];
            };

            blocking = {
              denylists.ads = [
                "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
                "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt"
              ];
              clientGroupsBlock.default = [ "ads" ];
              blockType = "zeroIp";
            };

            caching = {
              minTime = "5m";
              maxTime = "30m";
              prefetching = true;
            };

            log.level = "info";
          };
        };

        systemd.services.blocky.serviceConfig = {
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
          AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
          CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        };
      };
  };

  systemd.services."container@blocky".serviceConfig = {
    IPAddressAllow = [ "10.233.0.0/16" ];
    IPAddressDeny = [
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"
    ];
  };
}
