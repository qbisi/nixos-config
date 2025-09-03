{
  config,
  pkgs,
  lib,
  self,
  ...
}:
let
  inherit (lib) forEach cartesianProduct';
  vps = [
    "jp1"
    "sg1"
    "hk"
    "sl1"
  ];
  domain = self.vars.domain;
  uuid = {
    _secret = config.age.secrets.sing-uuid.path;
  };
  reality = {
    enabled = true;
    public_key = {
      _secret = config.age.secrets.sing-pubkey.path;
    };
  };
in
{
  config = {
    systemd.services.sing-box = {
      serviceConfig = {
        MemoryMax = "400M";
      };
    };

    networking = {
      proxy.default = "http://127.0.0.1:1080";
      tproxy.users = [
        "sing-box"
        "systemd-resolve"
      ];
      resolvconf = {
        enable = true;
        useLocalResolver = true;
      };
    };

    programs.ssh.extraConfig = ''
      Host *
        ProxyCommand nc -x 127.0.0.1:1080 -X 5 %h %p
    '';

    services.resolved.enable = lib.mkForce false;

    services.sing-box.enable = true;

    services.sing-box.rule_packages = with pkgs; [
      sing-geoip-enhanced
      sing-geosite-enhanced
    ];

    services.sing-box.rule_set = [
      "geoip-cn"
      "geoip-telegram"
      "geosite-gfw"
      "geosite-cn"
      "geosite-steam"
      "geosite-openai"
    ];

    services.sing-box.outbounds = {
      selector = [
        { tag = "direct"; }
        { tag = "private"; }
        {
          tag = "proxy";
        }
        { tag = "game"; }
        { tag = "ai"; }
        {
          tag = "final";
          outbounds = [ "proxy" ];
        }
      ];

      vless = cartesianProduct' {
        # tcp_multi_path = true;
        bind_interface = [
          "eth0"
          "wwan0"
          "wlan0"
        ];
        inherit uuid;
        tls = forEach vps (v: {
          server_name = "${v}.${domain}";
          inherit reality;
        });
        multiplex = {
          brutal = {
            down_mbps = 150;
            enabled = false;
            up_mbps = 50;
          };
          enabled = false;
          max_connections = 4;
          min_streams = 4;
          padding = false;
          protocol = "h2mux";
        };
        tag =
          config:
          "reality-"
          + lib.genTag [
            "server"
            "bind_interface"
          ] config;
        group = [
          [
            "proxy"
            "ai"
          ]
        ];
      };

      hysteria2 = cartesianProduct' {
        bind_interface = [
          "eth0"
          "wwan0"
        ];
        hop_interval = "30s";
        down_mbps = 150;
        up_mbps = 50;
        password = uuid;
        server_ports = "2080:3000";
        tls = forEach vps (v: {
          server_name = "${v}.${domain}";
        });
        group = [
          [
            "proxy"
            "ai"
          ]
        ];
      };

      direct = cartesianProduct' {
        bind_interface = [
          "eth0"
          "wwan0"
          "wlan0"
        ];
        group = [
          [
            "direct"
            "private"
            "final"
            "game"
            "proxy"
          ]
        ];
      };

    };

    services.sing-box.settings = {
      log = {
        level = "error";
      };
      dns = {
        final = "alidns";
        strategy = "prefer_ipv4";
        rules = [
          {
            rule_set = [ "geosite-gfw" ];
            server = "fakeip";
          }
          {
            server = "alidns";
          }
        ];
        servers = [
          {
            type = "udp";
            tag = "alidns";
            server = "223.5.5.5";
            server_port = 53;
            detour = "direct-auto";
          }
          {
            type = "fakeip";
            tag = "fakeip";
            inet4_range = "198.18.0.0/15";
            inet6_range = "fc00::/18";
          }
        ];
      };
      experimental = {
        cache_file = {
          cache_id = "";
          enabled = true;
          path = "cache.db";
          store_fakeip = true;
          # Store rejected DNS response cache in the cache file
          store_rdrc = true;
          rdrc_timeout = "1d";
        };
        clash_api = {
          default_mode = "Rule";
          external_controller = ":9090";
          access_control_allow_private_network = true;
          external_ui = "${pkgs.metacubexd}";
        };
      };
      inbounds = [
        {
          listen = "::";
          listen_port = 1080;
          tag = "mixed-in";
          type = "mixed";
        }
        {
          listen = "::";
          listen_port = 60000;
          tag = "tproxy-in";
          type = "tproxy";
          sniff = true;
          sniff_override_destination = true;
        }
      ];
      route = {
        final = "final";
        default_domain_resolver = "alidns";
        rules = [
          {
            action = "sniff";
          }
          {
            action = "hijack-dns";
            protocol = "dns";
          }
          {
            action = "route";
            clash_mode = "global";
            outbound = "final";
          }
          # private network
          {
            action = "route";
            ip_cidr = [
              "172.16.0.0/12"
              "10.0.0.0/8"
            ];
            outbound = "private";
          }
          # ssh
          {
            action = "route";
            network = [ "tcp" ];
            port = [ 22 ];
            outbound = "direct-auto";
          }
          # wireguard
          {
            action = "route";
            network = [ "udp" ];
            port = [ 51820 ];
            outbound = "direct-auto";
          }
          # steam game
          {
            action = "route";
            type = "logical";
            mode = "and";
            rules = [
              {
                network = [ "udp" ];
                port_range = [ "27000:27100" ];
              }
              {
                invert = true;
                rule_set = "geoip-cn";
              }
            ];
            outbound = "game";
          }
          # direct
          {
            action = "route";
            domain_suffix = [
              "steamcontent.com"
              "sharepoint.com"
            ];
            rule_set = [
              "geoip-cn"
              "geosite-cn"
            ];
            outbound = "direct";
          }
          # openai
          {
            action = "route";
            rule_set = [
              "geosite-openai"
            ];
            outbound = "ai";
          }
          # proxy
          {
            action = "route";
            domain_keyword = [ "libgen" ];
            domain_suffix = [
              "mikanani.me"
              "nixos.org"
              "sing-box.sagernet.org"
              "attic.csrc.eu.org"
            ];
            rule_set = [
              "geoip-telegram"
              "geosite-gfw"
              "geosite-steam"
            ];
            outbound = "proxy";
          }
        ];
      };
      services = [
        {
          type = "resolved";
          listen = "::";
          listen_port = 53;
        }
      ];
    };
  };
}
