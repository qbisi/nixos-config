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
    targetHost = "192.168.100.250";
    # buildOnTarget = true;
    tags = [
      "desktop"
      "dev"
    ];
  };

  disko.profile.partLabel = "nvme";

  hardware = {
    deviceTree.dtsFile = lib.mkForce ./dts/rk3588-hinlink-h88k.dts;
  };

  imports = [
    "${inputs.nixos-images}/devices/aarch64-linux/nixos-hinlink-h88k.nix"
    self.nixosModules.desktop
  ];

  networking = {
    hostName = "h89k";
    useDHCP = false;
    useNetworkd = true;
    networkmanager.enable = true;
  };

  nix.buildMachines = with self.vars.buildMachines; [
    ft
    x79
    mac
  ];

  virtualisation.waydroid.enable = true;

  system.stateVersion = "25.05";
}
