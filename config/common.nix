{
  lib,
  config,
  pkgs,
  self,
  inputs,
  ...
}:
{
  imports = [
    self.nixosModules.default
    inputs.nixos-images.nixosModules.default
    inputs.nur-fem.nixosModules.default
    inputs.secrets.nixosModules.default
    inputs.daeuniverse.nixosModules.daed
  ] ++ self.lib.listNixFilesRecursive ./common;

  time.timeZone = "Asia/Shanghai";

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    home-manager
    tree
    htop
    neofetch
    rsync
    usbutils
    pciutils
    fzf
  ];

  programs.nh = {
    enable = true;
    flake = "/home/${config.users.users.admin.name}/nixos-config";
  };

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      help = "run-help";
    };
    interactiveShellInit = ''
      if [ "$VSCODE_INJECTION" = "1" ]; then
        if [[ "$VSCODE_ZDOTDIR" == *"code"* ]]; then
          export EDITOR="code --wait"
        elif [[ "$VSCODE_ZDOTDIR" == *"codium"* ]]; then
          export EDITOR="codium --wait"
        fi
      fi
    '';
    ohMyZsh = {
      enable = true;
      theme = "gentoo";
      plugins = [
        "git"
        "history"
        "wd"
        "sudo"
      ];
    };
  };

  programs.bash = {
    # blesh.enable = true;
    # loginShellInit = ''
    #   if [ -f ~/.bashrc ]; then
    #     source ~/.bashrc
    #   fi
    # '';
    # promptInit = ''
    #   # Provide a nice prompt if the terminal supports it.
    #   export GIT_PS1_SHOWDIRTYSTATE=1
    #   export GIT_PS1_SHOWCOLORHINTS=1
    #   source ${pkgs.git}/share/bash-completion/completions/git-prompt.sh
    #   if [ "$TERM" != "dumb" ] || [ -n "$INSIDE_EMACS" ]; then
    #     PROMPT_COLOR="1;31m"
    #     ((UID)) && PROMPT_COLOR="1;32m"
    #     if [ -n "$INSIDE_EMACS" ]; then
    #       # Emacs term mode doesn't support xterm title escape sequence (\e]0;)
    #       PS1="\n\[\033[$PROMPT_COLOR\][\u@\h:\w]\\$\[\033[0m\] "
    #     else
    #       PS1="\n\[\033[$PROMPT_COLOR\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\\$\[\033[0m\] "
    #     fi
    #     if [[ $TERM == xterm* ]]; then
    #       PS1='\[\e[32m\]\u@\h \[\e[34m\]\w$(__git_ps1 " \[\e[35m\](%s\[\e[35m\])") \[\e[34m\]\$ \[\e[0m\]'
    #     fi
    #   fi
    # '';
    # interactiveShellInit = ''
    #   echo -ne "\033]0;$USER@$HOSTNAME\007"
    #   ble-sabbrev sd='sudo'
    #   ble-sabbrev sduo='sudo'
    #   ble-bind -f up 'history-search-backward immediate-accept'
    #   ble-bind -f down 'history-search-forward immediate-accept'
    #   if [ "$VSCODE_INJECTION" = "1" ]; then
    #       export EDITOR="code --wait"
    #   fi
    # '';
  };

  networking.tproxy.users = [ config.users.users.admin.name ];

  users.users = {
    admin = {
      inherit (self.vars.user) name hashedPassword;
      uid = 1000;
      isNormalUser = true;
      linger = true;
      shell = pkgs.zsh;
      extraGroups = [
        "wheel"
        "root"
        "video"
        "audio"
      ];
      openssh.authorizedKeys.keys = [
        self.vars.user.authorizedKeys
      ];
    };
    root.openssh.authorizedKeys.keys = [
      self.vars.user.authorizedKeys
    ];
  };

  nix = {
    registry = {
      agenix.to = {
        owner = "ryantm";
        repo = "agenix";
        type = "github";
      };
      colmena.to = {
        owner = "zhaofengli";
        repo = "colmena";
        type = "github";
      };
    };

    settings = {
      keep-outputs = true;
      # auto-optimise-store = true;
      warn-dirty = false;
      # Whether to accept nix configuration from a flake without prompting.
      accept-flake-config = true;
      experimental-features = [
        "nix-command"
        "flakes"
        # "pipe-operators"
      ];
      trusted-users = [ config.users.users.admin.name ];
      substituters = [
        # "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://nix-community.cachix.org"
        "https://colmena.cachix.org"
        # "ssh://root@${self.vars.hosts.x79.ip}?ssh-key=/run/agenix/id_ed25519"
      ];
      builders-use-substitutes = true;
      fallback = true;
      connect-timeout = 3;
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
        "cache.csrc.eu.org-1:x5rEGDqKTfp6brF2lvevAhDtBWZFrSWx7u8EH/kL/6k="
        "cache.qbisi.cc-1:xEChzP5k8fj+7wajY+e9IDORRTGMhViP5NaqMShGGjQ="
      ];
    };

    package = pkgs.nixVersions.latest;

    distributedBuilds = true;
  };
}
