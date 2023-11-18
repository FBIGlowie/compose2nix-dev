# Auto-generated using compose2nix v0.1.5.
{ pkgs, lib, ... }:

{
  # Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  # Containers
  virtualisation.oci-containers.containers."myproject-sabnzbd" = {
    image = "lscr.io/linuxserver/sabnzbd:latest";
    environment = {
      TZ = "America/New_York";
    };
    volumes = [
      "/var/volumes/sabnzbd:/config:rw"
      "storage:/storage:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=sabnzbd"
      "--network=myproject-default"
    ];
  };
  systemd.services."docker-myproject-sabnzbd" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
      RuntimeMaxSec = lib.mkOverride 500 360;
    };
    unitConfig = {
      Description = lib.mkOverride 500 "This is the sabnzbd container!";
    };
    after = [
      "docker-network-myproject-default.service"
      "docker-volume-storage.service"
    ];
    requires = [
      "docker-network-myproject-default.service"
      "docker-volume-storage.service"
    ];
    partOf = [
      "docker-compose-myproject-root.target"
    ];
    wantedBy = [
      "docker-compose-myproject-root.target"
    ];
  };
  virtualisation.oci-containers.containers."radarr" = {
    image = "lscr.io/linuxserver/radarr:develop";
    environment = {
      TZ = "America/New_York";
    };
    volumes = [
      "/var/volumes/radarr:/config:rw"
      "storage:/storage:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=radarr"
      "--network=myproject-default"
    ];
  };
  systemd.services."docker-radarr" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "docker-network-myproject-default.service"
      "docker-volume-storage.service"
    ];
    requires = [
      "docker-network-myproject-default.service"
      "docker-volume-storage.service"
    ];
    partOf = [
      "docker-compose-myproject-root.target"
    ];
    wantedBy = [
      "docker-compose-myproject-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-myproject-default" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "${pkgs.docker}/bin/docker network rm -f myproject-default";
    };
    script = ''
      docker network inspect myproject-default || docker network create myproject-default
    '';
    partOf = [ "docker-compose-myproject-root.target" ];
    wantedBy = [ "docker-compose-myproject-root.target" ];
  };

  # Volumes
  systemd.services."docker-volume-storage" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect storage || docker volume create storage --opt=device=/mnt/media --opt=o=bind --opt=type=none
    '';
    partOf = [ "docker-compose-myproject-root.target" ];
    wantedBy = [ "docker-compose-myproject-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-myproject-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
