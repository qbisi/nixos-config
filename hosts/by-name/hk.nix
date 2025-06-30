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
      "vps"
      "!cn"
    ];
  };

  imports = [
    "${inputs.nixos-images}/devices/by-name/nixos-x86_64-uefi.nix"
    "${self}/config/vps.nix"
  ];

  boot.initrd.availableKernelModules = [ "sd_mod" ];

  virtualisation.hypervGuest.enable = true;

  networking = {
    hostName = "hk";
    domain = self.vars.domain;
  };

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 1024;
    }
  ];

  system.stateVersion = "24.11";
}
