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
    "${inputs.nixos-images}/devices/by-name/nixos-aarch64-uefi.nix"
    "${self}/config/vps.nix"
  ];

  boot = {
    kernelParams = lib.mkAfter [
      "console=ttyAMA0"
    ];
    loader.grub.font = null;
  };

  virtualisation.hypervGuest.enable = true;

  networking.hostName = "jp1";

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 1024;
    }
  ];

  system.stateVersion = "24.11";
}
