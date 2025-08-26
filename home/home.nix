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
    ./CLI/bash.nix
    ./CLI/zsh.nix
    ./CLI/git.nix
    ./CLI/ssh.nix
  ];

  nixpkgs.config.allowUnfree = true;

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
    sessionVariables = {
      EDITOR = "nvim";
      CACHIX_AUTH_TOKEN = "$(${pkgs.coreutils}/bin/cat ${config.age.secrets.cachix.path} 2>/dev/null)";
      GITHUB_TOKEN = "$(${pkgs.coreutils}/bin/cat ${config.age.secrets.github.path} 2>/dev/null)";
      NIXPKGS_ALLOW_UNFREE = "1";
      GOOGLE_DEFAULT_CLIENT_SECRET = "$(${pkgs.coreutils}/bin/cat ${config.age.secrets.google-client.path} 2>/dev/null)";
      GOOGLE_DEFAULT_CLIENT_ID = "258187937688-1mjb8948qn4bo36tg5d4c0d93f2n12ai.apps.googleusercontent.com";
      GOOGLE_API_KEY = "$(${pkgs.coreutils}/bin/cat ${config.age.secrets.google-api.path} 2>/dev/null)";
    };

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
    python3
    hydra-check
    ragenix
    nil
    # tectonic #broken in 2025-08-25
    file
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
    tmux = {
      shortcut = "a";
      # aggressiveResize = true; -- Disabled to be iTerm-friendly
      baseIndex = 1;
      newSession = true;
      # Stop tmux+escape craziness.
      # escapeTime = 0;
      # Force tmux to use /tmp for sockets (WSL2 compat)
      secureSocket = false;
      enable = true;
      plugins = with pkgs; [
        tmuxPlugins.better-mouse-mode
      ];

      extraConfig = ''
        set -g status off
        set -g set-titles on
        set -g set-titles-string "#{USER}@#H:#{PWD}"

        # Mouse works as expected
        set-option -g mouse on
        # easy-to-remember split pane commands
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"
      '';
    };
    helix = {
      enable = false;
      settings = {
        theme = "autumn_night_transparent";
        editor.cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
      };
      languages.language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = lib.getExe pkgs.nixfmt-rfc-style;
        }
      ];
      themes = {
        autumn_night_transparent = {
          "inherits" = "autumn_night";
          "ui.background" = { };
        };
      };
    };
  };

  services.vscode-server = {
    enable = false;
    enableFHS = false;
    installPath = "$HOME/.vscode-server";
  };

  nix.registry = {
    nur-fem = {
      to = {
        owner = "qbisi";
        repo = "nur-fem";
        type = "github";
      };
    };
  };

  home.stateVersion = "24.11";
}
