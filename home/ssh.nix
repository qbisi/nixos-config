{
  lib,
  config,
  pkgs,
  self,
  ...
}:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "github.com" = {
        user = "git";
      };
      "*" = {
        addKeysToAgent = "yes";
        serverAliveInterval = 60;
      };
    }
    // lib.mapAttrs (_: v: { hostname = v.ip; }) self.vars.hosts;
  };
}
