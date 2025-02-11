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
    targetHost = "192.168.100.163";
    # buildOnTarget = true;
    tags = [
      "desktop"
      "dev"
    ];
  };

  imports = [
    "${inputs.nixos-images}/devices/aarch64-linux/nixos-hinlink-h88k.nix"
    self.nixosModules.desktop
  ];

  networking = {
    hostName = "h89k";
    useDHCP = false;
    networkmanager.enable = true;
  };

  hardware = {
    deviceTree.dtsFile = lib.mkForce ./dts/rk3588-hinlink-h88k.dts;
  };

  # currently does not support usb recover from suspend
  powerManagement.enable = false;

}
