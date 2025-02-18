{
  config,
  pkgs,
  lib,
  modulesPath,
  self,
  inputs,
  ...
}:
{
  deployment = {
    tags = [
      "builder"
      "dev"
    ];
    buildOnTarget = true;
  };

  imports = [
    "${inputs.nixos-images}/devices/x86_64-linux/nixos-x86_64-uefi.nix"
    self.nixosModules.secrets
    ../../nixos/config/nettools.nix
  ];

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
  };

  boot = {
    kernelParams = [
      "console=tty1"
    ];
    kernelModules = [ "kvm-intel" ];
    initrd.availableKernelModules = [
      "ehci_pci"
      "ahci"
      "mpt3sas"
      "xhci_pci"
      "usbhid"
      "sd_mod"
      "sr_mod"
    ];
  };

  networking = {
    hostName = "x79";
    proxy.default = "http://${self.vars.hostIP.h88k}:1080";
    firewall.allowedTCPPorts = [
      7892
    ];
  };

  environment = {
    systemPackages = with pkgs; [
      lm_sensors
    ];
  };

  virtualisation = {
    docker.enable = true;
    podman = {
      enable = true;
      # dockerCompat = true;
    };
  };

  users.users.admin.extraGroups = [ "podman" "docker" ];

  # virtualisation.oci-containers.containers = {
  #   autoBangumi = {
  #     image = "ghcr.io/estrellaxd/auto_bangumi:latest";
  #     ports = [ "7892:7892" ];
  #     volumes = [
  #       "/var/lib/autobangumi/config:/app/config"
  #       "/var/lib/autobangumi/data:/app/data"
  #     ];
  #     environment = {
  #       UMASK = "022";
  #       PGID = toString config.users.groups.${config.users.users.qbittorrent.group}.gid;
  #       PUID = toString config.users.users.qbittorrent.uid;
  #     };
  #   };
  # };

  users.groups = {
    media = {
      gid = 991;
      members = [ "qbisi" ];
    };
    guest = { };
  };

  users.users = {
    guest = {
      group = "guest";
      isSystemUser = true;
    };
  };

  systemd.services.jellyfin.environment = {
    http_proxy = "http://172.16.4.100:1080";
    https_proxy = "http://172.16.4.100:1080";
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

  fileSystems = {
    "/data" = {
      device = "/dev/disk/by-uuid/b599ceb0-36ac-4309-98e0-ad37fca219e5";
      fsType = "btrfs";
      options = [
        "nofail"
      ];
    };
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
        # note: localhost is the ipv6 localhost ::1
        "hosts allow" = "172.16. 192.168.0. 127.0.0.1 localhost";
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

  nix.buildMachines = with self.vars.buildMachines; [
    ft
    mac
  ];

  system.stateVersion = "24.11";
}
