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
}
