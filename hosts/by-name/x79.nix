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

  nixpkgs = {
    config = {
      allowUnfree = true;
      nvidia.acceptLicense = true;
    };
  };

  imports = [
    "${inputs.nixos-images}/devices/by-name/nixos-x86_64-uefi.nix"
    "${self}/config/web/harmonia.nix"
    "${self}/config/desktop.nix"
    "${self}/config/hydra.nix"
    "${self}/config/nas.nix"
    "${self}/config/container/debian.nix"
  ];

  hardware = {
    graphics.enable = true;
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
    nvidia.open = false;
  };

  boot = {
    kernelParams = [
      "console=tty1"
    ];
    kernelModules = [
      "ext4"
      "kvm-intel"
    ];
    initrd.availableKernelModules = [
      "ehci_pci"
      "ahci"
      "mpt3sas"
      "xhci_pci"
      "usbhid"
      "sd_mod"
      "sr_mod"
    ];
    binfmt.emulatedSystems = [
      "aarch64-linux"
    ];
  };

  fileSystems = {
    "/data" = {
      device = "/dev/disk/by-uuid/b599ceb0-36ac-4309-98e0-ad37fca219e5";
      fsType = "btrfs";
      options = [
        "nodev"
        "nofail"
        "noatime"
      ];
    };
  };

  programs = {
    steam.enable = true;
    ccache = {
      enable = true;
      owner = config.users.users.admin.name;
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  services.nginx.serverName = "csrc.eu.org";

  services.resolved.fallbackDns = [
    "223.5.5.5"
  ];

  systemd.services.gitwatch-lwotc = {
    enable = true;
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [
      gitwatch
      git
      openssh
    ];
    script = ''
      gitwatch "/home/qbisi/.local/share/Steam/steamapps/compatdata/268500/pfx/drive_c/users/steamuser/Documents/my games/XCOM2 War of the Chosen/XComGame/SaveData"
    '';
    serviceConfig.User = config.users.users.admin.name;
  };

  networking = {
    hostName = "x79";
    domain = "csrc.eu.org";
    proxy.default = self.vars.http_proxy;
    firewall.extraInputRules = ''
      ip saddr { ${self.vars.hosts.ft.ip}, ${self.vars.hosts.h88k.ip} } counter accept
    '';
    firewall.allowedTCPPorts = [ 8000 ];

    defaultGateway = {
      address = self.vars.hosts.e88a.ip;
      interface = "eth1";
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
      zotero
      (python3.withPackages (
        ps: with ps; [
          scipy
          pyvista
          ipywidgets
          notebook
          fenics-dolfinx
          firedrake
        ]
      ))
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
    distributedBuilds = true;
  };

  system.stateVersion = "24.11";
}
