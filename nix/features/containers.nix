{ den, ... }:
{
  den.aspects.containers = {
    nixos =
      { lib, pkgs, ... }:
      let
        iptables = "${pkgs.iptables}/bin/iptables";
        rule = "POSTROUTING -s 10.233.0.0/16 ! -o ve-+ -j MASQUERADE";
        up = pkgs.writeShellScript "containers-nat-up" ''
          ${iptables} -w -t nat -C ${rule} 2>/dev/null || ${iptables} -w -t nat -A ${rule}
        '';
        down = pkgs.writeShellScript "containers-nat-down" ''
          ${iptables} -w -t nat -D ${rule} 2>/dev/null || true
        '';

        dir = ./containers;
        files = lib.filter (lib.hasSuffix ".nix") (builtins.attrNames (builtins.readDir dir));

        hardening = {
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
        };

        mkContainer =
          name:
          {
            hostIp,
            localIp,
            module,
          }:
          {
            containers.${name} = {
              autoStart = true;
              privateNetwork = true;
              hostAddress = hostIp;
              localAddress = localIp;
              config = {
                imports = [ module ];
                system.stateVersion = "26.05";
                networking.useHostResolvConf = false;
                networking.nameservers = [ "9.9.9.9" ];
              };
            };

            systemd.services."container@${name}".serviceConfig = {
              IPAddressAllow = [ "10.233.0.0/16" ];
              IPAddressDeny = [
                "10.0.0.0/8"
                "172.16.0.0/12"
                "192.168.0.0/16"
              ];
            };
          };
      in
      {
        imports = map (f: import (dir + "/${f}") { inherit mkContainer hardening; }) files;

        boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

        systemd.services.containers-nat = {
          description = "NAT for privacy containers";
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = up;
            ExecStop = down;
          };
        };
      };
  };
}
