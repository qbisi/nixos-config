{
  lib,
  pkgs,
  config,
  self,
  ...
}:
{

  services.nginx = {
    virtualHosts."${config.networking.fqdn}" = {
      addSSL = true;
      useACMEHost = config.networking.domain;
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:3000/";
        };
      };
    };
  };

  services.hydra = {
    enable = true;
    listenHost = "127.0.0.1";
    hydraURL = "https://hydra.${config.networking.fqdnOrHostName}";
    useSubstitutes = true;
    notificationSender = self.vars.user.mail;
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

  nix = {
    settings = {
      max-jobs = 4;
      cores = 6;
      auto-optimise-store = true;
      allowed-uris = [
        "github:"
        "git+https://github.com/"
        "git+ssh://github.com/"
      ];
    };
  };
}
