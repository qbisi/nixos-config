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
    targetHost = "hinlink-h88k";
    # buildOnTarget = true;
    tags = [
      "router"
      "dev"
    ];
  };

  imports = [
    "${inputs.nixos-images}/devices/aarch64-linux/nixos-hinlink-h88k.nix"
    self.nixosModules.router
    self.nixosModules.secrets
  ];

  networking = {
    hostName = "hinlink-h88k";
    bridges.br0.interfaces = [
      "eth1"
      "eth2"
    ];
    interfaces.br0.ipv4.addresses = [
      {
        address = "192.168.101.1";
        prefixLength = 24;
      }
    ];
  };

  system.stateVersion = "24.11";
}
