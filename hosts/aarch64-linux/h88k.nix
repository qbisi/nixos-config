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
    "${self}/nixos/config/apps/obs-studio.nix"
  ];

  hardware = {
    deviceTree.dtsFile = lib.mkForce ./dts/rk3588-hinlink-h88k.dts;
  };

  powerManagement.enable = false;

  disko.profile.partLabel = "nvme";

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

  services.onedrive.enable = true;

  environment.systemPackages = with pkgs; [
    minicom
  ];

  nix.buildMachines = with self.vars.buildMachines; [
    ft
    x79
    mac
  ];

  system.stateVersion = "24.11";
}
