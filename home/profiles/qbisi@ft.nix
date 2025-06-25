{ config, pkgs, ... }:
{
  imports = [ ./qbisi.nix ];

  programs.ssh.matchBlocks."github.com".proxyJump = "sl2";
}
