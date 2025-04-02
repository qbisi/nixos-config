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

  security.acme = {
    acceptTerms = true;
    defaults.email = lib.mkDefault self.vars.user.mail;
    defaults.server = "https://acme.zerossl.com/v2/DV90";
    defaults.extraLegoFlags = [
      "--eab"
    ];
    certs."${config.networking.fqdn}" = {
      domain = "*.${config.networking.fqdn}";
      dnsProvider = "cloudflare";
      environmentFile = config.age.secrets.acme.path;
    };
  };

  services.nginx = {
    enable = true;
    group = "acme";
    defaultSSLListenPort = 443;
    virtualHosts."drive.${config.networking.fqdn}" = {
      addSSL = true;
      useACMEHost = config.networking.fqdn;
      locations = {
        "/" = {
          proxyPass = "http://localhost:5244";
        };
      };
    };

    virtualHosts."jellyfin.${config.networking.fqdn}" = {
      addSSL = true;
      useACMEHost = config.networking.fqdn;
      locations = {
        "/" = {
          proxyPass = "http://localhost:8096";
        };
      };
    };
  };
}
