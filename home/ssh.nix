{
  lib,
  config,
  pkgs,
  self,
  ...
}:
{
  services.ssh-agent.enable = pkgs.stdenv.hostPlatform.isLinux;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "ssh.github.com" = {
        port = 443;
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
