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
    buildOnTarget = true;
    tags = [
      "router"
      "dev"
    ];
  };

  imports = [
    "${inputs.nixos-images}/devices/aarch64-linux/nixos-hinlink-h88k.nix"
    self.nixosModules.router
    self.nixosModules.secrets
    self.nixosModules.desktop
    "${self}/nixos/config/nas.nix"
  ];

  hardware = {
    deviceTree.dtsFile = lib.mkForce ./dts/rk3588-hinlink-h88k.dts;
  };

  disko.profile.partLabel = "nvme";

  fileSystems = {
    "/.gigatf" = {
      device = "/dev/disk/by-uuid/e64827a8-9986-42da-8364-a958dcd129d4";
      fsType = "f2fs";
      options = [
        "nofail"
        "x-systemd.automount"
        "nodev"
        "noatime"
      ];
    };
    "/data" = {
      device = "data:";
      fsType = "rclone";
      options = [
        "nodev"
        "nofail"
        "allow_other"
        "args2env"
        "config=/etc/rclone-mnt.conf"
      ];
    };
  };

  system.activationScripts = {
    mergerfs = {
      text = ''
        mkdir -p /.data
      '';
    };
  };

  environment.etc."rclone-mnt.conf".text = ''
    [x79]
    type = sftp
    host = ${self.vars.hostIP.x79}
    user = root
    key_file = ${config.age.secrets.id_ed25519.path}

    [data]
    type = union
    action_policy = all
    create_policy = all
    search_policy = ff
    upstreams = /.data x79:/.gigatf:ro
  '';

  networking = {
    hostName = "h88k";
    bridges.br0.interfaces = [
      "eth1"
      "eth2"
    ];
    networkmanager.ensureProfiles.profiles = {
      eth0 = {
        connection = {
          id = "eth0";
          interface-name = "eth0";
          type = "ethernet";
        };
        ipv4 = {
          address1 = "${self.vars.hostIP.h88k}/23,172.16.4.254";
          dns = "223.5.5.5;";
          method = "manual";
          route1 = "172.16.0.0/12,172.16.4.254";
        };
        ipv6 = {
          method = "auto";
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    minicom
    rclone
  ];

  nix.buildMachines = with self.vars.buildMachines; [
    ft
    x79
    mac
  ];

  system.stateVersion = "24.11";
}
