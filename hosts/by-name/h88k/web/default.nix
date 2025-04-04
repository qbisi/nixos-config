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
          proxyPass = "http://unix:${config.services.alist.settings.scheme.unix_file}";
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
