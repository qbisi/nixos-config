{
  config,
  pkgs,
  lib,
  self,
  inputs,
  ...
}:
{
  services = {
    openlist = {
      enable = true;
      group = "acme";
      settings = {
        scheme = {
          http_port = null;
          unix_file = "/run/openlist/socket";
          unix_file_perm = "660";
        };
      };
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts."drive" = {
      serverName = lib.mkDefault "drive.${config.services.nginx.serverName}";
      addSSL = true;
      useACMEHost = config.networking.domain;
      locations = {
        "/" = {
          proxyPass = "http://unix:${config.services.openlist.settings.scheme.unix_file}";
        };
      };
    };
  };
}
