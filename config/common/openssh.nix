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
      Match localuser root
          IdentityFile ${config.age.secrets.id_ed25519.path or "~/.ssh/id_ed25519"}

      Match localuser hydra-queue-runner
          IdentityFile ${config.age.secrets.hydra_ed25519.path or "~/.ssh/id_ed25519"}
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
