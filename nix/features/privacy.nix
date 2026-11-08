{ den, ... }:
{
  den.aspects.privacy = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.searxng
        ];

        services.searx = {
          enable = true;
          settings = {
            server = {
              port = 8888;
              bind_address = "127.0.0.1";
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

        services.blocky = {
          enable = true;
          settings = {
            ports.dns = [
              "127.0.0.1:53"
              "[::1]:53"
            ];

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

        networking.nameservers = [
          "127.0.0.1"
          "::1"
        ];

        networking.networkmanager.insertNameservers = [ "127.0.0.1" ];
        services.resolved.enable = false;
      };
  };
}
