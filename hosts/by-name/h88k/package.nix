{
  config,
  pkgs,
  lib,
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
    "${inputs.nixos-images}/devices/by-name/nixos-hinlink-h88k.nix"
    "${self}/config/router.nix"
    "${self}/config/desktop.nix"
    "${self}/config/nas.nix"
    "${self}/config/nettools.nix"
    ./web
  ];

  hardware = {
    deviceTree.dtsFile = lib.mkForce ./rk3588-hinlink-h88k.dts;
  };

  disko.bootImage.partLabel = "nvme";

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

  networking = {
    hostName = "h88k";
    bridges.br0.interfaces = [
      "eth1"
      "eth2"
    ];
    nat.internalInterfaces = [ "wg0" ];
    defaultGateway = {
      address = "172.16.4.254";
      interface = "eth0";
      metric = 100;
    };
    interfaces = {
      eth0.ipv4 = {
        addresses = [
          {
            address = self.vars.hosts.h88k.ip;
            prefixLength = 23;
          }
        ];
        routes = [
          {
            address = "10.0.0.0";
            via = "172.16.4.254";
            prefixLength = 12;
          }
          {
            address = "172.16.0.0";
            prefixLength = 16;
            via = "172.16.4.254";
          }
        ];
      };
    };
  };

  services = {
    vlmcsd = {
      enable = true;
      disconnectClients = true;
      openFirewall = true;
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
