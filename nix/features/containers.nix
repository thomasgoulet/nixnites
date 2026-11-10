{
  den,
  inputs,
  ...
}:
{
  den.aspects.containers = {
    nixos =
      { pkgs, ... }:
      let
        iptables = "${pkgs.iptables}/bin/iptables";
        rule = "POSTROUTING -s 10.233.0.0/16 ! -o ve-+ -j MASQUERADE";
        up = pkgs.writeShellScript "containers-nat-up" ''
          ${iptables} -w -t nat -C ${rule} 2>/dev/null || ${iptables} -w -t nat -A ${rule}
        '';
        down = pkgs.writeShellScript "containers-nat-down" ''
          ${iptables} -w -t nat -D ${rule} 2>/dev/null || true
        '';
      in
      {
        imports = [
          (inputs.import-tree ./containers)
        ];

        boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

        systemd.services.containers-nat = {
          description = "NAT for NixOs containers";
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
