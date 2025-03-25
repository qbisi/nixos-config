{
  lib,
  pkgs,
  config,
  self,
  ...
}:
{
  networking.firewall.allowedTCPPorts = [
    3000
  ];

  services.hydra = {
    enable = true;
    listenHost = "*";
    hydraURL = "https://hydra.csrc.eu.org";
    useSubstitutes = true;
    notificationSender = self.vars.user.mail;
    extraConfig = ''
      max_output_size = ${builtins.toString (32 * 1024 * 1024 * 1024)}
    '';
  };

  nix.settings.allowed-uris = [
    "github:"
    "git+https://github.com/"
    "git+ssh://github.com/"
  ];
}
