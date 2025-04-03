{
  lib,
  pkgs,
  config,
  self,
  inputs,
  ...
}:
{
  services.nginx = {
    virtualHosts."attic.${config.networking.domain}" = {
      addSSL = true;
      useACMEHost = config.networking.domain;
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:8080";
          recommendedProxySettings = true;
        };
      };
    };
  };

  services.atticd = {
    enable = true;
    settings = {};
    environmentFile = config.age.secrets.token.path;
  };
}
