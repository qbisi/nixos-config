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

  nixpkgs.config.allowUnfree = true;

  imports = [
    "${inputs.nixos-images}/devices/by-name/nixos-x86_64-uefi.nix"
    "${self}/config/web/harmonia.nix"
    "${self}/config/desktop.nix"
    ./hydra.nix
  ];

  hardware = {
    graphics.enable = true;
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
  };

  boot = {
    # binfmt.emulatedSystems = [
    #   "aarch64-linux"
    # ];
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

  programs.steam.enable = true;

  services.nginx.serverName = "csrc.eu.org";

  services.resolved.fallbackDns = [
    "223.5.5.5%eth1"
  ];

  networking = {
    hostName = "x79";
    domain = "csrc.eu.org";
    firewall.extraInputRules = ''
      ip saddr { ${self.vars.hosts.ft.ip}, ${self.vars.hosts.h88k.ip} } counter accept
    '';

    defaultGateway = {
      address = "172.16.6.254";
      interface = "eth0";
      metric = 100;
    };

    interfaces.eth0.wakeOnLan.enable = true;

    interfaces.eth0.ipv4 = {
      addresses = [
        {
          address = "172.16.6.125";
          prefixLength = 23;
        }
      ];
      routes = [
        {
          address = "10.0.0.0";
          via = "172.16.6.254";
          prefixLength = 12;
        }
        {
          address = "172.16.0.0";
          prefixLength = 16;
          via = "172.16.6.254";
        }
      ];
    };

    interfaces.eth1.ipv4 = {
      addresses = [
        {
          address = "172.16.5.125";
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
    podman.enable = true;
  };

  users.users.admin.extraGroups = [
    "podman"
    "docker"
  ];

  systemd.services.nix-daemon.serviceConfig = {
    MemoryHigh = "100G";
    MemoryMax = "110G";
  };

  nix = {
    settings = {
      max-jobs = 2;
      cores = 24;
    };
    buildMachines = with self.vars.buildMachines; [
      ft
      mac
    ];
  };

  system.stateVersion = "24.11";
}
