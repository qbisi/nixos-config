{
  config,
  pkgs,
  inputs,
  self,
  ...
}:
{
  imports = [
    ./terminal/bash.nix
    ./terminal/zsh.nix
    ./terminal/git.nix
    ./terminal/ssh.nix
    self.homeManagerModules.secrets
  ];

  nixpkgs.config.allowUnfree = true;

  systemd.user.startServices = "sd-switch";

  home.sessionVariables = {
    EDITOR = "nvim";
    CACHIX_AUTH_TOKEN = "$(${pkgs.coreutils}/bin/cat ${config.age.secrets.cachix.path} 2>/dev/null)";
    GITHUB_TOKEN = "$(${pkgs.coreutils}/bin/cat ${config.age.secrets.github.path} 2>/dev/null)";
  };

  home.packages = with pkgs; [
    gh
    nixpkgs-review
    cachix
    # minicom
    # rkdeveloptool
    nixfmt-rfc-style
    colmena
    inputs.agenix.packages.${config.nixpkgs.system}.default
  ];

  programs = {
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
    vscode = {
    extensions = with pkgs.vscode-extensions; [
      dracula-theme.theme-dracula
      yzhang.markdown-all-in-one
      jnoortheen.nix-ide
      james-yu.latex-workshop
      mkhl.direnv
      # ms-python.vscode-pylance
      # ms-python.python
      # ms-python.debugpy
      ms-vscode-remote.remote-ssh
      editorconfig.editorconfig
    ];
  };
  };

  services.vscode-server = {
    enable = false;
    enableFHS = false;
  };

  home.stateVersion = "24.11";
}
