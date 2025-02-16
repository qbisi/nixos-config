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
    extensions = with pkgs.vscode-extensions; [
      dracula-theme.theme-dracula
      yzhang.markdown-all-in-one
      jnoortheen.nix-ide
      james-yu.latex-workshop
      mkhl.direnv
      # ms-python.vscode-pylance
      # ms-python.python
      # ms-python.debugpy
      ms-vscode-remote.remote-ssh
      editorconfig.editorconfig
    ];
  };

  home.packages = with pkgs; [
    telegram-desktop
    qq
    # wechat-uos
    # zotero
  ];
}
