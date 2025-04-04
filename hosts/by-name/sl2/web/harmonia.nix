{
  pkgs,
  lib,
  config,
  self,
  inputs,
  ...
}:
{
  services.harmonia = {
    enable = true;
    signKeyPaths = [ config.age.secrets.harmonia.path ];
    settings = {
      bind = "unix:/run/harmonia/socket";
      priority = 41;
    };
  };

  services.nginx = {
    virtualHosts."cache.${config.networking.domain}" = {
      addSSL = true;
      useACMEHost = config.networking.domain;
      locations = {
        "/" = {
          proxyPass = "http://${config.services.harmonia.settings.bind}";
          recommendedProxySettings = true;
        };
      };
    };
  };
}
