{
  config,
  lib,
  self,
  ...
}:
{
  imports = [
    ./sing-box/client.nix
    ./nettools.nix
  ];

  systemd.services.ModemManager.wantedBy = [ "multi-user.target" ];

  networking = {
    useDHCP = false;
    useNetworkd = true;
    networkmanager.enable = true;
    networkmanager.settings.main.no-auto-default = "*";
    modemmanager.enable = true;
    nftables.enable = true;

    networkmanager.ensureProfiles.profiles = {
      eth0 = lib.mkDefault {
        connection = {
          id = "eth0";
          interface-name = "eth0";
          type = "ethernet";
        };
        ipv4.method = "auto";
        ipv6.method = "auto";
      };

      wwan0 = {
        connection = {
          id = "wwan0";
          interface-name = "cdc-wdm0";
          type = "gsm";
        };
        ipv4.method = "auto";
        ipv6.method = "auto";
      };

      hotspot = lib.mkDefault {
        connection = {
          autoconnect = "false";
          id = "hotspot";
          interface-name = "wlan0";
          type = "wifi";
          controller = "br0";
          port-type = "bridge";
        };
        wifi = {
          band = "a";
          channel = "165";
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

    nat = {
      enable = true;
      internalInterfaces = [
        "br0"
        "eth0"
      ];
      externalInterfaces = [
        "wwan0"
        "eth0"
      ];
    };

    tproxy = {
      enable = lib.mkDefault true;
      internalIPs = [
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.100.0/24"
      ];
      allowedTCPPorts = [
        22
        53
      ];
      allowedUDPPorts = [
        53
        123
      ];
    };

    firewall = {
      enable = true;
      trustedInterfaces = [ "br0" ];
      extraInputRules = ''
        ip saddr { ${self.vars.hostIP.mac}, ${self.vars.hostIP.x79} } counter accept
      '';
      checkReversePath = false;
      interfaces = {
        "wwan0" = {
          allowedTCPPorts = [
            5201
          ];
          allowedUDPPorts = [
            5201
          ];
        };
        "eth0" = {
          allowedTCPPorts = [
            53
            1080
            9090 # metacubexd
          ];
          allowedUDPPorts = [
            53
            1080
            5355 # LLMNR
          ];
        };
      };
    };

    bridges.br0.interfaces = [ ];
    interfaces.br0.ipv4.addresses = lib.mkDefault [
      {
        address = "192.168.100.1";
        prefixLength = 24;
      }
    ];
  };

  systemd.network.wait-online.enable = false;

  systemd.network.networks."40-br0" = {
    matchConfig.Name = "br0";
    networkConfig = {
      DHCPServer = "yes";
    };
    dhcpServerConfig = {
      EmitDNS = "yes";
      DNS = "223.5.5.5";
    };
  };
}
