{
  pkgs,
  lib,
  config,
  self,
  inputs,
  ...
}:
{
  security.acme = {
    certs."csrc.eu.org" = {
      extraDomainNames = [
        "*.csrc.eu.org"
      ];
      dnsProvider = "cloudflare";
      environmentFile = config.age.secrets.acme.path or "/run/keys/acme";
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts."x79-harmonia" = {
      serverName = "cache.csrc.eu.org";
      addSSL = true;
      useACMEHost = "csrc.eu.org";
      locations = {
        "/" = {
          proxyPass = "https://${self.vars.hosts.x79.wgip}";
          recommendedProxySettings = true;
          extraConfig = ''
            proxy_ssl_server_name on;
            proxy_ssl_name cache.csrc.eu.org;
          '';
        };
      };
    };
    virtualHosts."x79-hydra" = {
      serverName = "hydra.csrc.eu.org";
      addSSL = true;
      useACMEHost = "csrc.eu.org";
      locations = {
        "/" = {
          proxyPass = "https://${self.vars.hosts.x79.wgip}";
          recommendedProxySettings = true;
          extraConfig = ''
            proxy_ssl_server_name on;
            proxy_ssl_name hydra.csrc.eu.org;
          '';
        };
      };
    };
  };
}
