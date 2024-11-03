{
  config,
  pkgs,
  lib,
  self,
  inputs,
  modulesPath,
  ...
}:
{
  deployment = {
    buildOnTarget = true;
    tags = [ "vps" ];
  };

  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    "${inputs.nixos-images}/devices/x86_64-linux/nixos-x86_64-uefi.nix"
    self.nixosModules.common
    self.nixosModules.vps
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

  networking.hostName = "sl1";

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 1024;
    }
  ];

  system.stateVersion = "24.11";
}
