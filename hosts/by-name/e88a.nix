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
    tags = [
      "router"
      "dev"
    ];
  };

  imports = [
    "${inputs.nixos-images}/devices/by-name/nixos-jwipc-e88a.nix"
  ];

  disko.bootImage.partLabel = "nvme";

  hardware = {
    deviceTree.dtsFile = lib.mkForce "${self}/dts/rk3588-jwipc-e88a.dts";
  };

  networking = {
    domain = null;
    hostName = "e88a";
    networkmanager.enable = true;
    firewall.allowedUDPPorts = [
      5355 # LLMNR
    ];
    bridges.br0.interfaces = [ "eth1" ];
    interfaces.br0.ipv4.addresses = lib.mkForce [
      {
        address = "192.168.101.1";
        prefixLength = 24;
      }
    ];
    nat = {
      enable = true;
      internalInterfaces = [
        "br0"
        "wg0"
      ];
      externalInterfaces = [
        "wwan0"
        "eth0"
      ];
    };
  };

  systemd.slices."user-1000".sliceConfig = {
    CPUQuota = "600%";
    MemoryMax = "6G";
  };

  environment.systemPackages = with pkgs; [
    rkdeveloptool
    myrktop
  ];

  nix.buildMachines = with self.vars.buildMachines; [
    ft
    x79
    mac
  ];

  system.stateVersion = "25.11";
}
