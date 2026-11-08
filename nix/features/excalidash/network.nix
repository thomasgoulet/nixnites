{
  config,
  lib,
  ...
}:
{
  systemd.services.init-excalidash-network = {
    description = "Create the docker network shared by ExcaliDash containers";
    wants = lib.mkForce [ ];
    after = lib.mkForce [
      "docker.service"
      "docker.socket"
    ];
    requires = [ "docker.service" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    path = [ config.virtualisation.docker.package ];
    script = ''
      docker network inspect excalidash >/dev/null 2>&1 || docker network create excalidash
    '';
  };
}
