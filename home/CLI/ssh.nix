{
  lib,
  config,
  pkgs,
  self,
  ...
}:
{
  config = lib.mkMerge [
    {
      programs.ssh = {
        enable = true;
        addKeysToAgent = "yes";
        serverAliveInterval = 60;
        matchBlocks = lib.mapAttrs (_: v: { hostname = v.ip; }) self.vars.hosts;
      };
    }

    {
      programs.ssh.matchBlocks = {
        "github.com" = {
          user = "git";
        };
      };
    }
  ];
}
