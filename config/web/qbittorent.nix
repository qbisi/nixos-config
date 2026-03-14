{
  config,
  pkgs,
  lib,
  self,
  inputs,
  ...
}:
{
  services.qbittorrent = {
    enable = true;
    webuiPort = 8080;
    torrentingPort = 5080;
    openFirewall = true;
  };

  networking.firewall.allowedTCPPorts = [ config.services.qbittorrent.torrentingPort ];

  services.nginx = {
    enable = true;
    virtualHosts."qbittorent" = {
      serverName = lib.mkDefault "qbittorent.${config.services.nginx.serverName}";
      addSSL = true;
      useACMEHost = config.networking.domain;
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.qbittorrent.webuiPort}";
        };
      };
    };
  };
}
