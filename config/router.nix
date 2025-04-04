{
  config,
  pkgs,
  lib,
  self,
  ...
}:
{
  imports = [
    ./sing-box/client.nix
  ];

  boot.kernelModules = [ "brutal" ];

  networking = {
    useDHCP = false;
    useNetworkd = true;
    networkmanager.enable = true;
    nftables.enable = true;
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
        "192.168.0.0/16"
      ];
      allowedTCPPorts = [
        22
        # hija dns, use fakeip
        # otherwise sniff_override on remote
        # 53
      ];
      allowedUDPPorts = [
        # 53
        123
        51820
      ];
    };

    firewall = {
      enable = true;
      trustedInterfaces = [
        "br0"
        "wg0"
      ];
      extraInputRules = ''
        ip saddr { ${self.vars.hosts.mac.ip}, ${self.vars.hosts.x79.ip} } counter accept
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

  systemd.network.networks."40-br0" = {
    matchConfig.Name = "br0";
    networkConfig = {
      DHCPServer = "yes";
      # RequiredForOnline = "no";
    };
    dhcpServerConfig = {
      EmitDNS = "yes";
      DNS = "223.5.5.5";
    };
  };
}
