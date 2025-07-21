{
  config,
  pkgs,
  lib,
  self,
  ...
}:
with lib;
let
  cfg = config.services.sing-box;
  sing-ruleset = pkgs.symlinkJoin {
    name = "sing-ruleset";
    paths = cfg.rule_packages;
  };
  settingsFormat = pkgs.formats.json { };
  selectorOpts =
    { config, ... }:
    {
      options = {
        tag = mkOption {
          type = types.str;
        };
        type = mkOption {
          type =
            with types;
            enum [
              "selector"
              "urltest"
            ];
          default = "selector";
        };
        outbounds = mkOption {
          type = types.nonEmptyListOf types.str;
        };
        default = mkOption {
          type = types.str;
          default = "";
        };
        interrupt_exist_connections = mkEnableOption "interrupt exist connections";
      };
      config = {
        outbounds = forEach (filter (x: elem config.tag x.group or [ ]) cfg.outbounds.other) (x: x.tag);
      };
    };
  commonOpts =
    { config, ... }:
    {
      tag = mkOption {
        type = with types; either str (functionTo str);
        default =
          config:
          lib.genTag [
            "type"
            "server"
            "bind_interface"
          ] config;
        apply = type: if isFunction type then type config else type;
      };
      type = mkOption {
        type = types.str;
      };
      group = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };
  directOpts =
    args@{ config, ... }:
    {
      freeformType = settingsFormat.type;
      options = commonOpts args;
      config = {
        type = "direct";
      };
    };
  socksOpts =
    args@{ config, ... }:
    {
      freeformType = settingsFormat.type;
      options = {
        server = mkOption {
          type = types.nonEmptyStr;
        };
        server_port = mkOption {
          type = types.port;
          default = 1080;
        };
      } // (commonOpts args);
      config = {
        type = "socks";
      };
    };
  vlessOpts =
    args@{ config, ... }:
    {
      freeformType = settingsFormat.type;
      options = {
        server = mkOption {
          type = types.nonEmptyStr;
          default = config.tls.server_name;
        };
        server_port = mkOption {
          type = types.port;
          default = 443;
        };
        flow = mkOption {
          type = types.str;
          default = "xtls-rprx-vision";
        };
        tls = {
          enabled = mkOption {
            type = types.bool;
            default = true;
          };
          reality = {
            enabled = mkEnableOption "reality";
            public_key = mkOption {
              type = with types; either str attrs;
              apply =
                v:
                assert (config.tls.reality.enabled -> v != "");
                v;
              default = "";
            };
            short_id = mkOption {
              type = types.str;
              default = "";
            };
          };
          utls = {
            enabled = mkOption {
              type = types.bool;
              default = true;
            };
            fingerprint = mkOption {
              type = types.enum [
                "chrome"
                "firefox"
                "edge"
                "safari"
                "360"
                "qq"
                "ios"
                "android"
                "random"
                "randomized"
              ];
              default = "chrome";
            };
          };
          server_name = mkOption {
            type = types.str;
            default = "";
          };
        };
      } // (commonOpts args);
      config = {
        type = "vless";
      };
    };
  hysteria2Opts =
    args@{ config, ... }:
    {
      freeformType = settingsFormat.type;
      options = {
        server = mkOption {
          type = types.nonEmptyStr;
          default = config.tls.server_name;
        };
        tls = {
          enabled = mkOption {
            type = types.bool;
            default = true;
          };
          server_name = mkOption {
            type = types.str;
            default = "";
          };
          alpn = mkOption {
            type =
              with types;
              listOf (enum [
                "http/1.1"
                "h2"
                "h3"
              ]);
            default = [ "h3" ];
          };
        };
      } // (commonOpts args);
      config = {
        type = "hysteria2";
      };
    };
in
{
  options = {
    services.sing-box = {
      rule_packages = mkOption {
        type = types.listOf types.package;
        default = [
          pkgs.sing-geoip
          pkgs.sing-geosite
        ];
      };
      rule_set = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      outbounds = {
        selector = mkOption {
          type = types.listOf (types.submodule selectorOpts);
          default = [ ];
        };
        other = mkOption {
          type = types.listOf settingsFormat.type;
          default = [ ];
        };
        direct = mkOption {
          type = types.listOf (types.submodule directOpts);
          default = [ ];
        };
        socks = mkOption {
          type = types.listOf (types.submodule socksOpts);
          default = [ ];
        };
        vless = mkOption {
          type = types.listOf (types.submodule vlessOpts);
          default = [ ];
        };
        hysteria2 = mkOption {
          type = types.listOf (types.submodule hysteria2Opts);
          default = [ ];
        };
      };
    };
  };

  config = mkIf config.services.sing-box.enable {

    environment.systemPackages = [ config.services.sing-box.package ];

    services.sing-box = {
      outbounds = {
        direct = [
          {
            tag = "direct-auto";
            tcp_multi_path = true;
          }
        ];
        other = with cfg.outbounds; direct ++ socks ++ vless ++ hysteria2;
      };

      settings = {
        outbounds = cfg.outbounds.selector ++ forEach cfg.outbounds.other (x: removeAttrs x [ "group" ]);
        route.rule_set = lib.forEach cfg.rule_set (v: {
          type = "local";
          tag = v;
          format = "binary";
          path = "${sing-ruleset}/share/sing-box/rule-set/${v}.srs";
        });
      };
    };
  };
}
