{ lib, config, ... }:
{
  virtualisation = {
    podman.enable = true;
  };

  networking.firewall.allowedTCPPorts = [
    7892
  ];

  virtualisation.oci-containers.containers = {
    autoBangumi = {
      image = "ghcr.io/estrellaxd/auto_bangumi:latest";
      ports = [ "7892:7892" ];
      volumes = [
        "/var/lib/autobangumi/config:/app/config"
        "/var/lib/autobangumi/data:/app/data"
      ];
      environment = {
        UMASK = "022";
        PGID = toString config.users.groups.${config.users.users.qbittorrent.group}.gid;
        PUID = toString config.users.users.qbittorrent.uid;
      };
    };
  };
}
