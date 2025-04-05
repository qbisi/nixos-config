{
  config,
  pkgs,
  lib,
  self,
  inputs,
  ...
}:
let
  cfg = config.services.nginx;
in
{
  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [
        cfg.defaultHTTPListenPort
        cfg.defaultSSLListenPort
      ];
    };

    services.nginx = {
      group = "acme";
    };
  };
}
