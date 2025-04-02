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
      settings = { };
    };
  };

  networking = {
    domain = self.vars.domain;
    # acme get confused by hijacked sing-box dns response
    tproxy.groups = [ "acme" ];
    firewall = {
      allowedTCPPorts = [
        443
      ];
      allowedUDPPorts = [
        443
      ];
    };
  };

  services.nginx = {
    enable = true;
    group = "acme";
    defaultSSLListenPort = 443;
    virtualHosts."drive.${config.networking.fqdn}" = {
      addSSL = true;
      useACMEHost = config.networking.domain;
      locations = {
        "/" = {
          proxyPass = "http://localhost:5244";
        };
      };
    };

    virtualHosts."jellyfin.${config.networking.fqdn}" = {
      addSSL = true;
      useACMEHost = config.networking.domain;
      locations = {
        "/" = {
          proxyPass = "http://localhost:8096";
        };
      };
    };
  };
}
