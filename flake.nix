{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-images.url = "github:qbisi/nixos-images";
    secrets.url = "git+ssh://git@github.com/qbisi/secrets";
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
    vscode-server = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/nixos-vscode-server";
    };
    nix-vscode-extensions = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/nix-vscode-extensions";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { nixpkgs, flake-parts, ... }@inputs:
    inputs.flake-parts.lib.mkFlake
      {
        inherit inputs;
        specialArgs = {
          lib = nixpkgs.lib.foldl' (prev: overlay: prev.extend overlay) nixpkgs.lib [
            (l: _: import ./lib.nix l)
          ];
        };
      }
      {
        systems = nixpkgs.lib.systems.flakeExposed;

        imports = [
          flake-parts.flakeModules.easyOverlay
          ./home
          ./hosts
          ./modules
          ./vars
        ];

        perSystem =
          {
            config,
            lib,
            pkgs,
            inputs',
            ...
          }:
          {
            formatter = pkgs.nixfmt-rfc-style;

            overlayAttrs = config.legacyPackages;

            legacyPackages = lib.makeScope pkgs.newScope (
              self:
              inputs'.nixvim.legacyPackages
              // lib.packagesFromDirectoryRecursive {
                inherit (self) callPackage;
                directory = ./pkgs;
              }
            );
          };
      };
}
