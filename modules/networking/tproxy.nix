{
  config,
  lib,
  self,
  ...
}:
with lib;
let
  cfg = config.networking.tproxy;
  canonicalizePortList = ports: unique (builtins.sort builtins.lessThan ports);
  toNftSet = list: concatStringsSep ", " list;
  ifaceSet = toNftSet (map (x: ''"${x}"'') cfg.internalInterfaces);
  ipSet = toNftSet cfg.internalIPs;
  ip6Set = toNftSet cfg.internalIPv6s;
  fwmark = builtins.toString cfg.fwmark;
  port = builtins.toString cfg.port;
  portsToNftSet = ports: concatStringsSep ", " (map (x: toString x) ports);
  tcpSet = portsToNftSet cfg.allowedTCPPorts;
  udpSet = portsToNftSet cfg.allowedUDPPorts;
  userSets = concatStringsSep ", " cfg.users;
  groupSets = concatStringsSep ", " cfg.groups;
in
{
  options = {
    networking.tproxy = {
      enable = mkEnableOption "tproxy";

      port = lib.mkOption {
        type = types.port;
        default = 60000;
        example = 60080;
        description = ''
          The local port that tproxy forward to and proxy server listen on.
        '';
      };

      users = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "root" ];
        description = ''
          The users for local proxy server to bypass the tproxy table.
        '';
      };

      groups = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "proxy" ];
        description = ''
          The group for local proxy server to bypass the tproxy table.
        '';
      };

      fwmark = mkOption {
        type = types.int;
        default = 9011;
        description = ''
          The firewallmark to set on tproxy packets.
        '';
      };

      allowedTCPPorts = lib.mkOption {
        type = types.listOf types.port;
        default = [ ];
        apply = canonicalizePortList;
        example = [
          22
          80
        ];
        description = ''
          List of TCP ports on which incoming connections are
          accepted.
        '';
      };

      allowedUDPPorts = mkOption {
        type = types.listOf types.port;
        default = [ ];
        apply = canonicalizePortList;
        example = [ 53 ];
        description = ''
          List of open UDP ports.
        '';
      };

      internalInterfaces = mkOption {
        type = types.listOf types.str;
        default = config.networking.nat.internalInterfaces;
        example = [ "br0" ];
        description = ''
          The interfaces for which to perform tproxy. Packets coming from
          these interface and destined for the external interface will
          be rewritten.
        '';
      };

      internalIPs = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "172.16.0.0/12" ];
        description = ''
          The IP address ranges to which to not perform tproxy.
        '';
      };

      internalIPv6s = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          The IPv6 address ranges to which to not perform tproxy.
        '';
      };
    };
  };
  config = mkIf (cfg.enable && config.networking.nftables.enable && config.networking.useNetworkd) {
    services.sing-box.settings.inbounds = [
      {
        type = "tun";
        tag = "tun-in";
        interface_name = "tun0";
        address = config.systemd.network.networks.tun0.address;
        mtu = 9000;
        auto_route = false;
      }
    ];

    networking.firewall.checkReversePath = false;

    networking.tproxy = {
      allowedUDPPorts = [
        67
        68
      ];
      internalIPs = [
        "100.64.0.0/10"
        "127.0.0.0/8"
        "169.254.0.0/16"
        "224.0.0.4/4"
        "240.0.0.4/4"
        "255.255.255.255/32"
      ];
      internalIPv6s = [
        "::1"
        "fe80::/10"
      ];
    };
    networking.nftables = {
      preCheckRuleset = ''
        sed 's/skuid { ${userSets} }/skuid nobody/g' -i ruleset.conf
        sed 's/skgid { ${groupSets} }/skgid nogroup/g' -i ruleset.conf
      '';
      tables = {
        proxy = {
          enable = true;
          family = "inet";
          content = ''
            chain output {
             type route hook output priority mangle; policy accept;
             ${optionalString (userSets != "") "skuid { ${userSets} } return"}
             ${optionalString (groupSets != "") "skgid { ${groupSets} } return"}
             fib saddr type local fib daddr type != local jump setmark
            }
            chain prerouting {
              type filter hook prerouting priority mangle; policy accept;
              iifname "lo" mark != ${fwmark} return
              iifname { ${ifaceSet} } fib saddr type != local fib daddr type != local jump setmark
              mark ${fwmark} meta protocol ip meta l4proto tcp tproxy ip to 127.0.0.1:${port} accept
              mark ${fwmark} meta protocol ip6 meta l4proto tcp tproxy ip6 to [::1]:${port} accept
            }
            chain setmark {
              meta mark set ct mark
              mark ${fwmark} return
              ${optionalString (tcpSet != "") "tcp dport { ${tcpSet} } return"}
              ${optionalString (udpSet != "") "udp dport { ${udpSet} } return"}
              ip daddr { ${ipSet} } return
              ip6 daddr { ${ip6Set} } return
              tcp dport 1-65535 tcp flags & (fin|syn|rst|ack) == syn meta mark set ${fwmark}
              udp dport 1-65535 ct state new meta mark set ${fwmark}
              ct mark set mark
            }
          '';
        };
      };
    };
    systemd.network.networks."tproxy" = {
      matchConfig.Name = "lo";
      routes = [
        {
          Type = "local";
          Scope = "host";
          Destination = "0.0.0.0/0";
          Table = 233;
        }
        {
          Type = "local";
          Scope = "host";
          Destination = "::/0";
          Table = 233;
        }
      ];
      routingPolicyRules = [
        {
          FirewallMark = cfg.fwmark;
          Priority = 32762;
          Table = 233;
          IPProtocol = "tcp";
          Family = "both";
        }
      ];
    };
    systemd.network.networks."tun0" = {
      matchConfig.Name = "tun0";
      address = [
        "172.18.0.1/30"
        "fdfe:dcba:9876::1/126"
      ];
      routes = [
        {
          Gateway = "172.18.0.2";
          Destination = "0.0.0.0/0";
          Table = 234;
        }
        {
          Gateway = "fdfe:dcba:9876::2";
          Destination = "::/0";
          Table = 234;
        }
      ];
      routingPolicyRules = [
        {
          FirewallMark = cfg.fwmark;
          Priority = 32761;
          Table = 234;
          IPProtocol = "udp";
          Family = "both";
        }
      ];
    };
  };
}
