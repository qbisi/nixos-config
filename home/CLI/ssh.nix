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
        matchBlocks = self.lib.genAttrs' (lib.attrsToList self.vars.hostIP) (host: {
          hostname = host.value;
        });
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
