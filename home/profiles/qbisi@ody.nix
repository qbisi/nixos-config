{
  config,
  pkgs,
  self,
  ...
}:
{
  imports = [
    ./qbisi.nix
    self.homeManagerModules.secrets
  ];

  home.sessionVariables = {
    http_proxy = "http://127.0.0.1:1080";
    https_proxy = "http://127.0.0.1:1080";
  };

  services.ssh-agent.enable = true;

  programs.ssh.matchBlocks."github.com".proxyJump = "hk";
}