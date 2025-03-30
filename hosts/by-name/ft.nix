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
    "${self}/config/nettools.nix"
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
    useDHCP = false;
    useNetworkd = true;
    defaultGateway = {
      address = "10.0.5.1";
      interface = "eth0";
      metric = 10;
    };
    interfaces.eth0.ipv4 = {
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
          address = self.vars.hostIP.ft;
          prefixLength = 24;
        }
      ];
    };

    firewall = {
      allowedUDPPorts = [ 51820 ];
    };

    wireguard = {
      enable = true;
      interfaces = {
        wg0 = {
          ips = [ "192.168.200.3/24" ];
          listenPort = 51820;
          privateKeyFile = config.age.secrets."wg-ft".path;
          peers = [
            {
              publicKey = self.vars.wgkey.h88k;
              allowedIPs = [ "0.0.0.0/0" ];
              endpoint = "${self.vars.hostIP.h88k}:51820";
              persistentKeepalive = 25;
            }
          ];
        };
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [ lm_sensors ];
  };

  nix = {
    settings = {
      max-jobs = 4;
      cores = 16;
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
