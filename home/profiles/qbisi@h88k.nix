{
  config,
  pkgs,
  self,
  ...
}:
{
  imports = [
    ./qbisi.nix
  ];

  home.sessionVariables = { };

  services.ssh-agent.enable = true;

  programs.ssh.matchBlocks."github.com".proxyJump = "hk";

  home.packages = with pkgs; [ ];
}
