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
    # useDHCP = false;
    # useNetworkd = true;
    proxy.default = "http://${self.vars.hostIP.h88k}:1080";
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

    defaultGateway = {
      address = "192.168.200.1";
      interface = "wg0";
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
