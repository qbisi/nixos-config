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
    ../apps/thunderbird.nix
  ];

  home.sessionVariables = {
    http_proxy = "http://127.0.0.1:1080";
    https_proxy = "http://127.0.0.1:1080";
  };

  services.ssh-agent.enable = true;

  programs.ssh.matchBlocks."github.com".proxyJump = "hk";

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };

  home.packages = with pkgs; [
    telegram-desktop
    qq
    # wechat-uos
    # zotero
  ];
}
