{
  lib,
  config,
  pkgs,
  pkgs-self,
  self,
  ...
}:
{
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

  programs.vim.defaultEditor = true;

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
          export EDITOR="code --wait"
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
    blesh.enable = true;
    loginShellInit = ''
      if [ -f ~/.bashrc ]; then
        source ~/.bashrc
      fi
    '';
    promptInit = ''
      # Provide a nice prompt if the terminal supports it.
      export GIT_PS1_SHOWDIRTYSTATE=1
      export GIT_PS1_SHOWCOLORHINTS=1
      source ${pkgs.git}/share/bash-completion/completions/git-prompt.sh
      if [ "$TERM" != "dumb" ] || [ -n "$INSIDE_EMACS" ]; then
        PROMPT_COLOR="1;31m"
        ((UID)) && PROMPT_COLOR="1;32m"
        if [ -n "$INSIDE_EMACS" ]; then
          # Emacs term mode doesn't support xterm title escape sequence (\e]0;)
          PS1="\n\[\033[$PROMPT_COLOR\][\u@\h:\w]\\$\[\033[0m\] "
        else
          PS1="\n\[\033[$PROMPT_COLOR\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\\$\[\033[0m\] "
        fi
        if [[ $TERM == xterm* ]]; then
          PS1='\[\e[32m\]\u@\h \[\e[34m\]\w$(__git_ps1 " \[\e[35m\](%s\[\e[35m\])") \[\e[34m\]\$ \[\e[0m\]'
        fi
      fi
    '';
    interactiveShellInit = ''
      echo -ne "\033]0;$USER@$HOSTNAME\007"
      ble-sabbrev sd='sudo'
      ble-sabbrev sduo='sudo'
      ble-bind -f up 'history-search-backward immediate-accept'
      ble-bind -f down 'history-search-forward immediate-accept'
      if [ "$VSCODE_INJECTION" = "1" ]; then
          export EDITOR="code --wait"
      fi
    '';
  };

  users.users = {
    "${self.vars.user.name}" = {
      inherit (self.vars.user) hashedPassword;
      isNormalUser = true;
      linger = true;
      shell = pkgs.zsh;
      extraGroups = [
        "wheel"
        "root"
      ];
      openssh.authorizedKeys.keys = [
        self.vars.user.authorizedKeys
      ];
    };
    root.openssh.authorizedKeys.keys = [
      self.vars.user.authorizedKeys
    ];
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ "@wheel" ];
    substituters = [
      # use mirror in CN only
      # "https://mirrors.ustc.edu.cn/nix-channels/store" 
      "https://nix-community.cachix.org"
    ];

    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  nix.package = pkgs.nixVersions.latest;

  nix.distributedBuilds = true;
}
