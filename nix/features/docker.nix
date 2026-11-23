{ den, ... }:
{
  den.aspects.docker = {

    # TODO - This is most likely a security risk
    user = {
      extraGroups = [ "docker" ];
    };

    nixos =
      { lib, ... }:
      {
        virtualisation.oci-containers.backend = "docker";
        virtualisation.docker = {
          enable = true;
          daemon.settings = {
            userland-proxy = false;
            ip = "127.0.0.1";
          };
        };

        systemd.services.docker = {
          before = lib.mkForce [ "shutdown.target" ];
        };
      };

  };
}
