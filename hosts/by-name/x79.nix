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
    "${self}/config/nettools.nix"
    "${self}/config/hydra.nix"
    self.nixosModules.secrets
  ];

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
    graphics = {
      enable = true;
      # Fixup for opengl not found sshing from non-nixos system
      extraPackages = [
        (pkgs.runCommand "mesa_glxindirect" { } (''
          mkdir -p $out/lib
          ln -s ${pkgs.mesa}/lib/libGLX_mesa.so.0 $out/lib/libGLX_indirect.so.0
        ''))
      ];
    };
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
    proxy.default = "http://${self.vars.hostIP.h88k}:1080";
    defaultGateway = {
      address = "172.16.4.254";
      interface = "eth1";
      metric = 10;
    };

    interfaces.eth1.ipv4 = {
      addresses = [
        {
          address = self.vars.hostIP.x79;
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

    firewall = {
      allowedUDPPorts = [ 51820 ];
    };

    wireguard = {
      enable = true;
      interfaces = {
        wg0 = {
          ips = [ "192.168.200.2/24" ];
          listenPort = 51820;
          privateKeyFile = config.age.secrets."wg-x79".path;
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
