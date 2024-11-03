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
    tags = [
      "builder"
      "dev"
    ];
    buildOnTarget = true;
  };

  imports = [
    "${inputs.nixos-images}/devices/x86_64-linux/nixos-x86_64-uefi.nix"
    self.nixosModules.secrets
  ];

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
  };

  boot = {
    kernelParams = [
      "console=tty1"
    ];
    kernelModules = [ "kvm-intel" ];
    initrd.availableKernelModules = [
      "ehci_pci"
      "ahci"
      "mpt3sas"
      "xhci_pci"
      "usbhid"
      "sd_mod"
      "sr_mod"
    ];
  };

  networking = {
    hostName = "x79";
    proxy.default = "http://${self.vars.hostIP.h88k}:1080";
  };

  environment = {
    systemPackages = with pkgs; [ lm_sensors ];
  };

  nix.buildMachines = with self.vars.buildMachines; [
    ft
    mac
  ];

  system.stateVersion = "24.11";
}
