{
  inputs = {
    nixos-images.url = "github:qbisi/nixos-images";
    nixpkgs.follows = "nixos-images/nixpkgs";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    secrets = {
      url = "git+ssh://git@github.com/qbisi/secrets";
      flake = false;
    };
  };
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      imports = [
        ./home
        ./hosts
        ./nixos
        ./pkgs
        ./lib
        "${inputs.secrets}"
        "${inputs.nixos-images}/pkgs"
      ];
      perSystem =
        { config, pkgs, ... }:
        {
          formatter = pkgs.nixfmt-rfc-style;
        };
    };
}