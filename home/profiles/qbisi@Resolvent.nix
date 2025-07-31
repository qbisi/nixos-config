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

  home.sessionVariables = {
    http_proxy = self.vars.http_proxy;
    https_proxy = self.vars.http_proxy;
  };

  programs.ssh.matchBlocks."github.com".proxyJump = "sl2";
}
