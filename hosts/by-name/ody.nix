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

  systemd.network.networks."40-br0" = {
    matchConfig.Name = "br0";
    networkConfig = {
      DHCPServer = "yes";
    };
    dhcpServerConfig = {
      EmitDNS = "yes";
      DNS = "192.168.101.1";
    };
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
    bridges.br0.interfaces = [ "eth1" ];
    firewall = {
      trustedInterfaces = [
        "br0"
        "wg0"
      ];
      allowedUDPPorts = [
        5355 # LLMNR
      ];
      extraInputRules = ''
        ip saddr ${self.vars.hosts.mac.ip} counter accept
      '';
    };
    nat = {
      enable = true;
      internalInterfaces = [
        "br0"
        "wg0"
        "eth0"
      ];
      externalInterfaces = [
        "wwan0"
        "eth0"
      ];
    };
    tproxy = {
      enable = true;
      internalIPs = [
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
      ];
      allowedTCPPorts = [
        22
        53
      ];
      allowedUDPPorts = [
        53
        123
        51820
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    minicom
    rkdeveloptool
  ];

  nix.distributedBuilds = true;

  system.stateVersion = "25.05";
}
