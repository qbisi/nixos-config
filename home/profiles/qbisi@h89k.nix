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

  services.ssh-agent.enable = true;

  programs.ssh.matchBlocks."github.com".proxyJump = "hk";

  home.packages = with pkgs; [
    telegram-desktop
    corefonts
    vista-fonts
  ];

  fonts.fontconfig.enable = true;
}
