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
    sing-uuid = {
      keyFile = /run/user/1000/agenix/sing-uuid;
      user = "sing-box";
    };
    sing-key = {
      keyFile = /run/user/1000/agenix/sing-key;
      user = "sing-box";
    };
    sing-wgcf = {
      keyFile = /run/user/1000/agenix/sing-wgcf;
      user = "sing-box";
    };
  };

  imports = [
    ./sing-box/server.nix
  ];

  boot.kernelModules = [ "brutal" ];

  networking = {
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

  services.nginx = {
    enable = true;
    defaultSSLListenPort = 8443;
    virtualHosts."${config.networking.fqdn}" = {
      addSSL = true;
      useACMEHost = config.networking.domain;
      locations = {
        "/" = {
          return = "403";
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

  services.mptcpd = {
    enable = true;
    extraMptcpdFlags = [
      "--path-manager=sspi"
      "--addr-flags=signal"
      "--notify-flags=existing,skip_link_local,skip_loopback,check_route"
    ];
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
