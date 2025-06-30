{
  pkgs,
  lib,
  config,
  ...
}:
{
  users.groups = {
    media = {
      gid = 991;
      members = [ config.users.users.admin.name ];
    };
    guest = { };
  };

  users.users = {
    guest = {
      group = "guest";
      isSystemUser = true;
    };
  };

  services.jellyfin = {
    group = "media";
    enable = true;
    openFirewall = true;
  };

  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    group = "media";
    port = 8080;
  };

  # services.sonarr = {
  #   enable = true;
  #   openFirewall = true;
  # };

  fileSystems = {
    "/srv/samba/private/data" = {
      device = "/data";
      options = [
        "bind"
        "nofail"
      ];
    };
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        "security" = "user";
        #"use sendfile" = "yes";
        #"max protocol" = "smb2";
        "hosts allow" = "172.16. 192.168.100. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      "public" = {
        "path" = "/srv/samba/public";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "guest";
        "force group" = "guest";
      };
      "private" = {
        "path" = "/srv/samba/private";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "qbisi";
        "force group" = "media";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
    interface = "eth1";
  };
}
