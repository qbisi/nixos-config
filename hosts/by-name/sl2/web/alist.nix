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
    alist = {
      enable = true;
      group = "acme";
      settings = {
        scheme = {
          http_port = null;
          unix_file = "/run/alist/socket";
          unix_file_perm = "660";
        };
      };
    };
  };

  services.nginx = {
    enable = true;
    group = "acme";
    defaultSSLListenPort = 443;
    virtualHosts."drive.${config.networking.domain}" = {
      addSSL = true;
      useACMEHost = config.networking.domain;
      locations = {
        "/" = {
          proxyPass = "http://unix:${config.services.alist.settings.scheme.unix_file}";
        };
      };
    };
  };
}
