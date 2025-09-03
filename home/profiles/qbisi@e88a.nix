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

  home.sessionVariables = rec {
    http_proxy = "http://127.0.0.1:1080";
    https_proxy = http_proxy;
  };

  services.ssh-agent.enable = true;
}
