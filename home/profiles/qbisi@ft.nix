{ config, pkgs, ... }:
{
  imports = [ ./qbisi.nix ];

  programs.ssh.matchBlocks."github.com".proxyJump = "x79,hk";
}
