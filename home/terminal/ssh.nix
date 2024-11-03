{
  lib,
  config,
  pkgs,
  self,
  ...
}:
with lib;
let
  inherit (self.lib) genAttrs';
in
{
  config = mkMerge [
    {
      programs.ssh = {
        enable = true;
        addKeysToAgent = "yes";
        serverAliveInterval = 60;
        matchBlocks = genAttrs' (attrsToList self.vars.hostIP) (host: {
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
