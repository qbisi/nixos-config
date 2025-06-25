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

  programs.ssh.matchBlocks."github.com".proxyJump = "sl2";

  home.packages = with pkgs; [
    corefonts
    vista-fonts
  ];

  fonts.fontconfig.enable = true;
}
