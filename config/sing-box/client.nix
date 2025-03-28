{
  config,
  pkgs,
  lib,
  self,
  ...
}:
let
  inherit (self.lib) cartesianProduct';
  inherit (lib) forEach;
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
    systemd.services.sing-box.serviceConfig = {
      Group = "proxy";
      MemoryMax = "400M";
    };

    users.groups.proxy.members = [ config.users.users.admin.name ];

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
        {
          tag = "proxy";
          default = "reality-jp1.qbisi.cc-eth0";
        }
        { tag = "game"; }
        { tag = "ai"; }
        {
          tag = "final";
          outbounds = [ "proxy" ];
        }
      ];

      direct = cartesianProduct' {
        bind_interface = [
          "eth0"
          "wwan0"
          "wlan0"
        ];
        group = [
          [
            "direct"
            "final"
            "game"
            "proxy"
          ]
        ];
      };

      vless = cartesianProduct' {
        bind_interface = [
          "eth0"
          "wwan0"
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
          + self.lib.genTag [
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
        bind_interface = "wwan0";
        down_mbps = 150;
        up_mbps = 50;
        password = uuid;
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

      other = [
        {
          tag = "block";
          type = "block";
        }
        {
          tag = "dns-out";
          type = "dns";
        }
      ];
    };

    services.sing-box.settings = {
      log = {
        level = "error";
      };
      dns = {
        rules = [
          {
            rule_set = [ "geosite-cn" ];
            server = "alidns";
          }
        ];
        servers = [
          {
            address = "223.5.5.5";
            detour = "direct";
            tag = "alidns";
          }
        ];
      };
      experimental = {
        cache_file = {
          cache_id = "";
          enabled = true;
          path = "";
          store_fakeip = false;
          # Store rejected DNS response cache in the cache file
          store_rdrc = false;
          rdrc_timeout = "7d";
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
          sniff = true;
          tag = "mixed-in";
          type = "mixed";
        }
        {
          listen = "::";
          listen_port = 60000;
          sniff = true;
          sniff_override_destination = true;
          tag = "tproxy-in";
          type = "tproxy";
        }
      ];
      route = {
        final = "final";
        rules = [
          {
            outbound = "dns-out";
            protocol = "dns";
          }
          {
            clash_mode = "global";
            outbound = "final";
          }
          {
            ip_cidr = [
              "172.16.0.1/12"
              "10.0.0.0/8"
            ];
            outbound = "direct-eth0";
          }
          {
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
          {
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
          {
            rule_set = [
              "geosite-openai"
            ];
            outbound = "ai";
          }
          {
            domain_keyword = [ "libgen" ];
            domain_suffix = [
              "mikanani.me"
              "nixos.org"
              "sing-box.sagernet.org"
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
    };
  };
}
