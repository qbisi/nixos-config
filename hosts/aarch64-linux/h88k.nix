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

  boot = {
    kernelModules = [ "ledtrig-netdev" ];
  };

  system.activationScripts = {
    led-netdev = ''
      echo "wwan0" > /sys/class/leds/blue:net/device_name
      echo 1 > /sys/class/leds/blue:net/link
      echo 1 > /sys/class/leds/blue:net/rx
      echo 1 > /sys/class/leds/blue:net/tx
    '';
  };

  fileSystems = {
    "/gigatf" = {
      device = "/dev/disk/by-uuid/e64827a8-9986-42da-8364-a958dcd129d4";
      fsType = "f2fs";
      options = [
        "nofail"
        "x-systemd.wanted-by=dev-disk-by\\x2duuid-e64827a8\\x2d9986\\x2d42da\\x2d8364\\x2da958dcd129d4.device"
        "nodev"
        "noatime"
      ];
    };
    "/data" = {
      device = "/.data:/gigatf=RO";
      fsType = "mergerfs";
      options = [
        "nodev"
        "nofail"
        "cache.files=off"
        "dropcacheonclose=false"
        "category.create=mfs"
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
    upstreams = /.data x79:/gigatf:ro
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
    mergerfs
  ];

  nix.buildMachines = with self.vars.buildMachines; [
    ft
    x79
    mac
  ];

  system.stateVersion = "24.11";
}
