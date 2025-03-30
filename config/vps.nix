{
  lib,
  config,
  pkgs,
  self,
  inputs,
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

  boot = {
    kernelModules = [ "brutal" ];
    extraModulePackages = [ (pkgs.tcp-brutal.override { linux = config.boot.kernelPackages.kernel; }) ];
  };

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

  services.vnstat.enable = true;

  systemd.services.vnstat-alert = {
    after = [ "vnstat.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      RestartSec = 600;
    };
    path = with pkgs; [ vnstat ];
    script = ''
      set +e
      OUTPUT=$(vnstat -i eth0 --alert 1 3 m tx 100 GB 2>&1)
      RETVAL=$?

      echo "$OUTPUT"

      if echo "$OUTPUT" | grep -q "No month data available"; then
          exit 0
      else
          exit $RETVAL
      fi
    '';
  };
}
