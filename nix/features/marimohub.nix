{ den, ... }:
{
  den.aspects.marimohub = {
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
      let
        port = "8886";
        storageRoot = "/var/lib/marimohub";
        # marimohub 0.4.10
        hubImage = "ghcr.io/marimo-team/marimohub@sha256:e060d021d519d88941608cc7b4c51696008e7795d35fa91a859005e183900f2c";
        # marimo-sandbox py3.13-marimo0.25.2
        sandboxImage = "ghcr.io/marimo-team/marimo-sandbox@sha256:f72bfaa857701ac2d7154cc5e3dbd265b12cf04e08bfd9761b1d594d7015c8a0";
        docker = "${config.virtualisation.docker.package}/bin/docker";
        dockerCli = pkgs.runCommand "docker-static-cli-28.3.2" {
          src = pkgs.fetchurl {
            url = "https://download.docker.com/linux/static/stable/x86_64/docker-28.3.2.tgz";
            hash = "sha256-nSdKPzMHZOvZzIL+KeXdXQVpvDT59T46yJBURM2ItBM=";
          };
        } ''
          tar -xzf $src docker/docker
          install -Dm755 docker/docker $out/bin/docker
        '';
      in
      {
        systemd.tmpfiles.rules = [
          "d ${storageRoot} 0750 root root -"
          "d ${storageRoot}/storage 0750 root root -"
        ];

        virtualisation.oci-containers.containers.marimohub = {
          image = hubImage;
          environment = {
            PORT = port;
            MARIMOHUB_BIND_HOST = "127.0.0.1";
            MARIMOHUB_AUTH_BACKEND = "dev";
            MARIMOHUB_STORAGE_BACKEND = "fs";
            MARIMOHUB_STORAGE_FS_ROOT = "${storageRoot}/storage";
            MARIMOHUB_COMPUTE_BACKEND = "docker";
            MARIMOHUB_COMPUTE_IMAGE = sandboxImage;
            MARIMOHUB_COMPUTE_DOCKER_HOST = "localhost";
            MARIMOHUB_COMPUTE_DOCKER_BIND_HOST = "127.0.0.1";
            MARIMOHUB_COMPUTE_DOCKER_OWNER_TAG = "hub-local";
            MARIMOHUB_RUN_MAINTENANCE = "true";
          };
          volumes = [
            "/var/run/docker.sock:/var/run/docker.sock"
            "${dockerCli}/bin/docker:/usr/local/bin/docker:ro"
            "${storageRoot}:${storageRoot}"
          ];
          extraOptions = [ "--network=host" ];
        };

        systemd.services.docker-marimohub = {
          serviceConfig = {
            ExecStop = lib.mkForce "${docker} stop -t 140 marimohub";
            TimeoutStopSec = lib.mkForce 150;
          };
        };
      };
  };
}
