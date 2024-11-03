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
    tags = [ "vps" ];
  };

  imports = [
    "${inputs.nixos-images}/devices/x86_64-linux/nixos-x86_64-uefi.nix"
    self.nixosModules.vps
  ];

  boot.initrd.availableKernelModules = [ "sd_mod" ];

  virtualisation.hypervGuest.enable = true;

  networking.hostName = "hk";

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 1024;
    }
  ];

  system.stateVersion = "24.11";
}
