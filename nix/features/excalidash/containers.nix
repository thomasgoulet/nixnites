{ ... }:
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
        FRONTEND_URL = "http://localhost:6767,http://0.0.0.0:6767";
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
      ports = [ "6767:80" ];
      dependsOn = [ "excalidash-backend" ];
      extraOptions = [ "--network=excalidash" ];
    };
  };
}
