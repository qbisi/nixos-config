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
  };

  imports = [
    "${inputs.nixos-images}/devices/by-name/nixos-jwipc-e88a.nix"
    "${self}/config/desktop.nix"
    "${self}/config/sing-box/client.nix"
  ];

  disko.bootImage.partLabel = "nvme";

  hardware = {
    deviceTree.dtsFile = lib.mkForce "${self}/dts/rk3588-jwipc-e88a.dts";
    firmware = lib.mkForce [
      (pkgs.armbian-firmware.override {
        filters = [
          "arm/mali/*"
          "rt*"
          "mediatek/*"
          "regulatory.db"
        ];
      })
    ];
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
    domain = self.vars.domain;
    hostName = "e88a";
    networkmanager.enable = true;
    firewall.checkReversePath = false;
    firewall.allowedUDPPorts = [
      5355 # LLMNR
    ];
    defaultGateway = {
      address = "172.16.6.254";
      interface = "eth0";
      metric = 100;
    };
    interfaces = {
      eth0.ipv4 = {
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
            address = "172.16.7.250";
            prefixLength = 23;
          }
        ];
      };
      br0.ipv4.addresses = [
        {
          address = "192.168.101.1";
          prefixLength = 24;
        }
      ];
    };
    bridges.br0.interfaces = [ "eth1" ];
    nat = {
      enable = true;
      internalInterfaces = [
        "br0"
        "wg0"
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

  systemd.slices."user-1000".sliceConfig = {
    CPUQuota = "600%";
    MemoryMax = "6G";
  };

  environment.variables = {
    MESA_GLSL_VERSION_OVERRIDE = 330;
  };

  environment.systemPackages = with pkgs; [
    rkdeveloptool
    myrktop
  ];

  nix.buildMachines = with self.vars.buildMachines; [
    ft
    x79
    mac
  ];

  system.stateVersion = "25.11";
}
