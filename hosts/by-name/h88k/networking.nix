{
  config,
  pkgs,
  lib,
  self,
  ...
}:
{
  imports = [
    "${self}/config/sing-box/client.nix"
    "${self}/config/web/openlist.nix"
  ];

  boot.kernelModules = [ "brutal" ];

  services.mptcpd = {
    enable = true;
    extraMptcpdFlags = [
      "--path-manager=sspi"
      "--addr-flags=subflow"
      "--notify-flags=existing,skip_link_local,skip_loopback,check_route"
    ];
  };

  services.resolved = {
    dnsovertls = "opportunistic";
    extraConfig = ''
      DNSStubListenerExtra=0.0.0.0
    '';
  };

  systemd.network.networks."40-br0" = {
    matchConfig.Name = "br0";
    networkConfig = {
      DHCPServer = "yes";
    };
    dhcpServerConfig = {
      EmitDNS = "yes";
      DNS = "192.168.100.1";
    };
  };

  systemd.network.networks."40-eth0" = {
    matchConfig.Name = "eth0";
    dns = [
      "223.5.5.5"
      "119.29.29.29"
    ];
  };

  services.sing-box.outbounds.hysteria2 = [
    {
      bind_interface = "wwan0";
      down_mbps = 10;
      up_mbps = 40;
      password = {
        _secret = config.age.secrets.sing-uuid.path;
      };
      tls.server_name = "e88a.${self.vars.domain}";
      server_port = 8443;
      group = [
        "private"
      ];
      tag = "hy2-e88a-wwan0";
    }
  ];

  networking = {
    hostName = "h88k";
    domain = self.vars.domain;
    networkmanager.enable = true;
    networkmanager.ensureProfiles.profiles = {
      hotspot = {
        connection = {
          autoconnect = "true";
          id = "hotspot";
          interface-name = "wlan0";
          type = "wifi";
          controller = "br0";
          port-type = "bridge";
        };
        wifi = {
          # band = "a";
          # channel = "165";
          mode = "ap";
          ssid = "${config.networking.hostName}-5G";
        };
        wifi-security = {
          group = "ccmp";
          key-mgmt = "wpa-psk";
          pairwise = "ccmp";
          proto = "rsn";
          psk = "12345678";
        };
      };
    };

    hosts = {
      "${self.vars.hosts.h88k.ip}" = [
        "drive.h88k.${self.vars.domain}"
      ];
      "${self.vars.hosts.x79.ip}" = [
        "cache.csrc.eu.org"
        "hydra.csrc.eu.org"
      ];
    };

    defaultGateway = {
      address = "172.16.4.254";
      interface = "eth0";
      metric = 100;
    };

    interfaces = {
      eth0.ipv4 = {
        addresses = [
          {
            address = self.vars.hosts.h88k.ip;
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
      br0.ipv4.addresses = [
        {
          address = "192.168.100.1";
          prefixLength = 24;
        }
      ];
    };

    bridges.br0.interfaces = [
      "eth1"
      "eth2"
    ];

    nat = {
      enable = true;
      internalInterfaces = [
        "br0"
        "eth0"
        "wg0"
      ];
      externalInterfaces = [
        "wwan0"
        "eth0"
      ];
    };

    tproxy = {
      enable = true;
      # acme get confused by hijacked sing-box dns response
      groups = [ "acme" ];
      internalIPs = [
        "192.168.0.0/16"
      ];
      allowedTCPPorts = [
        53
      ];
      allowedUDPPorts = [
        53
        123
        51820
      ];
    };

    # wireguard = {
    #   enable = true;
    #   interfaces.wg0.peers = [
    #     {
    #       publicKey = self.vars.hosts.e88a.wgpub;
    #       allowedIPs = [ "192.168.200.4/32" ];
    #       endpoint = "${self.vars.hosts.e88a.ip}:51820";
    #       persistentKeepalive = 25;
    #     }
    #   ];
    # };

    firewall = {
      enable = true;
      trustedInterfaces = [
        "br0"
        "wg0"
      ];
      extraInputRules = ''
        ip saddr { ${self.vars.hosts.mac.ip}, ${self.vars.hosts.x79.ip} } counter accept
      '';
      interfaces = {
        "eth0" = {
          allowedTCPPorts = [
            53
            1080
          ];
          allowedUDPPorts = [
            53
            1080
            5355 # LLMNR
          ];
        };
      };
    };
  };
}
