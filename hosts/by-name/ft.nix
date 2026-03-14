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
      "builder"
      "dev"
    ];
    buildOnTarget = true;
  };

  imports = [
    "${inputs.nixos-images}/devices/by-name/nixos-phytium-uefi.nix"
  ];

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
    ];
  };

  networking = {
    hostName = "ft";
    nameservers = [ self.vars.hosts.e88a.ip ];
    proxy.default = lib.mkProxy self.vars.hosts.e88a.ip;

    interfaces = {
      eth0.ipv4 = {
        routes = [
          {
            address = "172.16.0.0";
            prefixLength = 16;
            via = "10.0.5.1";
          }
          {
            address = "10.0.0.0";
            prefixLength = 12;
            via = "10.0.5.1";
          }
        ];
        addresses = [
          {
            address = "10.0.5.125";
            prefixLength = 24;
          }
        ];
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [ lm_sensors ];
  };

  nix = {
    settings = {
      max-jobs = 1;
      cores = 60;
    };
    distributedBuilds = true;
  };

  systemd.services.nix-daemon.serviceConfig = {
    MemoryHigh = "100G";
    MemoryMax = "110G";
  };

  system.stateVersion = "24.11";
}
