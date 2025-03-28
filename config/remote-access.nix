{
  lib,
  config,
  pkgs,
  self,
  inputs,
}:
{
  networking = {
    firewall.allowedTCPPorts = [
      8443
    ];
    allowedUDPPorts = [
      8443 # hy2-in
    ];
  };

  services.sing-box = {
    settings = {
      inbounds = [
        {
          tag = "hysteria2-in";
          type = "hysteria2";
          listen = "::";
          listen_port = 8443;
          sniff = true;
          sniff_override_destination = true;
          up_mbps = 10;
          down_mbps = 40;
          users = [
            {
              password = {
                _secret = config.age.secrets."sing-uuid".path;
              };
            }
          ];
          masquerade = "https://www.baidu.com";
          tls =
            let
              certDir = config.security.acme.certs.${config.networking.domain}.directory;
            in
            {
              enabled = true;
              alpn = [
                "h3"
              ];
              certificate_path = certDir + "/cert.pem";
              key_path = certDir + "/key.pem";
            };
        }
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
      environmentFile = config.age.secrets.acme.path;
    };
  };

  services.ddclient = {
    enable = true;
    usev4 = "";
    usev6 = "ifv6, ifv6=wwan0";
    protocol = "cloudflare";
    domains = [ config.networking.fqdn ];
    zone = config.networking.domain;
    username = self.vars.user.mail;
    passwordFile = config.age.secrets.ddclient.path;
  };

  systemd.services.ddclient.serviceConfig.Group = "proxy";
}
