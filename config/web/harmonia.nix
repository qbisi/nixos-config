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
    signKeyPaths = [ config.age.secrets."harmonia-${config.networking.hostName}".path ];
    settings = {
      bind = "unix:/run/harmonia/socket";
      priority = 41;
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts."harmonia" = {
      serverName = lib.mkDefault "cache.${config.services.nginx.serverName}";
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
