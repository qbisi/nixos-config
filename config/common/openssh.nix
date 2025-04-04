{
  lib,
  pkgs,
  config,
  self,
  inputs,
  ...
}:
{
  programs.ssh = {
    extraConfig = ''
      Match user root
          IdentityFile ${config.age.secrets.id_ed25519.path}

      Match user hydra-queue-runner
          IdentityFile ${config.age.secrets.hydra_ed25519.path}
    '';

    knownHosts = lib.mapAttrs (_: value: {
      extraHostNames = [ value.ip ];
      publicKey = value.sshpub;
    }) self.vars.hosts;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      X11Forwarding = true;
    };
  };
}
