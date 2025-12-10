{
  lib,
  config,
  pkgs,
  inputs,
  inputs',
  system,
  self,
  ...
}:
{
  imports = [
    ./zsh.nix
    ./tmux.nix
    ./ssh.nix
    ./git.nix
  ];

  nixpkgs = {
    overlays = [
      inputs.colmena.overlays.default
      self.overlays.default
    ];
    config.allowUnfree = true;
  };

  systemd.user.startServices = "sd-switch";

  xdg = {
    userDirs = {
      enable = pkgs.stdenv.hostPlatform.isLinux;
      desktop = "${config.home.homeDirectory}/OneDrive/Desktop";
      documents = "${config.home.homeDirectory}/OneDrive/Documents";
      music = "${config.home.homeDirectory}/OneDrive/music";
      pictures = "${config.home.homeDirectory}/OneDrive/Pictures";
      createDirectories = false;
    };
  };

  home = {
    homeDirectory =
      if pkgs.stdenv.hostPlatform.isDarwin then
        "/Users/${config.home.username}"
      else
        "/home/${config.home.username}";

    sessionVariables = {
      EDITOR = "nvim";
      CACHIX_AUTH_TOKEN = "$(${pkgs.coreutils}/bin/cat ${config.age.secrets.cachix.path} 2>/dev/null)";
      GITHUB_TOKEN = "$(${pkgs.coreutils}/bin/cat ${config.age.secrets.github.path} 2>/dev/null)";
      NIXPKGS_ALLOW_UNFREE = "1";
      GOOGLE_DEFAULT_CLIENT_SECRET = "$(${pkgs.coreutils}/bin/cat ${config.age.secrets.google-client.path} 2>/dev/null)";
      GOOGLE_DEFAULT_CLIENT_ID = "258187937688-1mjb8948qn4bo36tg5d4c0d93f2n12ai.apps.googleusercontent.com";
      GOOGLE_API_KEY = "$(${pkgs.coreutils}/bin/cat ${config.age.secrets.google-api.path} 2>/dev/null)";
    };

    sessionPath = [ "$HOME/.nix-profile/bin" ];

    shellAliases = {
      os = "nh os";
      hm = "nh home";
    };
  };

  home.packages = with pkgs; [
    eza
    bat
    gh
    yazi
    fd
    ripgrep
    tldr
    nixfmt-rfc-style
    nixpkgs-review
    nix-output-monitor
    nix-update
    lazygit
    duf
    hydra-check
    ragenix
    nil
    file
    nix-tree
    patchelf
    ssh-to-age
    gcc
  ];

  programs = {
    nh = {
      enable = true;
      flake = "$HOME/nixos-config";
    };
    nix-index.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    bash = {
      enable = true;
      sessionVariables = {
        NOSYSABASHRC = 1;
      };
    };
  };

  services.vscode-server = {
    enable = false;
    enableFHS = false;
    installPath = "$HOME/.vscode-server";
  };

  nix.registry = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
    nixpkgs.to = {
      type = "path";
      path = inputs.nixpkgs;
    };
  };

  home.stateVersion = "24.11";
}
