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
          daemon.settings.userland-proxy = false;
        };

        systemd.services.docker = {
          after = [ "multi-user.target" ];
          before = lib.mkForce [ "shutdown.target" ];
        };
      };

  };
}
