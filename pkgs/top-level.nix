{ pkgs, ... }:
let
  callPackage = pkgs.newScope packages;
  packages = rec {
    mptcpd = callPackage ./mptcpd.nix { };
  };
in
packages
