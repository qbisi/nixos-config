{ config, pkgs, ... }:
{
  imports = [ ./qbisi.nix ];

  programs.ssh.matchBlocks."github.com".proxyJump = "hk";
}
