{ mkContainer, hardening }:
{ ... }:
mkContainer "blocky" {
  hostIp = "10.233.1.1";
  localIp = "10.233.1.2";
  module =
    { ... }:
    {
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

      systemd.services.blocky.serviceConfig = hardening // {
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      };
    };
}
