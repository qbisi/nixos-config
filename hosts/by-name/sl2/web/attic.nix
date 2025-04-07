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
    enable = true;
    virtualHosts."attic" = {
      serverName = "attic.csrc.eu.org";
      addSSL = true;
      useACMEHost = "csrc.eu.org";
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:8080";
          recommendedProxySettings = true;
          extraConfig = ''
            client_max_body_size 2048m;
          '';
        };
      };
    };
  };

  services.atticd = {
    enable = true;
    settings = { };
    environmentFile = config.age.secrets.token.path;
  };
}
