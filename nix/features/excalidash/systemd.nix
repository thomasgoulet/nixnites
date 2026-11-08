{
  lib,
  pkgs,
  ...
}:
{
  systemd.services.docker-excalidash-backend = {
    wants = lib.mkForce [ ];
    after = lib.mkForce [
      "docker.service"
      "docker.socket"
      "init-excalidash-network.service"
      "multi-user.target"
    ];
    before = lib.mkForce [ "shutdown.target" ];
    requires = [ "init-excalidash-network.service" ];
    serviceConfig.ExecStartPre = lib.mkBefore [
      "${pkgs.coreutils}/bin/rm -rf /var/lib/excalidash/.migration-lock"
    ];
  };

  systemd.services.docker-excalidash-frontend = {
    wants = lib.mkForce [ ];
    after = lib.mkForce [
      "docker.service"
      "docker.socket"
      "docker-excalidash-backend.service"
      "init-excalidash-network.service"
      "multi-user.target"
    ];
    before = lib.mkForce [ "shutdown.target" ];
    requires = [ "init-excalidash-network.service" ];
  };
}
