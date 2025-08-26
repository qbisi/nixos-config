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

  systemd.services.sing-box = {
    partOf = lib.mkIf config.systemd.services.vnstat-alert.enable [
      "vnstat-alert.service"
    ];
    after = lib.mkIf config.systemd.services.vnstat-alert.enable [
      "vnstat-alert.service"
    ];
    serviceConfig = {
      Group = lib.mkForce "acme";
      MemoryMax = "200M";
    };
  };

  services.sing-box = {

    enable = true;
    rule_set = [
      "geoip-cn"
      "geosite-cn"
    ];
    settings = {
      log = {
        level = "error";
      };
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
          sniff = true;
          sniff_override_destination = true;
          multiplex = {
            brutal = {
              down_mbps = 480;
              enabled = true;
              up_mbps = 480;
            };
            enabled = true;
            padding = false;
          };
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
          sniff = true;
          sniff_override_destination = true;
          listen = "::";
          listen_port = 443;
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
      # endpoints = [
      #   {
      #     type = "wireguard";
      #     tag = "wgcf";
      #     system = true;
      #     name = "wg0";
      #     mtu = 1280;
      #     address = [
      #       "172.16.0.2/32"
      #       "2606:4700:110:8f3f:34c1:705c:6bb6:b69f/128"
      #     ];
      #     private_key = {
      #       _secret = "/run/keys/sing-wgcf";
      #     };
      #     listen_port = 50080;
      #     peers = [
      #       {
      #         address = "162.159.192.123";
      #         port = 2506;
      #         public_key = "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=";
      #         pre_shared_key = "";
      #         allowed_ips = [
      #           "0.0.0.0/0"
      #         ];
      #         persistent_keepalive_interval = 30;
      #         reserved = [
      #           115
      #           252
      #           141
      #         ];
      #       }
      #     ];
      #   }
      # ];
      outbounds = [
        {
          domain_strategy = "ipv4_only";
          tag = "direct";
          type = "direct";
        }
      ];
      route = {
        final = "direct";
      };
    };
  };
}
