{
  config,
  pkgs,
  lib,
  self,
  ...
}:
with lib;
let
  cfg = config.services.sing-box.outbounds;
  settingsFormat = pkgs.formats.json { };
  genTag = list: args: (concatStringsSep "-" (remove "" (forEach list (x: args.${x} or ""))));
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
        interrupt_exist_connections = mkEnableOption "interrupt exist connections";
      };
      config = {
        outbounds = forEach (filter (x: elem config.tag x.group or [ ]) cfg.other) (x: x.tag);
      };
    };
  commonOpts =
    { config, ... }:
    {
      tag = mkOption {
        type = with types; either str (functionTo str);
        default =
          config:
          genTag [
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
        server_ports = mkOption {
          type = types.nonEmptyStr;
          default = "2080:3000";
        };
        hop_interval = mkOption {
          type = types.nonEmptyStr;
          default = "30s";
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
      outbounds = {
        selector = mkOption {
          type = with types; listOf (submodule selectorOpts);
          default = [ ];
        };
        other = mkOption {
          type = types.listOf settingsFormat.type;
          default = [ ];
        };
        direct = mkOption {
          type = with types; listOf (submodule directOpts);
          default = [ ];
        };
        socks = mkOption {
          type = with types; listOf (submodule socksOpts);
          default = [ ];
        };
        vless = mkOption {
          type = with types; listOf (submodule vlessOpts);
          default = [ ];
        };
        hysteria2 = mkOption {
          type = with types; listOf (submodule hysteria2Opts);
          default = [ ];
        };
      };
    };
  };

  config = mkIf config.services.sing-box.enable {

    environment.systemPackages = [ config.services.sing-box.package ];

    services.sing-box = {
      outbounds.other = with cfg; direct ++ socks ++ vless ++ hysteria2;
      settings = {
        outbounds = cfg.selector ++ forEach cfg.other (x: removeAttrs x [ "group" ]);
      };
    };
  };
}
