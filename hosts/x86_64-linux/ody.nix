{
  config,
  pkgs,
  lib,
  modulesPath,
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
    "${inputs.nixos-images}/devices/x86_64-linux/nixos-x86_64-uefi.nix"
    self.nixosModules.router
    self.nixosModules.secrets
  ];

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
  };

  boot = {
    kernelParams = [
      "console=tty1"
    ];
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    initrd.availableKernelModules = [
      "ahci"
      "xhci_pci"
      "nvme"
      "sdhci_pci"
    ];
    kernelModules = [ "kvm-intel" ];
  };

  networking = {
    hostName = "ody";
    domain = self.vars.domain;
    bridges.br0.interfaces = [ "eth1" ];
    networkmanager.ensureProfiles.profiles = {
      eth0 = {
        connection = {
          id = "eth0";
          interface-name = "eth0";
          type = "ethernet";
        };
        ipv4 = {
          address1 = "${self.vars.hostIP.ody}/23,172.16.4.254";
          dns = "223.5.5.5;";
          method = "manual";
          route1 = "172.16.0.0/12,172.16.4.254";
        };
        ipv6 = {
          method = "auto";
        };
      };
    };
  };

  services.sing-box.outbounds = {
    socks = [
      {
        server = self.vars.hostIP.h88k;
        group = [
          "proxy"
          "direct"
        ];
      }
    ];
  };

  services.ddclient = {
    enable = true;
    usev6 = "webv6, webv6=ipv6.ident.me/";
    protocol = "cloudflare";
    domains = [ config.networking.fqdn ];
    zone = config.networking.domain;
    username = self.vars.user.mail;
    passwordFile = config.age.secrets.ddclient.path;
  };

  systemd.services.ddclient.serviceConfig.Group = "proxy";

  nix.buildMachines = with self.vars.buildMachines; [
    ft
    x79
    mac
  ];

  system.stateVersion = "24.11";
}
