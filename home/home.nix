{
  config,
  pkgs,
  system,
  inputs,
  ...
}:
{
  imports = [
    ./terminal/zsh.nix
    ./terminal/git.nix
    ./terminal/ssh.nix
  ];

  systemd.user.startServices = "sd-switch";

  home.sessionVariables = {
    EDITOR = "vim";
    CACHIX_AUTH_TOKEN = "$(${pkgs.coreutils}/bin/cat ${config.age.secrets.cachix.path} 2>/dev/null)";
    GITHUB_TOKEN = "$(${pkgs.coreutils}/bin/cat ${config.age.secrets.github.path} 2>/dev/null)";
  };

  home.packages = with pkgs; [
    # github cli 
    gh
    nixpkgs-review
    cachix

    # serial tool
    # minicom
    # rkdeveloptool

    # formatter
    nixfmt-rfc-style

    # colmena
    colmena

    # python
    # (python3.withPackages
    # (python-pkgs: with python-pkgs; [
    #   numpy
    #   pip
    # ]))

    devenv

    # agenix
    inputs.agenix.packages.${config.nixpkgs.system}.default
  ];

  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
  };

  nix.registry = {
    nix-develop = {
      to = {
        owner = "qbisi";
        repo = "nix-develop";
        type = "github";
      };
    };
  };

  home.stateVersion = "24.11";
}
