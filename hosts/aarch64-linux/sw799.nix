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
    targetHost = "192.168.100.108";
    # targetHost = "sw799";
    # buildOnTarget = true;
    tags = [
      "router"
      "dev"
    ];
  };

  imports = [
    "${inputs.nixos-images}/devices/aarch64-linux/nixos-bozz-sw799.nix"
    self.nixosModules.router
    self.nixosModules.secrets
  ];

  disko.profile.partLabel = "mmc";

  hardware.firmware = [ pkgs.linux-firmware ];

  networking = {
    hostName = "sw799";
    modemmanager.enable = lib.mkForce false;
    bridges.br0.interfaces = [ ];
    interfaces.br0.ipv4.addresses = lib.mkForce [
      {
        address = "192.168.101.1";
        prefixLength = 24;
      }
    ];
    networkmanager.ensureProfiles.profiles = {
      wwan0 = lib.mkDefault {
        connection = {
          id = "wwan0";
          interface-name = "wwan0";
          type = "ethernet";
        };
        ipv4 = {
          method = "auto";
        };
        ipv6 = {
          method = "auto";
        };
      };
    };
  };

  systemd.network.links."10-wwan0" = {
    matchConfig.Driver = "rndis_host";
    linkConfig.Name = "wwan0";
  };

  system.stateVersion = "24.11";
}
