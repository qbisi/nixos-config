{
  lib,
  pkgs,
  config,
  self,
  inputs,
  ...
}:
let
  domain = config.networking.domain;
in
{
  security.acme = lib.mkIf (domain != null) {
    acceptTerms = true;
    defaults.email = lib.mkDefault self.vars.user.mail;
    defaults.server = "https://acme.zerossl.com/v2/DV90";
    defaults.extraLegoFlags = [
      "--eab"
    ];
    certs."${domain}" = {
      extraDomainNames = [
        "*.${domain}"
        "*.${config.networking.fqdn}"
      ];
      dnsProvider = "cloudflare";
      environmentFile = config.age.secrets.acme.path or "/run/keys/acme";
    };
  };
}
