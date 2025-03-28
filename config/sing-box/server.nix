{
  config,
  pkgs,
  lib,
  self,
  ...
}:
with lib;
let
  uuid = {
    _secret = "/run/keys/sing-uuid";
  };
  certDir = config.security.acme.certs.${config.networking.domain}.directory;
in
{
  networking = {
    firewall.allowedUDPPortRanges = [
      {
        from = 2080;
        to = 3000;
      }
    ];
    nftables = {
      enable = true;
      tables = {
        hysteria_porthopping = {
          enable = true;
          family = "inet";
          content = ''
            define INGRESS_INTERFACE="eth0"
            define PORT_RANGE=2080-3000
            define HYSTERIA_SERVER_PORT=443

            chain prerouting {
              type nat hook prerouting priority dstnat; policy accept;
              iifname $INGRESS_INTERFACE udp dport $PORT_RANGE counter redirect to :$HYSTERIA_SERVER_PORT
            }
          '';
        };
      };
    };
  };

  systemd.services.sing-box.serviceConfig = {
    Group = "acme";
    MemoryMax = "200M";
  };
  services.sing-box.enable = true;
  services.sing-box.rule_set = [
    "geoip-cn"
    "geosite-cn"
  ];
  services.sing-box.settings = {
    dns = {
      servers = [ { address = "tls://1.1.1.1"; } ];
    };
    inbounds = [
      {
        listen = "::";
        listen_port = 1080;
        tag = "socks-in";
        type = "socks";
        udp_fragment = true;
      }
      {
        tag = "reality-in";
        listen = "::";
        listen_port = 443;
        multiplex = {
          brutal = {
            down_mbps = 480;
            enabled = true;
            up_mbps = 480;
          };
          enabled = true;
          padding = false;
        };
        sniff = true;
        sniff_override_destination = true;
        tcp_multi_path = true;
        tls = {
          enabled = true;
          reality = {
            enabled = true;
            private_key = {
              _secret = "/run/keys/sing-key";
            };
            handshake = {
              server = "127.0.0.1";
              server_port = config.services.nginx.defaultSSLListenPort;
            };
            short_id = [ "" ];
          };
          server_name = config.networking.fqdn;
        };
        type = "vless";
        users = [
          {
            flow = "xtls-rprx-vision";
            inherit uuid;
          }
        ];
      }
      {
        listen = "127.0.0.1";
        listen_port = 8001;
        sniff = true;
        sniff_override_destination = true;
        transport = {
          service_name = "grpc";
          type = "grpc";
        };
        type = "vless";
        users = [ { inherit uuid; } ];
      }
      {
        listen = "127.0.0.1";
        listen_port = 8000;
        sniff = true;
        sniff_override_destination = true;
        transport = {
          early_data_header_name = "Sec-WebSocket-Protocol";
          max_early_data = 2048;
          path = "/lessws";
          type = "ws";
        };
        type = "vless";
        users = [ { inherit uuid; } ];
      }
      {
        tag = "hysteria2-in";
        type = "hysteria2";
        listen = "::";
        listen_port = 443;
        sniff = true;
        sniff_override_destination = true;
        up_mbps = 480;
        down_mbps = 480;
        users = [
          {
            password = uuid;
          }
        ];
        masquerade = "https://${config.networking.fqdn}";
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
    log = {
      level = "error";
    };
    outbounds = [
      {
        domain_strategy = "ipv4_only";
        tag = "direct";
        type = "direct";
      }
      {
        tag = "dns-out";
        type = "dns";
      }
      {
        local_address = [
          "172.16.0.2/32"
          "2606:4700:110:8f3f:34c1:705c:6bb6:b69f/128"
        ];
        mtu = 1280;
        peer_public_key = "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=";
        private_key = {
          _secret = "/run/keys/sing-wgcf";
        };
        reserved = [
          115
          252
          141
        ];
        server = "162.159.192.123";
        server_port = 2506;
        tag = "wgcf";
        type = "wireguard";
      }
    ];
    route = {
      final = "direct";
      rules = [
        {
          outbound = "dns-out";
          protocol = "dns";
        }
        {
          mode = "or";
          outbound = "wgcf";
          rules = [
            { ip_version = 6; }
            {
              rule_set = [
                "geoip-cn"
                "geosite-cn"
              ];
            }
          ];
          type = "logical";
        }
      ];
    };
  };
}
