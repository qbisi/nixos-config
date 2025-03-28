{
  lib,
  config,
  pkgs,
  self,
  ...
}:
{
  imports = lib.filesystem.listFilesRecursive ./common;

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

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      X11Forwarding = true;
    };
    knownHosts = {
      ft = {
        extraHostNames = [ self.vars.hostIP.ft ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMaB38zfFByF9iolK5iJou7qjCmxtIFWreYMr/dKqeJp";
      };
      x79 = {
        extraHostNames = [ self.vars.hostIP.x79 ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB6hQrT6/2Kmr7dpAHUapxsv2t/uRF+GDehDwekj28mg";
      };
      mac = {
        extraHostNames = [ self.vars.hostIP.mac ];
        publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEYDL2Cb4lQ/NKRch7cekOdgmFlmT4tdDnv5r9VoGpss156tKamTa5dW7apjKqA1R2xTePyb7dVwzki1q0W/W9M=";
      };
    };
  };

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
      # auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];
      trusted-users = [ config.users.users.admin.name ];
      warn-dirty = false;
      substituters = [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://nix-community.cachix.org"
        "https://colmena.cachix.org"
        # "ssh://root@${self.vars.hostIP.x79}?ssh-key=/run/agenix/id_ed25519"
      ];
      builders-use-substitutes = true;
      fallback = true;
      connect-timeout = 3;
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
      ];
    };

    package = pkgs.nixVersions.latest;

    distributedBuilds = true;
  };
}
