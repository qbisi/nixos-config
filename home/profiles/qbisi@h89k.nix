{
  config,
  pkgs,
  self,
  ...
}:
{
  imports = [
    ./qbisi.nix
    ../texlive.nix
  ];

  services.ssh-agent.enable = true;

  programs.ssh.matchBlocks."github.com".proxyJump = "hk";

  home.packages = with pkgs; [
    telegram-desktop
    qq
  ];

  programs.vscode.enable=true;
}
