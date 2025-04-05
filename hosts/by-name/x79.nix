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
    "${inputs.nixos-images}/devices/by-name/nixos-x86_64-uefi.nix"
    # "${self}/config/hydra.nix"
    # "${self}/config/jupyter.nix"
  ];

  hardware = {
    graphics.enable = true;
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

  services.resolved.fallbackDns = [
    "223.5.5.5"
    "114.114.114.114"
  ];

  networking = {
    hostName = "x79";
    useDHCP = false;
    useNetworkd = true;
    defaultGateway = {
      address = "172.16.4.254";
      interface = "eth1";
      metric = 100;
    };

    interfaces.eth1.ipv4 = {
      addresses = [
        {
          address = self.vars.hosts.x79.ip;
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

    wireguard = {
      enable = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      lm_sensors
    ];
  };

  virtualisation = {
    docker.enable = true;
    podman.enable = true;
    lxd.enable = true;
  };

  users.users.admin.extraGroups = [
    "podman"
    "docker"
    "lxd"
  ];

  systemd.services.nix-daemon.serviceConfig = {
    MemoryHigh = "100G";
    MemoryMax = "110G";
  };

  nix = {
    settings = {
      max-jobs = 4;
      cores = 6;
    };
    buildMachines = with self.vars.buildMachines; [
      ft
      mac
    ];
    sshServe = {
      enable = true;
      keys = config.users.users.root.openssh.authorizedKeys.keys;
    };
  };

  system.stateVersion = "24.11";
}
