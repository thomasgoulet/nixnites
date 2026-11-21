{
  den,
  ...
}:
{
  den.aspects.excalidash = {
    includes = [
      den.aspects.docker
    ];

    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        virtualisation.oci-containers.containers = {
          excalidash-backend = {
            image = "zimengxiong/excalidash-backend@sha256:b77d43d9f70e414279e0babbbd59803086868e23148f071b8d65fb1e49bce836";
            environment = {
              DATABASE_URL = "file:/app/prisma/dev.db";
              PORT = "6768";
              NODE_ENV = "production";
              AUTH_MODE = "local";
              TRUST_PROXY = "false";
              FRONTEND_URL = "http://localhost:6767";
            };
            volumes = [ "/var/lib/excalidash:/app/prisma" ];
            extraOptions = [
              "--network=excalidash"
              "--network-alias=backend"
            ];
          };

          excalidash-frontend = {
            image = "zimengxiong/excalidash-frontend@sha256:0d1f4e852f052872b9a9f2e0267a7a0ba5ba3e0d2d097ad2d82371f6c3f0de2d";
            environment = {
              BACKEND_URL = "backend:6768";
            };
            ports = [ "127.0.0.1:6767:80" ];
            dependsOn = [ "excalidash-backend" ];
            extraOptions = [ "--network=excalidash" ];
          };
        };

        systemd.services.init-excalidash-network = {
          description = "Create the docker network shared by ExcaliDash containers";
          after = [ "docker.service" ];
          requires = [ "docker.service" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          path = [ config.virtualisation.docker.package ];
          script = ''
            docker network inspect excalidash >/dev/null 2>&1 || docker network create excalidash
          '';
        };

        systemd.services.docker-excalidash-backend = {
          after = [ "init-excalidash-network.service" ];
          requires = [ "init-excalidash-network.service" ];
          serviceConfig.ExecStartPre = lib.mkBefore [
            "${pkgs.coreutils}/bin/rm -rf /var/lib/excalidash/.migration-lock"
          ];
        };

        systemd.services.docker-excalidash-frontend = {
          after = [ "init-excalidash-network.service" ];
          requires = [ "init-excalidash-network.service" ];
        };
      };
  };
}
