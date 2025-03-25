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

      group = mkOption {
        type = types.str;
        default = "proxy";
        example = "root";
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
        sed 's/skgid ${cfg.group}/skgid nogroup/g' -i ruleset.conf
      '';
      tables = {
        proxy = {
          enable = true;
          family = "inet";
          content = ''
            chain output {
             type route hook output priority mangle; policy accept;
             skgid ${cfg.group} return
             fib saddr type local fib daddr type != local jump setmark
            }
            chain prerouting {
              type filter hook prerouting priority mangle; policy accept;
              iifname "lo" mark != ${fwmark} return
              iifname { ${ifaceSet} } fib saddr type != local fib daddr type != local jump setmark
              mark ${fwmark} meta protocol ip meta l4proto { tcp, udp } tproxy ip to 127.0.0.1:${port} accept
              mark ${fwmark} meta protocol ip6 meta l4proto { tcp, udp } tproxy ip6 to [::1]:${port} accept
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
          Family = "both";
        }
      ];
    };
  };
}
