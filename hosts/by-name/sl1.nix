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
    "${inputs.nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
    "${self}/config/vps.nix"
  ];

  boot = {
    initrd.availableKernelModules = [
      "ata_piix"
      "uhci_hcd"
      "virtio_pci"
      "virtio_scsi"
      "sd_mod"
    ];
    kernelModules = [ "kvm-amd" ];
  };

  networking = {
    hostName = "sl1";
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
