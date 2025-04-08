{
  config,
  pkgs,
  inputs,
  system,
  self,
  ...
}:
let
  extensions = inputs.nix-vscode-extensions.extensions.${system};
in
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
      enable = false;
      desktop = "$HOME";
      download = "$HOME";
      createDirectories = false;
    };
  };

  home = {
    sessionVariables = {
      EDITOR = "nvim";
      CACHIX_AUTH_TOKEN = "$(${pkgs.coreutils}/bin/cat ${config.age.secrets.cachix.path} 2>/dev/null)";
      GITHUB_TOKEN = "$(${pkgs.coreutils}/bin/cat ${config.age.secrets.github.path} 2>/dev/null)";
      NIXPKGS_ALLOW_UNFREE = "1";
    };

    shellAliases = {
      os = "nh os";
      hm = "nh home";
    };
  };

  home.packages = with pkgs; [
    gh
    yazi
    fd
    ripgrep
    tldr
    # cachix
    nixfmt-rfc-style
    nixpkgs-review
    nix-output-monitor
    nix-update
    lazygit
  ];
  programs = {
    nh = {
      enable = true;
      flake = "/home/${config.users.users.admin.name}/nixos-config";
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
  };

  services.vscode-server = {
    enable = true;
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
