{
  lib,
  config,
  pkgs,
  self,
  inputs,
  modulesPath,
  ...
}:
{
  deployment.keys = {
    acme = {
      keyFile = /run/user/1000/agenix/acme;
      user = "acme";
      group = "acme";
    };
    ddclient.keyFile = /run/user/1000/agenix/ddclient;
    "sing-uuid".keyFile = /run/user/1000/agenix/sing-uuid;
    "sing-key".keyFile = /run/user/1000/agenix/sing-key;
    "sing-wgcf".keyFile = /run/user/1000/agenix/sing-wgcf;
  };

  imports = [
    ./sing-box/server.nix
    ./nettools.nix
  ];

  networking = {
    domain = self.vars.domain;
    nftables.enable = true;
    firewall = {
      allowedTCPPorts = [
        80
        443
        5201
      ];
      allowedUDPPorts = [
        443
        5201
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
    certs."${config.networking.domain}" = {
      domain = "*.${config.networking.domain}";
      dnsProvider = "cloudflare";
      environmentFile = "/run/keys/acme";
    };
  };

  services.nginx = {
    enable = true;
    group = "acme";
    defaultSSLListenPort = 8443;
    virtualHosts."${config.networking.fqdn}" = {
      addSSL = true;
      useACMEHost = config.networking.domain;
      locations = {
        "/" = {
          proxyPass = "http://localhost:3000";
        };
      };
    };
  };

  services.ddclient = {
    enable = true;
    usev4 = "webv4, webv4=ipv4.ident.me/";
    # usev6 = "webv6, webv6=ipv6.ident.me/";
    protocol = "cloudflare";
    domains = [ config.networking.fqdn ];
    zone = config.networking.domain;
    username = self.vars.user.mail;
    passwordFile = "/run/keys/ddclient";
  };

}
