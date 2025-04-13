{ config, pkgs, ... }:
{
  home.username = "qbisi";
  home.homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "/Users/${config.home.username}"
    else
      "/home/${config.home.username}";
}
