{
lib,
  config,
  pkgs,
  self,
  ...
}:
{
  imports = [ ./qbisi.nix ];

	services.vscode-server.enable =lib.mkForce false;
}
