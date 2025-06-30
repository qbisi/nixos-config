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
    buildOnTarget = false;
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

  services.resolved.fallbackDns = [
    "223.5.5.5"
    "114.114.114.114"
  ];

  networking = {
    hostName = "ft";

    defaultGateway = {
      address = "172.16.6.254";
      interface = "eth1";
      metric = 100;
    };

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
      eth1.ipv4 = {
        routes = [
          {
            address = "172.16.0.0";
            prefixLength = 16;
            via = "172.16.6.254";
          }
          {
            address = "10.0.0.0";
            prefixLength = 12;
            via = "172.16.6.254";
          }
        ];
        addresses = [
          {
            address = "172.16.7.125";
            prefixLength = 23;
          }
        ];
      };
    };

    wireguard = {
      enable = true;
      interfaces.wg0.peers = lib.mkForce [
        {
          publicKey = self.vars.hosts.h88k.wgpub;
          allowedIPs = [ "192.168.200.1/32" ];
          endpoint = "${self.vars.hosts.h88k.ip}:51820";
          persistentKeepalive = 25;
        }
        {
          publicKey = self.vars.hosts.x79.wgpub;
          allowedIPs = [ "192.168.200.2/32" ];
          endpoint = "${self.vars.hosts.x79.ip}:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  environment = {
    systemPackages = with pkgs; [ lm_sensors ];
  };

  nix = {
    settings = {
      max-jobs = 2;
      cores = 32;
    };
    buildMachines = with self.vars.buildMachines; [
      x79
      mac
    ];
  };

  systemd.services.nix-daemon.serviceConfig = {
    MemoryHigh = "100G";
    MemoryMax = "110G";
  };

  system.stateVersion = "24.11";
}
