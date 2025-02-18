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
    "${inputs.nixos-images}/devices/aarch64-linux/nixos-phytium-uefi.nix"
    self.nixosModules.secrets
  ];

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
    ];
  };

  networking = {
    hostName = "ft";
    useDHCP = false;
    useNetworkd = true;
    proxy.default = "http://${self.vars.hostIP.h88k}:1080";
    defaultGateway = {
      address = "10.0.5.1";
      interface = "eth0";
    };
    interfaces.eth0.ipv4 = {
      routes = [
        {
          address = "172.16.0.0";
          prefixLength = 16;
          via = "10.0.5.1";
        }
      ];
      addresses = [
        {
          address = self.vars.hostIP.ft;
          prefixLength = 24;
        }
      ];
    };
  };

  environment = {
    systemPackages = with pkgs; [ lm_sensors ];
  };

  nix = {
    buildMachines = with self.vars.buildMachines; [
      x79
      mac
    ];

    sshServe = {
      enable = true;
      keys = config.users.users.admin.openssh.authorizedKeys.keys;
    };
  };

  system.stateVersion = "24.11";
}
