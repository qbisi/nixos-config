{
  config,
  pkgs,
  lib,
  self,
  inputs,
  ...
}:
let
  certDir = config.security.acme.certs.${config.networking.domain}.directory;
in
{
  deployment = {
    tags = [
      "router"
      "dev"
    ];
    buildOnTarget = true;
  };

  imports = [
    "${inputs.nixos-images}/devices/by-name/nixos-x86_64-uefi.nix"
    "${self}/config/router.nix"
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
    firewall.interfaces = {
      "wwan0" = {
        allowedTCPPorts = [
          8443
        ];
        allowedUDPPorts = [
          8443 # hy2-in
        ];
      };
    };
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

  services.sing-box = {
    outbounds = {
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
    settings = {
      inbounds = [
        {
          tag = "hysteria2-in";
          type = "hysteria2";
          listen = "::";
          listen_port = 8443;
          sniff = true;
          sniff_override_destination = true;
          up_mbps = 10;
          down_mbps = 40;
          users = [
            {
              password = {
                _secret = config.age.secrets."sing-uuid".path;
              };
            }
          ];
          masquerade = "https://www.baidu.com";
          tls = {
            enabled = true;
            alpn = [
              "h3"
            ];
            certificate_path = certDir + "/cert.pem";
            key_path = certDir + "/key.pem";
          };
        }
      ];
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = lib.mkDefault self.vars.user.mail;
    defaults.server = "https://acme.zerossl.com/v2/DV90";
    defaults.extraLegoFlags = [
      "--eab"
    ];
    certs."${config.networking.domain}" = {
      domain = "*.${config.networking.domain}";
      dnsProvider = "cloudflare";
      environmentFile = config.age.secrets.acme.path;
    };
  };

  services.ddclient = {
    enable = true;
    usev4 = "";
    usev6 = "ifv6, ifv6=wwan0";
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
