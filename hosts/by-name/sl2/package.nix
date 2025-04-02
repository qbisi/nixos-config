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
    targetHost = "132.226.16.187";
    buildOnTarget = true;
    tags = [ "vps" ];
  };

  imports = [
    "${inputs.nixos-images}/devices/by-name/nixos-aarch64-uefi.nix"
    "${inputs.nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
    "${self}/config/vps.nix"
    ./web/hydra.nix
  ];

  boot = {
    initrd.availableKernelModules = [
      "virtio_scsi"
    ];
  };

  networking = {
    hostName = "sl2";
    useDHCP = false;
    useNetworkd = true;
    interfaces.eth0.useDHCP = true;
  };

  system.stateVersion = "25.05";
}
