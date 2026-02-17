{ inputs, ... }:
{
  imports = [
    inputs.nix-rosetta-builder.darwinModules.default
  ];

  nix-rosetta-builder.onDemand = true;

  nix.settings = {
    warn-dirty = false;
    substituters = [ "https://mirrors.ustc.edu.cn/nix-channels/store" ];
    experimental-features = "nix-command flakes";
  };

  nixpkgs.system = "aarch64-darwin";

  system.stateVersion = 6;
}
