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
    buildOnTarget = true;
  };

  imports = [
    "${inputs.nixos-images}/devices/by-name/nixos-x86_64-uefi.nix"
    "${self}/config/proxy/dae.nix"
  ];

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
  };

  boot = {
    kernelParams = [
      "console=tty1"
    ];
    binfmt.emulatedSystems = [ "aarch64-linux" ];
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
    useDHCP = false;
    useNetworkd = true;
    networkmanager.enable = true;
    nftables.enable = true;
    nameservers = [
      "223.5.5.5"
    ];
    defaultGateway = {
      address = "172.16.4.254";
      interface = "eth0";
      metric = 1000;
    };
    interfaces.eth0.ipv4 = {
      addresses = [
        {
          address = self.vars.hostIP.ody;
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

  systemd.network.wait-online.enable = false;

  nix.buildMachines = with self.vars.buildMachines; [
    ft
    x79
    mac
  ];

  system.stateVersion = "24.11";
}
