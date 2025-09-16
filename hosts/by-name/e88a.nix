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
    "${self}/config/desktop.nix"
    "${self}/config/sing-box/client.nix"
    "${self}/config/remote-access.nix"
    "${self}/config/nas.nix"
  ];

  nixpkgs = {
    system = "aarch64-linux";
  };

  disko = {
    enableConfig = true;
    bootImage = {
      fileSystem = "btrfs";
      partLabel = "nvme";
    };
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "console=tty1"
      "earlycon"
      "net.ifnames=0"
    ];
    consoleLogLevel = 6;
    loader.grub.enable = true;
  };

  hardware = {
    firmware = [
      (pkgs.armbian-firmware.override {
        filters = [
          "arm/mali/*"
          "rt*"
          "mediatek/*"
          "regulatory.db"
        ];
      })
    ];
    deviceTree = {
      name = "rockchip/rk3588-jwipc-e88a.dtb";
      platform = "rockchip";
      dtsFile = "${self}/dts/rk3588-jwipc-e88a.dts";
    };
    serial = {
      enable = true;
      unit = 2;
      baudrate = 1500000;
    };
    bluetooth.enable = lib.mkForce false;
  };

  fileSystems = {
    "/gigatf" = {
      device = "/dev/disk/by-uuid/e64827a8-9986-42da-8364-a958dcd129d4";
      fsType = "f2fs";
      options = [
        "nofail"
        "x-systemd.wanted-by=dev-disk-by\\x2duuid-e64827a8\\x2d9986\\x2d42da\\x2d8364\\x2da958dcd129d4.device"
        "nodev"
        "noatime"
      ];
    };
    "/.data" = {
      device = "/dev/sda";
      fsType = "ext4";
      options = [
        "nodev"
        "noatime"
      ];
    };
    "/data" = {
      device = "/.data:/gigatf=RO";
      fsType = "mergerfs";
      options = [
        "nodev"
        "nofail"
        "cache.files=off"
        "dropcacheonclose=false"
        "category.create=mfs"
      ];
    };
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
    firewall = {
      extraInputRules = ''
        ip saddr { ${self.vars.hosts.ft.ip}, ${self.vars.hosts.x79.ip} } counter accept
      '';
      trustedInterfaces = [
        "br0"
        "wg0"
      ];
      allowedTCPPorts = [
        1080
        9090
      ];
      allowedUDPPorts = [
        5355 # LLMNR
      ];
    };
    defaultGateway = {
      address = "172.16.6.254";
      interface = "eth1";
      metric = 100;
    };
    interfaces = {
      "${config.networking.defaultGateway.interface}".ipv4 = {
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
    bridges.br0.interfaces = [ "eth0" ];
    nat = {
      enable = true;
      internalInterfaces = [
        "br0"
        "wg0"
        "eth1"
      ];
      externalInterfaces = [
        "eth1"
        "wwan0"
        "wlan0"
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
    mergerfs
  ];

  nix.distributedBuilds = true;

  system.stateVersion = "25.11";
}
