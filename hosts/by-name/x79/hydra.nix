{
  lib,
  pkgs,
  config,
  self,
  ...
}:
{

  services.nginx = {
    enable = true;
    virtualHosts."hydra" = {
      serverName = lib.mkDefault "hydra.${config.services.nginx.serverName}";
      addSSL = true;
      useACMEHost = config.networking.domain;
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:3000";
          recommendedProxySettings = true;
        };
      };
    };
  };

  services.hydra = {
    enable = true;
    listenHost = "127.0.0.1";
    hydraURL = "https://${config.services.nginx.virtualHosts.hydra.serverName}";
    useSubstitutes = true;
    notificationSender = "hydra@localhost"; # e-mail of hydra service
    minimumDiskFreeEvaluator = 20;
    minimumDiskFree = 20;
    extraEnv = config.networking.proxy.envVars;
    extraConfig = ''
      max_output_size = ${builtins.toString (32 * 1024 * 1024 * 1024)}
    '';
    buildMachinesFiles = [
      "${pkgs.writeText "machine" ''
        localhost ${config.nixpkgs.system} - 2 1 kvm,nixos-test,big-parallel,benchmark - -
      ''}"
      "/etc/nix/machines"
    ];
  };

  systemd.services.hydra-update-gc-roots = {
    serviceConfig = {
      onSuccess = [
        "attic-upload.service"
      ];
    };
    startAt = lib.mkForce "12:00";
  };

  systemd.services.attic-upload = {
    path = [
      pkgs.attic-client
      pkgs.bash
    ];
    environment = config.networking.proxy.envVars;
    script = ''
      find /nix/var/nix/gcroots/hydra -type f -exec \
        bash -c 'attic push nur-fem "/nix/store/$(basename "$1")"' _ {} \;
    '';
    serviceConfig = {
      User = "qbisi";
    };
  };

  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
      dates = "weekly";
    };

    settings = {
      auto-optimise-store = true;
      allowed-uris = [
        "github:"
        "git+https://github.com/"
        "git+ssh://github.com/"
      ];
    };
  };
}
