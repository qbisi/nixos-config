{
  config,
  pkgs,
  self,
  ...
}:
{
  imports = [ ./qbisi.nix ];

  home.sessionVariables = {
    http_proxy = "http://${self.vars.hosts.h88k.ip}:1080";
    https_proxy = "http://${self.vars.hosts.h88k.ip}:1080";
  };
}
