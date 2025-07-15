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
    buildOnTarget = false;
  };

  disko.bootImage.partLabel = "mmc";

  imports = [
    "${inputs.nixos-images}/devices/by-name/nixos-x86_64-uefi.nix"
    "${self}/config/remote-access.nix"
    "${self}/config/sing-box/client.nix"
  ];

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
  };

  boot = {
    initrd.availableKernelModules = [
      "ahci"
      "xhci_pci"
      "nvme"
      "sdhci_pci"
    ];
    kernelModules = [ "kvm-intel" ];
  };

  networking = {
    hostName = "ody";
    domain = self.vars.domain;
    networkmanager.enable = true;
    nameservers = [
      "223.5.5.5"
    ];
    defaultGateway = {
      address = "172.16.4.254";
      interface = "eth0";
      metric = 100;
    };
    interfaces.eth0.ipv4 = {
      addresses = [
        {
          address = self.vars.hosts.ody.ip;
          prefixLength = 23;
        }
      ];
      routes = [
        {
          address = "10.0.0.0";
          via = "172.16.4.254";
          prefixLength = 12;
        }
        {
          address = "172.16.0.0";
          prefixLength = 16;
          via = "172.16.4.254";
        }
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    minicom
    rkdeveloptool
  ];

  nix.buildMachines = with self.vars.buildMachines; [
    ft
    x79
    mac
  ];

  system.stateVersion = "25.05";
}
