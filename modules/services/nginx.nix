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
  options.services.nginx = {
    serverName = lib.mkOption {
      type = lib.types.str;
      default = config.networking.fqdnOrHostName;
      description = ''
        The server name for the nginx virtual host.
        This is used to generate the SSL certificate.
      '';
    };
  };

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
